
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Screens/home_screen.dart';
import '../providers/auth_provider.dart';

const String _webClientId = "410065233024-11q30o1pca6ocofi3n4jhd4m6iv46uq9.apps.googleusercontent.com";

final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: _webClientId,
  scopes: ['email', 'profile'],
);

Future<void> signInWithGoogle(BuildContext context, WidgetRef ref) async {
  try {
    await _googleSignIn.signOut();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      _showFriendlyError(context, 'Google services are currently unavailable. Please try login again.');
      return;
    }

    final result = await ref.read(authProvider.notifier).socialLogin(
      idToken: idToken,
      deviceName: 'flutter_app',
    );

    if (!context.mounted) return;

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      await _googleSignIn.signOut();
      _showFriendlyError(context, result['message']);
    }
  } catch (e) {
    if (!context.mounted) return;

    String userMessage = 'Something went wrong. Please check your connection and try again.';
    if (e.toString().contains('NetworkImage') || e.toString().contains('SocketException')) {
      userMessage = 'No internet connection. Please connect to Wi-Fi or mobile data.';
    }

    _showFriendlyError(context, userMessage);
  }
}

void _showFriendlyError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
