class ApiConstants {

  static const String baseUrl = 'https://fitlife-app-theta.vercel.app/v1';

  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String getUser = '$baseUrl/user';
  static const String resendVerification = '$baseUrl/email/verification-notification';
  static const String socialLogin = '$baseUrl/social-login';

  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}