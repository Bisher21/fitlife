import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/auth-provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // قائمة البريد الإلكتروني المسموحة
  final List<String> _allowedEmailDomains = [
    '@gmail.com',
    '@yahoo.com',
    '@outlook.com',
    '@hotmail.com',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // التحقق من نوع البريد الإلكتروني
  bool _isValidEmailDomain(String email) {
    email = email.toLowerCase().trim();
    return _allowedEmailDomains.any((domain) => email.endsWith(domain));
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم التسجيل بنجاح! تحقق من بريدك الإلكتروني'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // الانتقال للصفحة الرئيسية
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'فشل التسجيل'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0E21),
                  const Color(0xFF1D1E33),
                  Colors.orange.shade900.withOpacity(0.3),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Back Button & Title
                  _buildHeader(),

                  const SizedBox(height: 30),

                  // Register Form
                  _buildRegisterForm(),

                  const SizedBox(height: 20),

                  // Terms & Conditions
                  _buildTermsCheckbox(),

                  const SizedBox(height: 20),

                  // Register Button
                  _buildRegisterButton(),

                  const SizedBox(height: 15),

                  // Divider
                  _buildDivider(),

                  const SizedBox(height: 15),

                  // Social Login
                  _buildSocialLogin(),

                  const SizedBox(height: 20),

                  // Login Link
                  _buildLoginLink(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // Header
  // ============================================
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ],
        ),
        // أيقونة رياضية
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade600,
                Colors.deepOrange.shade700,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade600.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'انضم إلينا',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ابدأ رحلتك نحو جسم أفضل',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  // ============================================
  // Register Form
  // ============================================
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال الاسم';
              }
              if (value.length < 3) {
                return 'الاسم يجب أن يكون 3 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال البريد الإلكتروني';
              }
              if (!value.contains('@')) {
                return 'البريد الإلكتروني غير صحيح';
              }
              // التحقق من نوع البريد
              if (!_isValidEmailDomain(value)) {
                return 'يُسمح فقط بـ Gmail, Yahoo, Outlook أو Hotmail';
              }
              return null;
            },
            helperText: 'يُسمح فقط: Gmail, Yahoo, Outlook, Hotmail',
          ),
          const SizedBox(height: 20),

          // Password Field
          _buildTextField(
            controller: _passwordController,
            label: 'كلمة المرور',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال كلمة المرور';
              }
              if (value.length < 8) {
                return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
              }
              // التحقق من قوة كلمة المرور
              bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
              bool hasLowercase = value.contains(RegExp(r'[a-z]'));
              bool hasDigits = value.contains(RegExp(r'[0-9]'));

              if (!hasUppercase || !hasLowercase || !hasDigits) {
                return 'يجب أن تحتوي على أحرف كبيرة وصغيرة وأرقام';
              }
              return null;
            },
            helperText: 'يجب أن تحتوي على أحرف كبيرة وصغيرة وأرقام',
          ),
          const SizedBox(height: 20),

          // Confirm Password Field
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'تأكيد كلمة المرور',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء تأكيد كلمة المرور';
              }
              if (value != _passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // Text Field مخصص
  // ============================================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        helperText: helperText,
        helperStyle: TextStyle(
          color: Colors.orange.shade400,
          fontSize: 11,
        ),
        prefixIcon: Icon(icon, color: Colors.orange.shade600),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade400,
          ),
          onPressed: onToggleVisibility,
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.orange.shade600,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  // ============================================
  // Terms & Conditions Checkbox
  // ============================================
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: Colors.orange.shade600,
            side: BorderSide(color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'أوافق على ',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: فتح صفحة الشروط والأحكام
                },
                child: Text(
                  'الشروط والأحكام',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' و',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: فتح صفحة سياسة الخصوصية
                },
                child: Text(
                  'سياسة الخصوصية',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // Register Button
  // ============================================
  Widget _buildRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade600,
                Colors.deepOrange.shade700,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade600.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'إنشاء حساب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================
  // Divider
  // ============================================
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade700,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade700,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ============================================
  // Social Login Button
  // ============================================
  Widget _buildSocialLogin() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: ElevatedButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () async {
              // TODO: تطبيق Google Sign-In
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم إضافة التسجيل بجوجل قريباً'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            label: const Text(
              'التسجيل بواسطة Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================
  // Login Link
  // ============================================
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'سجّل دخولك',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}


