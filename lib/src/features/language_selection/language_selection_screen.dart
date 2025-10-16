import 'package:flutter/material.dart';
import 'package:farm_connect/src/features/language_selection/language_service.dart';
import 'package:go_router/go_router.dart';

/// Represents a language option with its name and code.
class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

/// A screen that allows users to select their preferred language.
///
/// This screen displays a list of languages and saves the user's selection
/// locally and to Firestore before navigating to the next screen.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LanguageService _languageService = LanguageService();
  bool _isSaving = false;

  // List of available languages
  final List<Language> languages = const [
    Language('Kannada', 'kn'),
    Language('English', 'en'),
    Language('Hindi', 'hi'),
    Language('Telugu', 'te'),
    Language('Tamil', 'ta'),
    Language('Marathi', 'mr'),
    Language('Malayalam', 'ml'),
    Language('Punjabi', 'pa'),
    Language('Rajasthani', 'raj'),
    Language('Urdu', 'ur'),
  ];

  /// Handles the language selection, saves it, and navigates to the next screen.
  void _onLanguageSelected(String localeCode) async {
    if (_isSaving) return; // Prevent multiple taps

    setState(() {
      _isSaving = true;
    });

    try {
      await _languageService.saveLanguageSelection(localeCode);

      if (mounted) {
        // Navigate to the role selection screen as requested.
        context.go('/role-selection');
      }
    } catch (e) {
      // Handle potential errors, e.g., show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save language: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Row(
            children: [
              // Left side: Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'FarmConnect',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connect Farmers Directly to Markets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Please select your language',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Language buttons grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: languages.length,
                          itemBuilder: (context, index) {
                            final lang = languages[index];
                            return OutlinedButton(
                              onPressed: () => _onLanguageSelected(lang.code),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                lang.name,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side: Image
              if (MediaQuery.of(context).size.width > 800) // Only show image on larger screens
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://static.wixstatic.com/media/9181a6_5f418640fb684af88c1e00e237839199~mv2.png/v1/fill/w_563,h_704,al_c,q_90,enc_auto/9181a6_5f418640fb684af88c1e00e237839199~mv2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Loading indicator
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}