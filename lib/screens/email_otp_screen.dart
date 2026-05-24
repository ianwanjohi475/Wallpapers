import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../painters/orb_painter.dart';
import '../providers/notifications_provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

/// 6-digit confirmation code screen shown right after sign-up.
class EmailOtpScreen extends StatefulWidget {
  final String email;

  const EmailOtpScreen({super.key, required this.email});

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen>
    with SingleTickerProviderStateMixin {
  static const _len = 6;

  late final List<TextEditingController> _ctrls =
      List.generate(_len, (_) => TextEditingController());
  late final List<FocusNode> _focus = List.generate(_len, (_) => FocusNode());

  bool _verifying = false;
  String? _error;
  int _resendIn = 0;
  Timer? _resendTicker;
  late AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 22))
      ..repeat();
    _startResendCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTicker?.cancel();
    _orbCtrl.dispose();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendIn = 60);
    _resendTicker?.cancel();
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendIn <= 1) {
        t.cancel();
        setState(() => _resendIn = 0);
      } else {
        setState(() => _resendIn--);
      }
    });
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _code;
    if (code.length != _len) {
      setState(() => _error = 'Enter all 6 digits');
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await AuthService.instance
          .verifySignupOtp(email: widget.email, token: code);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      await context.read<NotificationsProvider>().addWelcomeNotification();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (_) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = _friendlyAuthError(e.message));
    } catch (e) {
      setState(() => _error = _friendlyNetworkError(e));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resendIn > 0) return;
    HapticFeedback.lightImpact();
    try {
      await AuthService.instance.resendSignupOtp(widget.email);
      _startResendCountdown();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New code sent to your email'),
          backgroundColor: AppColors.bgCard,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not resend. Try again in a moment.'),
          backgroundColor: AppColors.bgCard,
        ),
      );
    }
  }

  static String _friendlyAuthError(String raw) {
    final r = raw.toLowerCase();
    if (r.contains('token') || r.contains('invalid') || r.contains('otp')) {
      return 'Incorrect code. Please double-check and try again.';
    }
    if (r.contains('expired')) return 'Code expired. Tap "Resend" to get a new one.';
    if (r.contains('rate') || r.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return raw;
  }

  static String _friendlyNetworkError(Object e) {
    final s = e.toString();
    if (s.contains('SocketException') ||
        s.contains('Connection reset') ||
        s.contains('ClientException') ||
        s.contains('NetworkException') ||
        s.contains('Failed host lookup')) {
      return 'No internet connection. Check your connection and try again.';
    }
    return 'Verification failed. Please try again.';
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
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
                                        color: AppColors.borderSubtle,
                                        width: 0.5),
                                  ),
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accentGold.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.accentGold
                                        .withValues(alpha: 0.3),
                                    width: 1),
                              ),
                              child: const Icon(
                                  Icons.mark_email_unread_rounded,
                                  color: AppColors.accentGold,
                                  size: 38),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Verify Your Email',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w700,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                      text:
                                          'We sent a 6-digit confirmation code to\n'),
                                  TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_len, (i) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: SizedBox(
                                    width: 44,
                                    height: 56,
                                    child: TextField(
                                      controller: _ctrls[i],
                                      focusNode: _focus[i],
                                      maxLength: 1,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: const TextStyle(
                                        fontFamily: 'Rajdhani',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: AppColors.bgCard,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: AppColors.borderSubtle,
                                              width: 0.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: AppColors.borderSubtle,
                                              width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: AppColors.accentGold,
                                              width: 1.5),
                                        ),
                                      ),
                                      onChanged: (v) {
                                        if (v.isNotEmpty && i < _len - 1) {
                                          _focus[i + 1].requestFocus();
                                        } else if (v.isEmpty && i > 0) {
                                          _focus[i - 1].requestFocus();
                                        }
                                        if (_code.length == _len) {
                                          _verify();
                                        }
                                        setState(() => _error = null);
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: _verifying ? null : _verify,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 56,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient:
                                      _verifying ? null : AppColors.goldGradient,
                                  color: _verifying ? AppColors.bgCard : null,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: _verifying
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
                                  child: _verifying
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: AppColors.accentGold,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'VERIFY & CONTINUE',
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
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Didn't receive the code? ",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _resend,
                                  child: Text(
                                    _resendIn > 0
                                        ? 'Resend in ${_resendIn}s'
                                        : 'Resend',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: _resendIn > 0
                                          ? AppColors.textTertiary
                                          : AppColors.accentGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
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
