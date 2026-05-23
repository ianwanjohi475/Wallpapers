// Supabase project credentials.
//
// Fill these from: https://supabase.com/dashboard/project/_/settings/api
//
//   Project URL -> kSupabaseUrl
//   anon public key -> kSupabaseAnonKey
//
// The anon key is safe to ship in client code (RLS policies in the SQL
// migration protect every write). The service_role key is NOT shipped.

const String kSupabaseUrl = 'https://YOUR-PROJECT-REF.supabase.co';
const String kSupabaseAnonKey = 'YOUR-ANON-PUBLIC-KEY';

// Deep-link scheme used for OAuth callbacks (matches AndroidManifest.xml).
const String kAuthRedirectScheme = 'io.wcwallpapers.app';
const String kAuthRedirectUrl = '$kAuthRedirectScheme://login-callback';
