class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "http://10.0.2.2:5000/api";
  // 10.0.2.2 = localhost for Android emulator
  // For real device use your computer IP like: http://192.168.1.x:5000/api

  // Auth
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String getMe = "$baseUrl/auth/me";
}