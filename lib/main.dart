import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/auth-provider.dart';
import 'Screens/HomeScreen.dart';
import 'Screens/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // هنا نضيف AuthProvider ليكون متاح في كل التطبيق
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // يمكنك إضافة Providers أخرى هنا في المستقبل
      ],
      child: MaterialApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,

        // الثيم العام للتطبيق
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo', // إذا أردت خط عربي
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        // الصفحة الأولى (Splash Screen)
        home: const SplashScreen(),

        // Routes - المسارات بين الصفحات
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}



