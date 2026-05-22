import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../painters/orb_painter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;

  late AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxW = Responsive.contentMaxWidth(context);

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
                opacity: 0.32,
                child: CustomPaint(
                  size: size,
                  painter: OrbPainter(t: _orbCtrl.value, orbs: purpleOrbs),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _sent ? _buildSuccess() : _buildForm(),
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _BackButton(onTap: () => Navigator.maybePop(context)),
          const SizedBox(height: 48),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.3),
                    width: 1),
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  color: AppColors.accentGold, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Reset Password',
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
              'Enter your email and we\'ll send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Email Address',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
            style: const TextStyle(
                fontFamily: 'Inter', fontSize: 15, color: Colors.white),
            decoration: _decoration('you@example.com', Icons.email_rounded),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 56,
              decoration: BoxDecoration(
                gradient: _loading ? null : AppColors.goldGradient,
                color: _loading ? AppColors.bgCard : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _loading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.35),
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
                        'SEND RESET LINK',
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
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.maybePop(context);
              },
              child: const Text(
                'Back to Log In',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.accentGold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: _BackButton(onTap: () => Navigator.maybePop(context)),
        ),
        const SizedBox(height: 60),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.accentGreen.withValues(alpha: 0.4), width: 1),
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              color: AppColors.accentGreen, size: 46),
        ),
        const SizedBox(height: 28),
        const Text(
          'Check Your Inbox',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a password reset link to\n${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 48),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Back to Log In',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.bgPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: const Text(
            'Didn\'t get it? Try again',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 15, color: AppColors.textTertiary),
      prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }
}
