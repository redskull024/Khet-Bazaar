import 'package:shared_preferences/shared_preferences.dart';

/// A service class for handling authentication-related tasks,
/// including temporarily persisting user role selection.
class AuthService {
  static const String _tempRoleKey = 'tempSelectedRole';

  /// Saves the selected role temporarily to local storage.
  ///
  /// This is used to hold the role choice before the user completes
  /// the full authentication or registration process.
  ///
  /// [role] The role string to save (e.g., 'farmer', 'buyer').
  Future<void> saveTemporaryRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tempRoleKey, role);
  }
}