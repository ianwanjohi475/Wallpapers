# Supabase Setup — WC Wallpapers 2026

The Flutter app talks to Supabase for **auth, wallpapers, favourites,
downloads, and profiles**. Everything else is local.

You only need to do this once. Total time: ~10 minutes.

---

## 1 · Create the project

1. Go to **https://supabase.com** and sign in.
2. Click **New Project** → name it `wc-wallpapers`, pick a region close to
   your users, set a database password (save it somewhere).
3. Wait ~2 minutes for the database to spin up.

---

## 2 · Run the SQL migrations

1. In your Supabase dashboard, open **SQL Editor → New query**.
2. Paste the contents of `supabase/migrations/001_init.sql` and click **Run**.
3. Open a new query, paste `supabase/migrations/002_seed.sql`, and **Run**.

You should now see these tables under **Table Editor**:
- `wallpapers` (43 rows seeded)
- `profiles`
- `user_favorites`
- `user_downloads`

And one storage bucket called `avatars` (public).

---

## 3 · Wire your API keys into the app

1. In Supabase, go to **Settings → API**. Copy:
   - **Project URL** (looks like `https://abcd1234.supabase.co`)
   - **anon / public key** (long JWT — safe to ship in client code)

2. Open `lib/core/supabase_config.dart` and paste them in:
   ```dart
   const String kSupabaseUrl    = 'https://abcd1234.supabase.co';
   const String kSupabaseAnonKey = 'eyJhbGciOi...';
   ```

> Don't paste the `service_role` key. The anon key is the only one that
> belongs in the app — RLS policies (in the SQL) protect every write.

---

## 4 · Enable email confirmation (OTP code, not link)

1. **Authentication → Providers → Email**.
2. Make sure **Enable Email provider** is on.
3. Under **Email auth settings**, ensure **Confirm email** is on so users
   receive a verification code after sign-up.
4. (Optional) **Authentication → Email Templates → Confirm signup** — replace
   the default link template with the OTP-style template:
   ```
   <h2>Your WC Wallpapers code</h2>
   <p>Enter this 6-digit code in the app:</p>
   <p style="font-size:28px;font-weight:bold">{{ .Token }}</p>
   ```
   The `{{ .Token }}` placeholder is the 6-digit OTP the
   `EmailOtpScreen` expects.

---

## 5 · Enable Google sign-in

1. **Authentication → Providers → Google** → toggle on.
2. Supabase shows you a callback URL like
   `https://<project>.supabase.co/auth/v1/callback` — copy it.
3. In **Google Cloud Console** → APIs & Services → Credentials → **Create
   OAuth client ID** → Web application.
   - **Authorized redirect URI:** paste the Supabase callback URL above.
   - Copy the **Client ID** and **Client secret** back into Supabase's
     Google provider settings.
4. Back in Supabase, under **Authentication → URL Configuration**, add the
   app's deep link to **Redirect URLs**:
   ```
   io.wcwallpapers.app://login-callback
   ```
   This matches the intent-filter already in `AndroidManifest.xml`.

---

## 6 · Install the new Dart packages

From the project root:
```bash
flutter pub get
```

`supabase_flutter` and `app_links` are the only new dependencies.

---

## 7 · Run the app

```bash
flutter run
```

You should see:
- Splash → Onboarding (first run) → Login
- Login offers **Continue with Google**, email/password, or **Continue as guest**
- Sign-up shows the email field + password, then a 6-digit OTP screen
- Home/Browse/Search/Favourites/Categories all load from Supabase
- Tapping **Download** while in guest mode prompts you to sign up
- Liking syncs to `user_favorites` automatically when signed in

---

## What was built

| Layer | Files |
|---|---|
| Schema + RLS + seed | `supabase/migrations/001_init.sql`, `002_seed.sql` |
| Config | `lib/core/supabase_config.dart` |
| Services | `lib/services/{auth,wallpaper,favorites,download,profile}_service.dart` |
| Auth state | `lib/providers/auth_provider.dart` |
| Sync favourites | `lib/providers/favorites_provider.dart` (updated) |
| OTP screen | `lib/screens/email_otp_screen.dart` |
| Auth-required sheet | `lib/widgets/auth_required_sheet.dart` |
| Guest button | added to `login_screen.dart` |
| Real downloads tab | `lib/screens/downloads_screen.dart` |
| Real profile | `lib/screens/{settings,edit_profile}_screen.dart` |

Future swap: change `image_url` values from Unsplash → Cloudflare R2 once
you have your own 4K renders ready. Nothing in the Flutter code needs to
change.
