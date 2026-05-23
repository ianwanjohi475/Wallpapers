-- Seed wallpapers — run AFTER 001_init.sql
-- Safe to re-run: uses on conflict (slug) do nothing

insert into public.wallpapers
  (slug, title, image_url, category, resolution, is_premium, is_featured, is_new, download_count, like_count)
values
  -- Featured
  ('lusail-finals',       'Lusail Finals',       'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&w=1600&q=85', 'stadiums', '4K', false, true,  false, 12400, 1900),
  ('the-golden-goal',     'The Golden Goal',     'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&w=1600&q=85', 'trophies', '4K', false, true,  false,  8200, 1100),
  ('messiah-magic',       'Messiah Magic',       'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=1600&q=85', 'legends',  '4K', true,  true,  false, 15100, 2300),
  ('hyper-gold',          'Hyper Gold',          'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1600&q=85', 'abstract', '4K', true,  true,  false, 45000, 6200),
  ('galaxy-cup',          'Galaxy Cup',          'https://images.unsplash.com/photo-1486286701208-1d58e9338013?auto=format&fit=crop&w=1600&q=85', 'trophies', '4K', true,  true,  false, 50000, 7100),

  -- New today
  ('brazil-neon',         'Brazil Neon',         'https://images.unsplash.com/photo-1434648957308-5e6a859697e8?auto=format&fit=crop&w=1600&q=85', 'flags',    'HD', false, false, true,   1200,  340),
  ('pitch-lines',         'Pitch Lines',         'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?auto=format&fit=crop&w=1600&q=85', 'abstract', 'HD', true,  false, true,    900,  210),
  ('fire-football',       'Fire Football',       'https://images.unsplash.com/photo-1551958219-acbc595b6c4e?auto=format&fit=crop&w=1600&q=85', 'abstract', 'HD', false, false, true,   2500,  480),

  -- Most downloaded
  ('stadium-crowd',       'Stadium Crowd',       'https://images.unsplash.com/photo-1521537634581-0dced2fee2ef?auto=format&fit=crop&w=1600&q=85', 'stadiums', 'HD', false, false, false, 18000, 2400),
  ('jersey-texture',      'Jersey Texture',      'https://images.unsplash.com/photo-1567447838040-5dc2dca0b92b?auto=format&fit=crop&w=1600&q=85', 'teams',    'HD', false, false, false, 12000, 1600),
  ('neon-goal-post',      'Neon Goal Post',      'https://images.unsplash.com/photo-1432553759672-4b1e91b8ccf4?auto=format&fit=crop&w=1600&q=85', 'neon',     '4K', false, false, false, 33000, 4500),
  ('blueprint-art',       'Blueprint Art',       'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=1600&q=85', 'abstract', 'HD', false, false, false,  9000, 1100),

  -- Browse-all extras
  ('neon-stadium',        'Neon Stadium',        'https://images.unsplash.com/photo-1459865264687-595d652de67e?auto=format&fit=crop&w=1600&q=85', 'stadiums', '4K', true,  false, false, 12400, 1700),
  ('gold-explosion',      'Gold Explosion',      'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?auto=format&fit=crop&w=1600&q=85', 'abstract', 'HD', false, false, false,  8200,  990),
  ('sunset-player',       'Sunset Player',       'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=1600&q=85', 'legends',  'HD', false, false, false, 24100, 3200),
  ('cyberpunk-kit',       'Cyberpunk Kit',       'https://images.unsplash.com/photo-1567361808960-af78c3a8dc73?auto=format&fit=crop&w=1600&q=85', 'neon',     '4K', true,  false, false,  5500,  720),
  ('motion-blur',         'Motion Blur',         'https://images.unsplash.com/photo-1521537634581-0dced2fee2ef?auto=format&fit=crop&w=1600&q=85', 'stadiums', 'HD', false, false, false, 15900, 2100),
  ('trophy-gold',         'Trophy Gold',         'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&w=1600&q=85', 'trophies', '4K', true,  false, false, 30100, 4200),
  ('grass-dew-4k',        'Grass Dew 4K',        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1600&q=85', 'abstract', '4K', false, false, false, 11200, 1500),
  ('flag-splash',         'Flag Splash',         'https://images.unsplash.com/photo-1434648957308-5e6a859697e8?auto=format&fit=crop&w=1600&q=85', 'flags',    'HD', false, false, false,  9400, 1200),
  ('home-jersey',         'Home Jersey',         'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=1600&q=85', 'teams',    'HD', false, false, false,  7300,  940),
  ('dark-pitch',          'Dark Pitch',          'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?auto=format&fit=crop&w=1600&q=85', 'dark',     'HD', false, false, false,  6100,  820),
  ('neon-strike',         'Neon Strike',         'https://images.unsplash.com/photo-1517927033932-b3d18e61fb3a?auto=format&fit=crop&w=1600&q=85', 'neon',     '4K', true,  false, false, 14200, 1900),
  ('captain-legend',      'Captain Legend',      'https://images.unsplash.com/photo-1543351611-58f69d7c1781?auto=format&fit=crop&w=1600&q=85', 'legends',  'HD', false, false, false, 18700, 2500),
  ('world-cup-lift',      'World Cup Lift',      'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?auto=format&fit=crop&w=1600&q=85', 'trophies', '4K', true,  false, false, 22400, 3100),
  ('arena-night',         'Arena Night',         'https://images.unsplash.com/photo-1566577739112-5180d4bf9390?auto=format&fit=crop&w=1600&q=85', 'stadiums', 'HD', false, false, false,  9800, 1300),
  ('team-spirit',         'Team Spirit',         'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?auto=format&fit=crop&w=1600&q=85', 'teams',    'HD', false, false, false, 11500, 1550),
  ('midnight-football',   'Midnight Football',   'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&w=1600&q=85', 'dark',     'HD', false, false, false,  8400, 1100),
  ('glory-flag',          'Glory Flag',          'https://images.unsplash.com/photo-1530549387789-4c1017266635?auto=format&fit=crop&w=1600&q=85', 'flags',    'HD', false, false, false,  7700, 1020),
  ('neon-dribble',        'Neon Dribble',        'https://images.unsplash.com/photo-1484482340112-e1e2682b4856?auto=format&fit=crop&w=1600&q=85', 'neon',     'HD', false, false, false, 10300, 1380),
  ('league-final',        'League Final',        'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?auto=format&fit=crop&w=1600&q=85', 'trophies', 'HD', false, false, false, 16200, 2200),
  ('stadium-lights',      'Stadium Lights',      'https://images.unsplash.com/photo-1620294728046-bb99a5e0e99b?auto=format&fit=crop&w=1600&q=85', 'stadiums', '4K', true,  false, false, 19500, 2650),
  ('kit-collection',      'Kit Collection',      'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?auto=format&fit=crop&w=1600&q=85', 'teams',    'HD', false, false, false,  8800, 1200),
  ('shadow-pitch',        'Shadow Pitch',        'https://images.unsplash.com/photo-1516802273409-68526ee1bdd6?auto=format&fit=crop&w=1600&q=85', 'dark',     'HD', false, false, false,  7200,  980),
  ('neon-rush',           'Neon Rush',           'https://images.unsplash.com/photo-1511886929837-354d827aae26?auto=format&fit=crop&w=1600&q=85', 'neon',     '4K', true,  false, false, 13400, 1780),
  ('golden-boot',         'Golden Boot',         'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=1600&q=85', 'legends',  'HD', false, false, false, 16400, 2200),
  ('cup-closeup',         'Cup Closeup',         'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?auto=format&fit=crop&w=1600&q=85', 'trophies', 'HD', false, false, false, 11200, 1500),
  ('crowd-roar',          'Crowd Roar',          'https://images.unsplash.com/photo-1518553419145-3ebcb52b9093?auto=format&fit=crop&w=1600&q=85', 'stadiums', 'HD', false, false, false,  9200, 1250),
  ('squad-goals',         'Squad Goals',         'https://images.unsplash.com/photo-1600679472829-3044539ce8ed?auto=format&fit=crop&w=1600&q=85', 'teams',    'HD', false, false, false, 10400, 1420),
  ('dark-arena',          'Dark Arena',          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?auto=format&fit=crop&w=1600&q=85', 'dark',     '4K', true,  false, false, 12600, 1680),
  ('icon-legend',         'Icon Legend',         'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1600&q=85', 'legends',  '4K', true,  false, false, 20100, 2700),
  ('silver-glory',        'Silver Glory',        'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=1600&q=85', 'trophies', 'HD', false, false, false,  8700, 1160),
  ('electric-kick',       'Electric Kick',       'https://images.unsplash.com/photo-1484482340112-e1e2682b4856?auto=format&fit=crop&w=1600&q=85', 'neon',     'HD', false, false, false,  9600, 1290)
on conflict (slug) do nothing;
