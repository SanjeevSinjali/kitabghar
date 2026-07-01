class ApiEndpoints {
  ApiEndpoints._();

  // static const String baseUrl = "http://10.0.2.2:5000/api";
  // static const String baseUrl = "http://172.20.10.2:5000/api";
  // 10.0.2.2 = localhost for Android emulator
  static const String baseUrl = "http://192.168.18.125:5000/api";

  // Auth
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String getMe = "$baseUrl/auth/me";

  // Books
  static const String books = "$baseUrl/books";
}
