import 'package:bproject/Screens/verify_screen.dart';
import 'package:bproject/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Name is required';
      } else if (value.length < 3) {
        _nameError = 'Name must be at least 3 characters';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
        _passwordError = 'Password must contain at least one uppercase letter';
      } else if (!RegExp(r'[a-z]').hasMatch(value)) {
        _passwordError = 'Password must contain at least one lowercase letter';
      } else if (!RegExp(r'[0-9]').hasMatch(value)) {
        _passwordError = 'Password must contain at least one number';
      } else {
        _passwordError = null;
      }

      if (_passwordConfirmationController.text.isNotEmpty) {
        _validateConfirmPassword(_passwordConfirmationController.text);
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isFormValid() {
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordConfirmationController.text.isNotEmpty;
  }

  Future<void> _register() async {
    _validateName(_nameController.text.trim());
    _validateEmail(_emailController.text.trim());
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_passwordConfirmationController.text);

    if (!_isFormValid()) return;

    final result = await ref.read(authProvider.notifier).register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
      deviceName: 'flutter_app',
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerificationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2933),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF48C64),
              Color(0xFF1F2933),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'To get started!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 40),

                      _inputField(
                        controller: _nameController,
                        hint: 'Full Name',
                        errorText: _nameError,
                        onChanged: _validateName,
                      ),
                      const SizedBox(height: 16),

                      _inputField(
                        controller: _emailController,
                        hint: 'Email',
                        errorText: _emailError,
                        onChanged: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      _passwordField(
                        controller: _passwordController,
                        hint: 'Password',
                        obscure: _obscurePassword,
                        errorText: _passwordError,
                        toggle: (v) => setState(() => _obscurePassword = v),
                        onChanged: _validatePassword,
                      ),
                      const SizedBox(height: 16),

                      _passwordField(
                        controller: _passwordConfirmationController,
                        hint: 'Confirm Password',
                        obscure: _obscurePasswordConfirmation,
                        errorText: _confirmPasswordError,
                        toggle: (v) =>
                            setState(() => _obscurePasswordConfirmation = v),
                        onChanged: _validateConfirmPassword,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                            'Register',
                            style: TextStyle(
                              color: Color(0xFFF48C64),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already have account? ',
                              style: TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? errorText,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: _outlineDecoration(hint, errorText != null),
          onChanged: onChanged,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    String? errorText,
    required Function(bool) toggle,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: _outlineDecoration(hint, errorText != null).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => toggle(!obscure),
            ),
          ),
          onChanged: onChanged,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration _outlineDecoration(String hint, bool hasError) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : Colors.white54,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : Colors.white,
        ),
      ),
    );
  }
}