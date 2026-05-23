import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final bool isPremium;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.bio,
    this.avatarUrl,
    this.isPremium = false,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        name: j['name'] as String?,
        email: j['email'] as String?,
        bio: j['bio'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        isPremium: (j['is_premium'] ?? false) as bool,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );

  String get initials {
    final n = (name ?? email ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'[\s@.]+')).where((s) => s.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();
  SupabaseClient get _sb => Supabase.instance.client;

  Future<UserProfile?> getMine() async {
    final user = _sb.auth.currentUser;
    if (user == null) return null;
    final row = await _sb
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return UserProfile.fromJson(row);
  }

  Future<UserProfile> updateMine({
    String? name,
    String? bio,
    String? email,
    String? avatarUrl,
  }) async {
    final user = _sb.auth.currentUser!;
    final patch = <String, dynamic>{
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    final row = await _sb
        .from('profiles')
        .update(patch)
        .eq('id', user.id)
        .select()
        .single();
    return UserProfile.fromJson(row);
  }

  /// Upload an avatar (raw bytes) and return its public URL.
  Future<String> uploadAvatar(Uint8List bytes,
      {String contentType = 'image/jpeg'}) async {
    final user = _sb.auth.currentUser!;
    final path = '${user.id}/avatar.jpg';
    await _sb.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );
    final url = _sb.storage.from('avatars').getPublicUrl(path);
    // Cache-bust so the new image shows immediately.
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> uploadAvatarFile(File file) async =>
      uploadAvatar(await file.readAsBytes());
}
