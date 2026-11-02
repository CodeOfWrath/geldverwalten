import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<void> setGuestMode(bool isGuest);
  Future<bool> isGuest();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String CACHED_USER_KEY = 'CACHED_USER_KEY';
  static const String GUEST_MODE_KEY = 'GUEST_MODE_KEY';

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
  Future<void> setGuestMode(bool isGuest) async {
    await sharedPreferences.setBool(GUEST_MODE_KEY, isGuest);
    if (isGuest) {
      final guestUser = UserModel.fromJson({
        'id': 0,
        'nom': 'Invité',
        'prenom': 'Utilisateur',
        'pseudo': 'Micaelle',
        'email': 'invite@depensia.cm',
        'token': '',
        'isGuest': true,
      });
      await cacheUser(guestUser);
    }
  }

  @override
  Future<bool> isGuest() async {
    return sharedPreferences.getBool(GUEST_MODE_KEY) ?? true;
  }
}
