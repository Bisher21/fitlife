import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/auth-provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // التحقق من حالة تسجيل الدخول
  Future<void> _checkAuthStatus() async {
    // الانتظار قليلاً لعرض الشاشة
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // جلب AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // التحقق من حالة المصادقة
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // التوجيه حسب الحالة
    if (authProvider.isAuthenticated) {
      // المستخدم مسجل دخول → الصفحة الرئيسية
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // المستخدم غير مسجل → صفحة تسجيل الدخول
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // يمكنك وضع اللوجو هنا
            Icon(
              Icons.flutter_dash,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'My App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}