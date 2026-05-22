import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../painters/orb_painter.dart';
import '../widgets/google_logo.dart';
import 'legal_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;
  bool _agreedToTerms = false;

  final _termsRecognizer = TapGestureRecognizer();
  final _privacyRecognizer = TapGestureRecognizer();

  late AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    _termsRecognizer.onTap = () => _openLegal(LegalScreen.terms());
    _privacyRecognizer.onTap = () => _openLegal(LegalScreen.privacy());
  }

  void _openLegal(Widget page) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: AppColors.bgCard,
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
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
                  painter: OrbPainter(t: _orbCtrl.value, orbs: splashOrbs),
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
                          // Back button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.maybePop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.borderSubtle, width: 0.5),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Logo + title
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.sports_soccer_rounded,
                                    color: AppColors.bgPrimary, size: 26),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WC WALLPAPERS',
                                    style: TextStyle(
                                      fontFamily: 'Rajdhani',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.accentGold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    '2026',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Join millions of football fans worldwide',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Name field
                          _InputField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            hint: 'e.g. Alex Rivera',
                            icon: Icons.person_rounded,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 16),
                          // Email field
                          _InputField(
                            controller: _emailCtrl,
                            label: 'Email Address',
                            hint: 'you@example.com',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter your email';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          _InputField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            hint: 'Min. 8 characters',
                            icon: Icons.lock_rounded,
                            obscureText: _obscurePassword,
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
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter a password';
                              if (v.length < 8) return 'Password must be 8+ characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Terms checkbox
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _agreedToTerms = !_agreedToTerms);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _agreedToTerms
                                        ? AppColors.accentGold
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _agreedToTerms
                                          ? AppColors.accentGold
                                          : AppColors.borderSubtle,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _agreedToTerms
                                      ? const Icon(Icons.check_rounded,
                                          size: 13,
                                          color: AppColors.bgPrimary)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style: const TextStyle(
                                            color: AppColors.accentGold,
                                            decoration: TextDecoration.underline,
                                            decorationColor: AppColors.accentGold,
                                          ),
                                          recognizer: _termsRecognizer,
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: const TextStyle(
                                            color: AppColors.accentGold,
                                            decoration: TextDecoration.underline,
                                            decorationColor: AppColors.accentGold,
                                          ),
                                          recognizer: _privacyRecognizer,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Signup button
                          GestureDetector(
                            onTap: _loading ? null : _signup,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: _loading
                                    ? null
                                    : AppColors.goldGradient,
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
                                        'CREATE ACCOUNT',
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
                          const SizedBox(height: 24),
                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                    color: AppColors.borderSubtle,
                                    thickness: 0.5),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                    color: AppColors.borderSubtle,
                                    thickness: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Google button
                          _SocialButton(
                            leading: const GoogleLogo(size: 18),
                            label: 'Continue with Google',
                            onTap: () => HapticFeedback.lightImpact(),
                          ),
                          const SizedBox(height: 12),
                          // Already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
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
                                          const LoginScreen(),
                                      transitionsBuilder: (_, anim, __, child) =>
                                          FadeTransition(
                                              opacity: anim, child: child),
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Log In',
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
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix,
                  )
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
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget leading;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.leading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
