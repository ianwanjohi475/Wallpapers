-- WC Wallpapers 2026 — initial schema
-- Run this once in Supabase SQL Editor: https://supabase.com/dashboard/project/_/sql/new

-- =====================================================================
-- 1. WALLPAPERS
-- =====================================================================
create table if not exists public.wallpapers (
  id              uuid primary key default gen_random_uuid(),
  slug            text unique not null,
  title           text not null,
  description     text,
  image_url       text not null,
  thumb_url       text,
  category        text not null,
  resolution      text not null default '4K',
  is_premium      boolean not null default false,
  is_featured     boolean not null default false,
  is_new          boolean not null default false,
  download_count  integer not null default 0,
  like_count      integer not null default 0,
  tags            text[]  not null default '{}',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists wallpapers_category_idx on public.wallpapers(category);
create index if not exists wallpapers_featured_idx on public.wallpapers(is_featured) where is_featured;
create index if not exists wallpapers_new_idx on public.wallpapers(is_new) where is_new;
create index if not exists wallpapers_downloads_idx on public.wallpapers(download_count desc);

-- IMMUTABLE wrapper so the expression can be used in a GIN index.
-- (to_tsvector(regconfig, text) is immutable, but PostgreSQL won't infer
-- immutability through a concatenation of column references, so we wrap it.)
create or replace function public.wallpapers_search_doc(t text, c text, tg text[])
returns tsvector
language sql
immutable
as $$
  select to_tsvector('english'::regconfig,
    coalesce(t,'') || ' ' || coalesce(c,'') || ' ' || coalesce(array_to_string(tg,' '),''))
$$;

create index if not exists wallpapers_search_idx on public.wallpapers using gin (
  public.wallpapers_search_doc(title, category, tags)
);

-- =====================================================================
-- 2. PROFILES (1-to-1 with auth.users)
-- =====================================================================
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  name        text,
  email       text,
  bio         text,
  avatar_url  text,
  is_premium  boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Auto-create a profile row when a new auth user signs up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- 3. FAVORITES
-- =====================================================================
create table if not exists public.user_favorites (
  user_id      uuid references auth.users(id) on delete cascade,
  wallpaper_id uuid references public.wallpapers(id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (user_id, wallpaper_id)
);

create index if not exists user_favorites_user_idx on public.user_favorites(user_id);

-- Keep wallpapers.like_count in sync
create or replace function public.bump_like_count()
returns trigger language plpgsql as $$
begin
  if (tg_op = 'INSERT') then
    update public.wallpapers set like_count = like_count + 1 where id = new.wallpaper_id;
    return new;
  elsif (tg_op = 'DELETE') then
    update public.wallpapers set like_count = greatest(0, like_count - 1) where id = old.wallpaper_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists user_favorites_like_count on public.user_favorites;
create trigger user_favorites_like_count
  after insert or delete on public.user_favorites
  for each row execute function public.bump_like_count();

-- =====================================================================
-- 4. DOWNLOADS
-- =====================================================================
create table if not exists public.user_downloads (
  id           bigserial primary key,
  user_id      uuid references auth.users(id) on delete cascade,
  wallpaper_id uuid references public.wallpapers(id) on delete cascade,
  created_at   timestamptz not null default now()
);

create index if not exists user_downloads_user_idx on public.user_downloads(user_id, created_at desc);

create or replace function public.bump_download_count()
returns trigger language plpgsql as $$
begin
  update public.wallpapers set download_count = download_count + 1 where id = new.wallpaper_id;
  return new;
end;
$$;

drop trigger if exists user_downloads_dl_count on public.user_downloads;
create trigger user_downloads_dl_count
  after insert on public.user_downloads
  for each row execute function public.bump_download_count();

-- =====================================================================
-- 5. UPDATED_AT TRIGGER
-- =====================================================================
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists wallpapers_touch on public.wallpapers;
create trigger wallpapers_touch before update on public.wallpapers
  for each row execute function public.touch_updated_at();

drop trigger if exists profiles_touch on public.profiles;
create trigger profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

-- =====================================================================
-- 6. SEARCH FUNCTION (used by search_screen.dart)
-- =====================================================================
create or replace function public.search_wallpapers(q text)
returns setof public.wallpapers
language sql stable as $$
  select * from public.wallpapers
  where public.wallpapers_search_doc(title, category, tags)
        @@ plainto_tsquery('english'::regconfig, q)
     or title ilike '%' || q || '%'
     or category ilike '%' || q || '%'
  order by download_count desc;
$$;

-- =====================================================================
-- 7. ROW-LEVEL SECURITY
-- =====================================================================
alter table public.wallpapers      enable row level security;
alter table public.profiles        enable row level security;
alter table public.user_favorites  enable row level security;
alter table public.user_downloads  enable row level security;

-- Wallpapers: everyone (incl. guests) can read
drop policy if exists wallpapers_select_all on public.wallpapers;
create policy wallpapers_select_all on public.wallpapers
  for select using (true);

-- Profiles: anyone can view a public profile; only owner can update
drop policy if exists profiles_select_all on public.profiles;
create policy profiles_select_all on public.profiles
  for select using (true);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update using (auth.uid() = id);

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert with check (auth.uid() = id);

-- Favorites: owner only
drop policy if exists favorites_select_own on public.user_favorites;
create policy favorites_select_own on public.user_favorites
  for select using (auth.uid() = user_id);

drop policy if exists favorites_insert_own on public.user_favorites;
create policy favorites_insert_own on public.user_favorites
  for insert with check (auth.uid() = user_id);

drop policy if exists favorites_delete_own on public.user_favorites;
create policy favorites_delete_own on public.user_favorites
  for delete using (auth.uid() = user_id);

-- Downloads: owner only
drop policy if exists downloads_select_own on public.user_downloads;
create policy downloads_select_own on public.user_downloads
  for select using (auth.uid() = user_id);

drop policy if exists downloads_insert_own on public.user_downloads;
create policy downloads_insert_own on public.user_downloads
  for insert with check (auth.uid() = user_id);

-- =====================================================================
-- 8. STORAGE BUCKETS (avatars)
-- =====================================================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists avatars_public_read on storage.objects;
create policy avatars_public_read on storage.objects
  for select using (bucket_id = 'avatars');

drop policy if exists avatars_owner_write on storage.objects;
create policy avatars_owner_write on storage.objects
  for insert with check (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists avatars_owner_update on storage.objects;
create policy avatars_owner_update on storage.objects
  for update using (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists avatars_owner_delete on storage.objects;
create policy avatars_owner_delete on storage.objects
  for delete using (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );
