import 'package:dio/dio.dart';
import '../models/address_model.dart';
import '../core/services/api_client.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);
}

class PostgresAddressRepository implements AddressRepository {
  final ApiClient _apiClient;

  PostgresAddressRepository(this._apiClient);

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final res = await _apiClient.dio.get('/addresses');

      if (res.statusCode == 200 &&
          res.data['success'] == true &&
          res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final res = await _apiClient.dio.post('/addresses', data: address.toJson());

      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return AddressModel.fromJson(res.data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to add address');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ??
          e.message ??
          'Failed to add address');
    }
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final res = await _apiClient.dio.patch('/addresses/${address.id}', data: address.toJson());

      if (res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return AddressModel.fromJson(res.data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to update address');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ??
          e.message ??
          'Failed to update address');
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      final res = await _apiClient.dio.delete('/addresses/$addressId');

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception((res.data is Map ? res.data['message'] : null) ?? 'Failed to delete address');
      }
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ??
          e.message ??
          'Failed to delete address');
    }
  }
}
