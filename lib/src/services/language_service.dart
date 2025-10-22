import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selectedLanguage';

  Future<void> saveLanguageSelection(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, localeCode);
  }

  Future<String?> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }
}