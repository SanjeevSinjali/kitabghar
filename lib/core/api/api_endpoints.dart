class ApiEndpoints {
  ApiEndpoints._();

  // Replace with your computer's current LAN IP.
  static const String baseUrl = "http://192.168.18.119:5000/api/v1";

  /// Host without the /api/v1 suffix — used to build URLs for uploaded
  /// files served from the backend's static folders (/avatars, /books).
  static String get baseHost => baseUrl.replaceAll('/api/v1', '');

  static String bookImageUrl(String? image) {
    if (image == null || image.isEmpty) return '';
    return '$baseHost$image';
  }

  static String avatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty) return '';
    return '$baseHost$avatar';
  }

  // Auth
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String whoami = "$baseUrl/auth/whoami";
  static const String updateProfile = "$baseUrl/auth/update";

  // Books
  static const String books = "$baseUrl/books";
  static const String myBooks = "$baseUrl/books/mine";
  static const String featuredBooks = "$baseUrl/books/featured";
  static const String searchBooks = "$baseUrl/books/search";

  // Wishlist
  static const String wishlist = "$baseUrl/wishlist";
  static const String wishlistToggle = "$baseUrl/wishlist/toggle";

  // Purchases
  static const String purchases = "$baseUrl/purchases";
  static const String khaltiInitiate = "$baseUrl/purchases/khalti/initiate";
  static const String khaltiVerify = "$baseUrl/purchases/khalti/verify";
}