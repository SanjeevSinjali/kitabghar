import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/features/purchases/data/models/purchase_model.dart';

class PurchaseRemoteDataSource {
  final ApiClient _apiClient;

  PurchaseRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<PurchaseModel>> getPurchases({required String token}) async {
    final response = await _apiClient.get(ApiEndpoints.purchases, token: token);
    final List data = response['data'];
    return data.map((e) => PurchaseModel.fromJson(e)).toList();
  }

  Future<PurchaseModel> buyBook({
    required String token,
    required PurchaseModel item,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.purchases,
      token: token,
      body: item.toBody(),
    );
    return PurchaseModel.fromJson(response['data']);
  }

  /// Returns the raw {pidx, paymentUrl} map from the backend.
  Future<Map<String, dynamic>> initiateKhaltiPayment({
    required String token,
    required PurchaseModel item,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.khaltiInitiate,
      token: token,
      body: item.toBody(),
    );
    return response['data'];
  }

  Future<PurchaseModel> verifyKhaltiPayment({
    required String token,
    required String pidx,
    required PurchaseModel item,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.khaltiVerify,
      token: token,
      body: {
        'pidx': pidx,
        ...item.toBody(),
      },
    );
    return PurchaseModel.fromJson(response['data']);
  }
}