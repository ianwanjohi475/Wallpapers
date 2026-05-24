import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../painters/orb_painter.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/auth_service.dart';
import '../widgets/google_logo.dart';
import 'forgot_password_screen.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;
  bool _googleLoading = false;
  bool _rememberMe = true;
  String? _error;

  late AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _goMain() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (_) => false,
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      await context.read<FavoritesProvider>().syncWithServer();
      if (!mounted) return;
      _goMain();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Could not sign in. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    HapticFeedback.lightImpact();
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithGoogle();
      // Browser opens — when the user finishes, the auth state listener
      // in AuthProvider fires and the app reloads to MainScreen via
      // the splash gate on next launch. Stay on this screen meanwhile.
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    HapticFeedback.lightImpact();
    await context.read<AuthProvider>().continueAsGuest();
    if (!mounted) return;
    _goMain();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isSignedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _goMain();
          });
        }
        return _buildLoginScreen(context);
      },
    );
  }

  Widget _buildLoginScreen(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              Opacity(
                opacity: 0.35,
                child: CustomPaint(
                  size: size,
                  painter: OrbPainter(t: _orbCtrl.value, orbs: purpleOrbs),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: safeBottom + 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _continueAsGuest,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.borderSubtle, width: 0.5),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(height: 48),
                          const Center(
                            child: Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w700,
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Log in to sync your favorites across devices',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Google FIRST (per request)
                          GestureDetector(
                            onTap: _googleLoading ? null : _loginWithGoogle,
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _googleLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: AppColors.bgPrimary,
                                            strokeWidth: 2),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GoogleLogo(size: 20),
                                          SizedBox(width: 12),
                                          Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: AppColors.bgPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                      color: AppColors.borderSubtle,
                                      thickness: 0.5)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or use email',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: AppColors.textTertiary)),
                              ),
                              const Expanded(
                                  child: Divider(
                                      color: AppColors.borderSubtle,
                                      thickness: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _InputLabel('Email Address'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter your email';
                              }
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: Colors.white),
                            decoration: _inputDecoration(
                              hint: 'you@example.com',
                              prefixIcon: Icons.email_rounded,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _InputLabel('Password'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Enter your password'
                                : null,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: Colors.white),
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              prefixIcon: Icons.lock_rounded,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _rememberMe = !_rememberMe);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? AppColors.accentGold
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: _rememberMe
                                              ? AppColors.accentGold
                                              : AppColors.borderSubtle,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(Icons.check_rounded,
                                              size: 11,
                                              color: AppColors.bgPrimary)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const ForgotPasswordScreen(),
                                      transitionsBuilder:
                                          (_, anim, __, child) =>
                                              FadeTransition(
                                                  opacity: anim, child: child),
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          GestureDetector(
                            onTap: _loading ? null : _login,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 56,
                              decoration: BoxDecoration(
                                gradient:
                                    _loading ? null : AppColors.goldGradient,
                                color: _loading ? AppColors.bgCard : null,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: _loading
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: AppColors.accentGold
                                              .withValues(alpha: 0.35),
                                          blurRadius: 20,
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: AppColors.accentGold,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'LOG IN',
                                        style: TextStyle(
                                          fontFamily: 'Rajdhani',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.bgPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: _continueAsGuest,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.borderSubtle, width: 0.5),
                              ),
                              child: const Center(
                                child: Text(
                                  'Continue as guest',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const SignupScreen(),
                                      transitionsBuilder: (_, anim, __, child) =>
                                          FadeTransition(
                                              opacity: anim, child: child),
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: AppColors.textTertiary,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.textTertiary, size: 20),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
          : null,
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accentGold, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      errorStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12),
    );
  }
}

Widget _InputLabel(String label) => Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
    );
