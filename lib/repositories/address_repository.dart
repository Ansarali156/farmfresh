import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';
import '../core/constants/app_constants.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);
}

class PostgresAddressRepository implements AddressRepository {
  final Dio _dio;

  PostgresAddressRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final res = await _dio.get('/addresses', options: await _authOptions());

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
      final res = await _dio.post('/addresses',
          data: address.toJson(), options: await _authOptions());

      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return AddressModel.fromJson(
              res.data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to add address');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to add address');
    }
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final res = await _dio.patch('/addresses/${address.id}',
          data: address.toJson(), options: await _authOptions());

      if (res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return AddressModel.fromJson(
              res.data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to update address');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to update address');
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      final res = await _dio.delete('/addresses/$addressId',
          options: await _authOptions());

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception(
            res.data['message'] ?? 'Failed to delete address');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to delete address');
    }
  }
}
