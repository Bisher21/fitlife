class ApiConstants {

  static const String baseUrl = 'https://fitlife-app-theta.vercel.app';

  // Auth Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String socialLogin = '/social-login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String resendVerification = '/email/verification-notification';

  // Headers
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}