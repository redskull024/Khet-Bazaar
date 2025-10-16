import 'package:flutter/material.dart';

// --- PLACEHOLDER: Dependencies ---
// These classes are placeholders to make the example self-contained and runnable.
// In a real app, these would be in their own files.

/// A placeholder for the screen to navigate to after language selection.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Role")),
      body: const Center(
        child: Text("Role Selection Screen"),
      ),
    );
  }
}

/// A placeholder service for managing language settings.
class LanguageService {
  Future<void> saveLanguageSelection(String localeCode) async {
    // In a real app, this would save the language preference to a local
    // storage solution like SharedPreferences or flutter_secure_storage.
    debugPrint("Language selection saved: \$localeCode");
    // Simulate a network/disk write delay.
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// --- DATA STRUCTURE ---

/// Represents a language option in the UI.
class LanguageOption {
  final String primaryName;
  final String secondaryName;
  final String localeCode;

  const LanguageOption({
    required this.primaryName,
    required this.secondaryName,
    required this.localeCode,
  });
}

// --- UI CONTENT WIDGET ---

/// The main interactive content block for the Language Selection Screen.
///
/// This widget is designed to be placed within a larger responsive layout,
/// such as the left column of a Row. It includes the app's branding, a
/// language selection prompt, and a grid of language options.
class LanguageSelectionContent extends StatelessWidget {
  /// Creates the language selection content block.
  const LanguageSelectionContent({super.key});

  // --- Static Data for Languages ---
  static const List<LanguageOption> _languageOptions = [
    LanguageOption(primaryName: 'English', secondaryName: 'English', localeCode: 'en'),
    LanguageOption(primaryName: 'ಕನ್ನಡ', secondaryName: 'Kannada', localeCode: 'kn'),
    LanguageOption(primaryName: 'हिंदी', secondaryName: 'Hindi', localeCode: 'hi'),
    LanguageOption(primaryName: 'తెలుగు', secondaryName: 'Telugu', localeCode: 'te'),
    LanguageOption(primaryName: 'தமிழ்', secondaryName: 'Tamil', localeCode: 'ta'),
    LanguageOption(primaryName: 'मराठी', secondaryName: 'Marathi', localeCode: 'mr'),
    LanguageOption(primaryName: 'മലയാളം', secondaryName: 'Malayalam', localeCode: 'ml'),
    LanguageOption(primaryName: 'ਪੰਜਾਬੀ', secondaryName: 'Punjabi', localeCode: 'pa'),
    LanguageOption(primaryName: 'राजस्थानी', secondaryName: 'Rajasthani', localeCode: 'raj'),
    LanguageOption(primaryName: 'اردو', secondaryName: 'Urdu', localeCode: 'ur'),
  ];

  // --- Colors and Styling ---
  static const Color _primaryTextColor = Color(0xFF1E463E);
  static const Color _buttonColor = Color(0xFFE8F5E9);

  /// Handles the logic for selecting a language and navigating to the next screen.
  ///
  /// This function saves the selected language using [LanguageService] and then
  /// pushes the [RoleSelectionScreen] onto the navigation stack.
  void _selectLanguage(BuildContext context, String localeCode) {
    LanguageService().saveLanguageSelection(localeCode).then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }).catchError((error) {
      // Optional: Handle any errors during the save operation.
      debugPrint("Error saving language: \$error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not save language preference: \$error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Title ---
            const Text(
              "Direct Farm Marketplace",
              style: TextStyle(
                color: _primaryTextColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif', // A serif font can add a touch of elegance
              ),
            ),
            const SizedBox(height: 16),

            // --- Motto ---
            const Text(
              "Connect farmers directly with buyers. Fresh produce, fair prices, sustainable farming.",
              style: TextStyle(
                color: _primaryTextColor,
                fontSize: 18,
                height: 1.5, // Improved line spacing for readability
              ),
            ),
            const SizedBox(height: 48),

            // --- Language Prompt ---
            Row(
              children: const [
                Icon(Icons.language, color: _primaryTextColor, size: 24),
                SizedBox(width: 12),
                Text(
                  "Choose Your Language",
                  style: TextStyle(
                    color: _primaryTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Language Grid ---
            // A Wrap widget is used for a responsive grid that adjusts the number
            // of columns based on the available width.
            Wrap(
              spacing: 16.0, // Horizontal space between buttons
              runSpacing: 16.0, // Vertical space between rows
              children: _languageOptions.map((language) {
                return _buildLanguageButton(context, language);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single language button.
  ///
  /// Each button is a [Card] with a custom shape and color, containing
  /// the language names. It has an [InkWell] for the tap effect.
  Widget _buildLanguageButton(BuildContext context, LanguageOption language) {
    return Card(
      elevation: 2.0,
      color: _buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple is clipped
      child: InkWell(
        key: Key('language_button_${language.localeCode}'),
        onTap: () => _selectLanguage(context, language.localeCode),
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.primaryName,
                style: const TextStyle(
                  color: _primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                language.secondaryName,
                style: TextStyle(
                  color: _primaryTextColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}