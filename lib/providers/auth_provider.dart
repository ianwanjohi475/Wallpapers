import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

/// Top-level auth state for the app.
///
/// Three possible modes:
///   - signed-in:  user has a session
///   - guest:      user explicitly continued without an account
///   - none:       no decision yet -> show login/onboarding
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  static const _kGuestKey = 'is_guest_mode';

  final AuthService _auth = AuthService.instance;
  StreamSubscription<AuthState>? _sub;

  bool _guest = false;
  UserProfile? _profile;
  bool _bootstrapping = true;

  bool get isSignedIn => _auth.isSignedIn;
  bool get isGuest => _guest && !isSignedIn;
  bool get hasDecided => isSignedIn || _guest;
  bool get bootstrapping => _bootstrapping;
  User? get user => _auth.currentUser;
  UserProfile? get profile => _profile;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _guest = prefs.getBool(_kGuestKey) ?? false;
    if (isSignedIn) {
      _profile = await ProfileService.instance.getMine();
    }
    _bootstrapping = false;
    notifyListeners();

    _sub = _auth.onAuthStateChange.listen((state) async {
      if (state.event == AuthChangeEvent.signedIn) {
        _guest = false;
        await prefs.setBool(_kGuestKey, false);
        _profile = await ProfileService.instance.getMine();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _profile = null;
      } else if (state.event == AuthChangeEvent.userUpdated) {
        _profile = await ProfileService.instance.getMine();
      }
      notifyListeners();
    });
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    _guest = true;
    await prefs.setBool(_kGuestKey, true);
    notifyListeners();
  }

  Future<void> exitGuest() async {
    final prefs = await SharedPreferences.getInstance();
    _guest = false;
    await prefs.setBool(_kGuestKey, false);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await exitGuest();
  }

  Future<void> refreshProfile() async {
    if (!isSignedIn) return;
    _profile = await ProfileService.instance.getMine();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
