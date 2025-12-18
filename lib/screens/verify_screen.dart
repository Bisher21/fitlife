import 'package:flutter/material.dart';
import '../services/api-service.dart';
import '../services/storage-service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../Model/user_model.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String? userEmail;


  bool _isInitialLoading = true;
  bool _isCheckingVerification = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndCheckVerification();
  }

  Future<void> _loadUserAndCheckVerification() async {
    setState(() => _isInitialLoading = true);

    try {
      final localUserMap = await SharedPreferencesHelper.getUser();

      if (localUserMap != null) {
        final localUser = UserResponseModel.fromJson(localUserMap);

        if (localUser.isVerified) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }
        setState(() => userEmail = localUser.email);
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  Future<void> _refreshStatus() async {
    if (_isCheckingVerification) return;

    setState(() => _isCheckingVerification = true);

    try {
      final result = await ApiService.getAuthenticatedUser();

      if (!mounted) return;
      setState(() => _isCheckingVerification = false);

      if (result['success']) {
        final user = UserResponseModel.fromJson(result['user']);

        if (user.isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {

          _showSnackBar('Not verified yet, please check your email', Colors.orange);
        }
      } else {

        if (result['isNotVerified'] == true) {
          _showSnackBar('Not verified yet, please check your email', Colors.orange);
        } else {
          _showSnackBar(result['message'], Colors.red);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingVerification = false);
      _showSnackBar('Connection error occurred', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1F2933),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 50),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Email Icon
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.mark_email_unread_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),


        const Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),


        const Text(
          'We sent a verification link to:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // User Email
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Text(
            userEmail ?? 'Unknown email',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),


        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Click the link in your email to verify your account',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isCheckingVerification ? null : _refreshStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _isCheckingVerification
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFF48C64),
                strokeWidth: 2.5,
              ),
            )
                : const Text(
              'I\'ve Verified - Continue',
              style: TextStyle(
                color: Color(0xFFF48C64),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Resend Email Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: _isResending
                ? null
                : () async {
              setState(() => _isResending = true);
              try {
                final res = await ApiService.resendVerification();
                if (!mounted) return;
                _showSnackBar(
                  res['message'] ?? 'Email sent',
                  res['success'] ? Colors.green : Colors.red,
                );
              } catch (e) {
                _showSnackBar('An error occurred', Colors.red);
              } finally {
                if (mounted) setState(() => _isResending = false);
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isResending
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Text(
              'Resend Verification Email',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Logout Button
        TextButton(
          onPressed: () async {
            await ApiService.logout();
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}