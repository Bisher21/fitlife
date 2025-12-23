import 'package:bproject/Screens/verify_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final result = await ref.read(authProvider.notifier).refreshUser();

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.user != null && !authState.isVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerificationScreen()),
      );
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final authState = ref.watch(authProvider);
    final userData = authState.user?.toJson();

    if (authState.isLoading || userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFF7F9FC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                _buildAppBar(primaryColor),
                const SizedBox(height: 20),
                _buildWelcomeCard(primaryColor, userData),
                const SizedBox(height: 20),
                _buildInfoCard(primaryColor, userData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'الرئيسية',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: primaryColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(Color primaryColor, Map<String, dynamic> userData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userData['name'] ?? 'مستخدم',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ready to star? ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Color primaryColor, Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: userData['email'] ?? '-',
            primaryColor: primaryColor,
          ),
          const Divider(height: 30),
          _infoRow(
            icon: Icons.verified_user_outlined,
            title: 'Account State',
            value: userData['email_verified_at'] != null
                ? 'Vrified'
                : 'Not verified',
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryColor,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}