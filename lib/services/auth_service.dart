import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Thin wrapper around supabase_flutter auth.
/// All methods throw [AuthException] on failure for the UI to catch.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _sb = Supabase.instance.client;

  // ----- Session helpers --------------------------------------------------
  User? get currentUser => _sb.auth.currentUser;
  Session? get currentSession => _sb.auth.currentSession;
  bool get isSignedIn => currentSession != null;
  Stream<AuthState> get onAuthStateChange => _sb.auth.onAuthStateChange;

  // ----- Email + password sign-up (sends OTP confirmation code) ----------
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return _sb.auth.signUp(
      email: email,
      password: password,
      data: {if (fullName != null) 'full_name': fullName},
      emailRedirectTo: null, // We use OTP code flow, not link.
    );
  }

  // ----- Verify the 6-digit OTP that Supabase emails after sign-up -------
  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) {
    return _sb.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );
  }

  // ----- Resend confirmation OTP -----------------------------------------
  Future<void> resendSignupOtp(String email) {
    return _sb.auth.resend(type: OtpType.signup, email: email);
  }

  // ----- Email + password sign-in ----------------------------------------
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _sb.auth.signInWithPassword(email: email, password: password);
  }

  // ----- Google OAuth — opens Chrome Custom Tab (slides in-app, not full browser)
  Future<bool> signInWithGoogle() {
    return _sb.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kAuthRedirectUrl,
      // externalNonBrowserApplication = Chrome Custom Tabs on Android,
      // SFSafariViewController on iOS — both feel in-app, not a browser tab.
      authScreenLaunchMode: LaunchMode.externalNonBrowserApplication,
    );
  }

  // ----- Password reset (sends email with link) --------------------------
  Future<void> sendPasswordReset(String email) {
    return _sb.auth.resetPasswordForEmail(email);
  }

  // ----- Sign out ---------------------------------------------------------
  Future<void> signOut() => _sb.auth.signOut();
}
