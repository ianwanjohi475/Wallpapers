import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  bool _saving = false;
  bool _uploadingAvatar = false;
  bool _loaded = false;
  String? _avatarUrl;
  String _initials = 'WC';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final profile = context.read<AuthProvider>().profile;
    if (profile != null) {
      _nameCtrl.text = profile.name ?? '';
      _emailCtrl.text = profile.email ?? '';
      _bioCtrl.text = profile.bio ?? '';
      _avatarUrl = profile.avatarUrl;
      _initials = profile.initials;
    }
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    HapticFeedback.lightImpact();
    final colors = AppThemeColors.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: colors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.photo_camera_rounded, color: colors.accent),
              title: Text(
                'Take a photo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: colors.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: colors.accent),
              title: Text(
                'Choose from gallery',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: colors.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;
      if (!mounted) return;
      setState(() => _uploadingAvatar = true);

      final bytes = await picked.readAsBytes();
      final url = await ProfileService.instance.uploadAvatar(bytes);
      await ProfileService.instance.updateMine(avatarUrl: url);
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile();
      if (!mounted) return;
      setState(() {
        _avatarUrl = url;
        _uploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.accentGreen, size: 18),
              SizedBox(width: 8),
              Text('Profile photo updated',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
          backgroundColor: AppThemeColors.of(context).bgCard,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not upload photo: ${e.toString()}'),
          backgroundColor: AppThemeColors.of(context).bgCard,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    try {
      await ProfileService.instance.updateMine(
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.accentGreen, size: 18),
              SizedBox(width: 8),
              Text('Profile updated',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
            ],
          ),
          backgroundColor: AppThemeColors.of(context).bgCard,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: ${e.toString()}'),
          backgroundColor: AppThemeColors.of(context).bgCard,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final safeTop = MediaQuery.of(context).padding.top;
    final maxW = Responsive.contentMaxWidth(context);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 16),
            decoration: BoxDecoration(
              color: colors.bgPrimary,
              border: Border(
                bottom:
                    BorderSide(color: colors.borderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: colors.textPrimary, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  'EDIT PROFILE',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: !_loaded
                ? Center(
                    child: CircularProgressIndicator(color: colors.accent))
                : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(24, 28, 24, 40),
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
                                        color: colors.bgElevated,
                                        border: Border.all(
                                            color: colors.accent, width: 2),
                                      ),
                                      child: ClipOval(
                                        child: _uploadingAvatar
                                            ? Center(
                                                child: SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: colors.accent,
                                                    strokeWidth: 2.5,
                                                  ),
                                                ),
                                              )
                                            : (_avatarUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: _avatarUrl!,
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (_, __, ___) =>
                                                            _initialsFallback(
                                                                colors),
                                                  )
                                                : _initialsFallback(colors)),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: GestureDetector(
                                        onTap: _uploadingAvatar
                                            ? null
                                            : _pickAvatar,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.goldGradient,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: colors.bgPrimary,
                                                width: 2),
                                          ),
                                          child: const Icon(
                                              Icons.camera_alt_rounded,
                                              color: AppColors.bgPrimary,
                                              size: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _label(colors, 'Full Name'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameCtrl,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Enter your name'
                                        : null,
                                style: _fieldStyle(colors),
                                decoration: _decoration(colors,
                                    'Your name', Icons.person_rounded),
                              ),
                              const SizedBox(height: 20),
                              _label(colors, 'Email Address'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                enabled: false,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                                style: _fieldStyle(colors).copyWith(
                                    color: colors.textSecondary),
                                decoration: _decoration(colors,
                                    'you@example.com', Icons.email_rounded),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  'Email changes go through verification — coming soon.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _label(colors, 'Bio'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _bioCtrl,
                                maxLines: 3,
                                maxLength: 120,
                                style: _fieldStyle(colors),
                                decoration: _decoration(colors,
                                    'Tell us about yourself',
                                    Icons.edit_note_rounded),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _saving ? null : _save,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: _saving
                                        ? null
                                        : AppColors.goldGradient,
                                    color: _saving ? colors.bgCard : null,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _saving
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: colors.accent
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 20,
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: _saving
                                        ? SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: colors.accent,
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

  Widget _initialsFallback(AppThemeColors colors) => Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 34,
            color: colors.accent,
          ),
        ),
      );

  TextStyle _fieldStyle(AppThemeColors colors) => TextStyle(
      fontFamily: 'Inter', fontSize: 15, color: colors.textPrimary);

  Widget _label(AppThemeColors colors, String text) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: colors.textSecondary,
        ),
      );

  InputDecoration _decoration(
      AppThemeColors colors, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontFamily: 'Inter', fontSize: 15, color: colors.textTertiary),
      prefixIcon: Icon(icon, color: colors.textTertiary, size: 20),
      filled: true,
      fillColor: colors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      counterStyle:
          TextStyle(fontFamily: 'Inter', color: colors.textTertiary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.borderSubtle, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.borderSubtle, width: 0.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.borderSubtle, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.accent, width: 1),
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
