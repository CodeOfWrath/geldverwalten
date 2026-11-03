import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<void> setGuestMode(bool isGuest, {String? pseudo});
  Future<bool> isGuest();
  Future<void> setHasSeenOnboarding(bool value);
  Future<bool> hasSeenOnboarding();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String CACHED_USER_KEY = 'CACHED_USER_KEY';
  static const String GUEST_MODE_KEY = 'GUEST_MODE_KEY';
  static const String HAS_SEEN_ONBOARDING_KEY = 'HAS_SEEN_ONBOARDING_KEY';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(CACHED_USER_KEY, jsonEncode(user.toJson()));
    await sharedPreferences.setBool(GUEST_MODE_KEY, user.isGuest);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(CACHED_USER_KEY);
    if (jsonString != null) {
      return UserModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(CACHED_USER_KEY);
    await sharedPreferences.remove(GUEST_MODE_KEY);
  }

  @override
  Future<void> setGuestMode(bool isGuest, {String? pseudo}) async {
    await sharedPreferences.setBool(GUEST_MODE_KEY, isGuest);
    final String chosenPseudo = (pseudo != null && pseudo.trim().isNotEmpty)
        ? pseudo.trim()
        : 'Visiteur';

    final guestUser = UserModel.fromJson({
      'id': 0,
      'nom': 'Invité',
      'prenom': 'Utilisateur',
      'pseudo': chosenPseudo,
      'email': 'mode.visiteur@depensia.cm',
      'token': '',
      'isGuest': isGuest,
    });
    await cacheUser(guestUser);
  }

  @override
  Future<bool> isGuest() async {
    return sharedPreferences.getBool(GUEST_MODE_KEY) ?? true;
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    await sharedPreferences.setBool(HAS_SEEN_ONBOARDING_KEY, value);
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    return sharedPreferences.getBool(HAS_SEEN_ONBOARDING_KEY) ?? false;
  }
}
