import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/features/wishlist/data/models/wishlist_model.dart';

class WishlistRemoteDataSource {
  final ApiClient _apiClient;

  WishlistRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<WishlistModel>> getWishlist({required String token}) async {
    final response = await _apiClient.get(ApiEndpoints.wishlist, token: token);
    final List data = response['data'];
    return data.map((e) => WishlistModel.fromJson(e)).toList();
  }

  /// Returns true if the book was just added, false if it was just removed.
  Future<bool> toggle({
    required String token,
    required WishlistModel item,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.wishlistToggle,
      token: token,
      body: item.toBody(),
    );
    return response['data']['wishlisted'] as bool;
  }

  Future<bool> remove({
    required String token,
    required String bookId,
  }) async {
    await _apiClient.delete(
      '${ApiEndpoints.wishlist}/$bookId',
      token: token,
    );
    return true;
  }
}