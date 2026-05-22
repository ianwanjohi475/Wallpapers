import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Alex Rivera');
  final _emailCtrl = TextEditingController(text: 'alex.rivera@example.com');
  final _bioCtrl =
      TextEditingController(text: 'Die-hard football fan since 2010.');
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.accentGreen, size: 18),
            SizedBox(width: 8),
            Text('Profile updated',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
          ],
        ),
        backgroundColor: AppColors.bgCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final maxW = Responsive.contentMaxWidth(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text(
                  'EDIT PROFILE',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.bgElevated,
                                  border: Border.all(
                                      color: AppColors.accentGold, width: 2),
                                ),
                                child: const Center(
                                  child: Text(
                                    'AR',
                                    style: TextStyle(
                                      fontFamily: 'Rajdhani',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 34,
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Photo picker coming soon'),
                                        backgroundColor: AppColors.bgCard,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGradient,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.bgPrimary,
                                          width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded,
                                        color: AppColors.bgPrimary, size: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _label('Full Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your name'
                              : null,
                          style: _fieldStyle,
                          decoration:
                              _decoration('Your name', Icons.person_rounded),
                        ),
                        const SizedBox(height: 20),
                        _label('Email Address'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                          style: _fieldStyle,
                          decoration:
                              _decoration('you@example.com', Icons.email_rounded),
                        ),
                        const SizedBox(height: 20),
                        _label('Bio'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _bioCtrl,
                          maxLines: 3,
                          maxLength: 120,
                          style: _fieldStyle,
                          decoration: _decoration(
                              'Tell us about yourself', Icons.edit_note_rounded),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _saving ? null : _save,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 56,
                            decoration: BoxDecoration(
                              gradient:
                                  _saving ? null : AppColors.goldGradient,
                              color: _saving ? AppColors.bgCard : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _saving
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
                              child: _saving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: AppColors.accentGold,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'SAVE CHANGES',
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _fieldStyle = TextStyle(
      fontFamily: 'Inter', fontSize: 15, color: Colors.white);

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      );

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 15, color: AppColors.textTertiary),
      prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      counterStyle:
          const TextStyle(fontFamily: 'Inter', color: AppColors.textTertiary),
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
