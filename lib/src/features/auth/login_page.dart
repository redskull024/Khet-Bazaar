import 'package:farm_connect/src/features/dashboard/buyer_dashboard_screen.dart';
import 'package:farm_connect/src/features/dashboard/farmer_dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_connect/src/features/auth/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart'; // Import go_router

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // State
  bool _isSignIn = true;
  bool _isLoading = false;
  String? _selectedRole;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _agreedToTerms = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final role = await _authService.getTemporaryRole();
    if (mounted) {
      setState(() {
        _selectedRole = role;
      });
    }
  }

  // UPDATED: Uses go_router for navigation
  void _handleAuthSuccess(Map<String, String?>? userPrefs) {
    if (!mounted) return;
    final role = userPrefs?['role'];
    if (role == 'farmer') {
      context.go('/farmer-dashboard');
    } else {
      context.go('/buyer-dashboard');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _onGoogleSignIn() async {
    if (_selectedRole == null) {
      _showError('Please select a role first.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userPrefs = await _authService.signInWithGoogle(_selectedRole!);
      if (!mounted) return;
      _handleAuthSuccess(userPrefs);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Google Sign-In Failed: $e');
      }
    }
  }

  Future<void> _onPhoneSignIn() async {
    if (_selectedRole == null) {
      _showError('Please select a role first.');
      return;
    }
    final phoneNumber = _phoneController.text;
    if (phoneNumber.isEmpty) {
      _showError('Please enter a phone number in the form to use this method.');
      return;
    }

    setState(() => _isLoading = true);

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          final user = userCredential.user;
          if (user != null) {
            final userPrefs = await _authService.getUserPreferences(user.uid);
            _handleAuthSuccess(userPrefs ?? {'role': _selectedRole});
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showError('Auto-verification failed: $e');
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Phone verification failed: ${e.message}');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSmsCodeDialog(verificationId, phoneNumber);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _showSmsCodeDialog(String verificationId, String phoneNumber) {
    String smsCode = '';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter SMS Code'),
          content: TextField(onChanged: (value) => smsCode = value, keyboardType: TextInputType.number, autofocus: true),
          actions: [
            TextButton(
              onPressed: () async {
                if (smsCode.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  setState(() => _isLoading = true);
                  try {
                    final userPrefs = await _authService.signInWithSmsCode(verificationId, smsCode, _selectedRole!, phoneNumber);
                    _handleAuthSuccess(userPrefs);
                  } catch (e) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      _showError('Failed to sign in: $e');
                    }
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onEmailSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isSignIn && !_agreedToTerms) {
      _showError('You must agree to the terms and conditions.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      Map<String, String?>? userPrefs;
      if (_isSignIn) {
        userPrefs = await _authService.signInWithEmail(_emailController.text, _passwordController.text);
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception('Passwords do not match');
        }
        userPrefs = await _authService.signUpWithEmail({
          'email': _emailController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'phoneNumber': _phoneController.text,
          'role': _selectedRole,
        });
      }
      if (!mounted) return;
      _handleAuthSuccess(userPrefs);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Operation Failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.leaf, color: Color(0xFF1E463E), size: 40),
                const SizedBox(height: 20),
                Text(
                  'Welcome ${_selectedRole ?? ''}'.toUpperCase(),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E463E)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your account or create a new one',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                _buildExternalAuthButtons(),
                const SizedBox(height: 30),
                const Text('OR CONTINUE WITH EMAIL', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                _buildAuthToggle(),
                const SizedBox(height: 20),
                Form(key: _formKey, child: _isSignIn ? _buildSignInForm() : _buildSignUpForm()),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _onEmailSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSignIn ? const Color(0xFF1E463E) : Colors.lightGreen,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_isSignIn ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExternalAuthButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _onGoogleSignIn,
            icon: const FaIcon(FontAwesomeIcons.google, size: 16),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _onPhoneSignIn,
            icon: const FaIcon(FontAwesomeIcons.mobileAlt, size: 16),
            label: const Text('Continue with Mobile'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _buildToggleButton('Sign In', _isSignIn),
          ),
          Expanded(
            child: _buildToggleButton('Sign Up', !_isSignIn),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSignIn = text == 'Sign In';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E463E) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Username, Email, or Phone'),
          validator: (v) => v!.isEmpty ? 'Field is required' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: _buildToggleIcon('password'),
          ),
          validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Username'), validator: (v) => v!.isEmpty ? 'Username is required' : null),
        const SizedBox(height: 10),
        TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Email is required' : null),
        const SizedBox(height: 10),
        TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
        const SizedBox(height: 10),
        TextFormField(controller: _passwordController, obscureText: !_passwordVisible, decoration: InputDecoration(labelText: 'Password', suffixIcon: _buildToggleIcon('password')), validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null),
        const SizedBox(height: 10),
        TextFormField(controller: _confirmPasswordController, obscureText: !_confirmPasswordVisible, decoration: InputDecoration(labelText: 'Confirm Password', suffixIcon: _buildToggleIcon('confirm')), validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
        CheckboxListTile(
          value: _agreedToTerms,
          onChanged: (val) => setState(() => _agreedToTerms = val!),
          title: const Text('I agree to the Terms and Conditions'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  IconButton _buildToggleIcon(String field) {
    bool isVisible = field == 'password' ? _passwordVisible : _confirmPasswordVisible;
    return IconButton(
      icon: FaIcon(isVisible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, size: 18),
      onPressed: () {
        setState(() {
          if (field == 'password') _passwordVisible = !_passwordVisible;
          if (field == 'confirm') _confirmPasswordVisible = !_confirmPasswordVisible;
        });
      },
    );
  }
}