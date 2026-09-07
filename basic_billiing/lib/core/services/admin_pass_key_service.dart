import 'package:shared_preferences/shared_preferences.dart';

abstract class IAdminPassKeyService {
  Future<String> getPassKey();
  Future<bool> verifyPassKey(String input);
  Future<bool> setPassKey(String newKey);
  Future<bool> changePassKey({required String oldKey, required String newKey});
  Future<bool> isAdminViewEnabled();
  Future<bool> setAdminViewEnabled(bool enabled);
}

class AdminPassKeyService implements IAdminPassKeyService {
  static const String _key = 'admin_pass_key';
  static const String _adminViewKey = 'admin_view_enabled';
  static const String defaultPassKey = '3046';

  @override
  Future<String> getPassKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? defaultPassKey;
  }

  @override
  Future<bool> verifyPassKey(String input) async {
    final current = await getPassKey();
    return input.trim() == current.trim();
  }

  @override
  Future<bool> setPassKey(String newKey) async {
    if (newKey.trim().isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_key, newKey.trim());
  }

  @override
  Future<bool> changePassKey({
    required String oldKey,
    required String newKey,
  }) async {
    final isCorrect = await verifyPassKey(oldKey);
    if (!isCorrect) return false;
    return await setPassKey(newKey);
  }

  @override
  Future<bool> isAdminViewEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adminViewKey) ?? false;
  }

  @override
  Future<bool> setAdminViewEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_adminViewKey, enabled);
  }
}
