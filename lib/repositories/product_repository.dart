import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../core/services/api_client.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({String? search, String? category, String? sortBy});
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getPopularProducts();
  Future<List<String>> getCategories();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> getFarmerProducts({int page = 1, int limit = 20, String? search, String? status});
  Future<String> uploadProductImage(String productId, String filePath);
}

class PostgresProductRepository implements ProductRepository {
  final ApiClient _apiClient;

  PostgresProductRepository(this._apiClient);

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final res = await _apiClient.dio.get('/products/featured');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (e) {
      // Error in getFeaturedProducts handled silently
    }
    return [];
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    try {
      final res = await _apiClient.dio.get('/products/popular');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (e) {
      // Error in getPopularProducts handled silently
    }
    return [];
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final res = await _apiClient.dio.get('/categories');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return ['All', ...list.map((item) => item['name'] as String)];
      }
    } catch (e) {
      // Error in getCategories handled silently
    }
    return ['All', 'Vegetables', 'Fruits', 'Dairy', 'Grains'];
  }

  @override
  Future<List<ProductModel>> getProducts({String? search, String? category, String? sortBy}) async {
    try {
      final query = <String, String>{};
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (category != null && category != 'All') query['category'] = category;
      if (sortBy != null) query['sortBy'] = sortBy;

      final res = await _apiClient.dio.get('/products', queryParameters: query);

      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (e) {
      // Error in getProducts handled silently
    }
    return [];
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final res = await _apiClient.dio.post('/products', data: product.toCreatePayload());
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return ProductModel.fromBackendJson(res.data['data']);
        }
      }
      throw Exception('Failed to add product');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to add product');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final res = await _apiClient.dio.patch('/products/${product.id}', data: product.toCreatePayload());
      if (res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return ProductModel.fromBackendJson(res.data['data']);
        }
      }
      throw Exception('Failed to update product');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final res = await _apiClient.dio.delete('/products/$id');
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to delete product');
    }
  }

  @override
  Future<List<ProductModel>> getFarmerProducts({int page = 1, int limit = 20, String? search, String? status}) async {
    try {
      final query = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (status != null) query['status'] = status;

      final res = await _apiClient.dio.get('/farmer/products', queryParameters: query);
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<String> uploadProductImage(String productId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final res = await _apiClient.dio.post('/products/$productId/images', data: formData);
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          final images = res.data['data']['images'] as List?;
          if (images != null && images.isNotEmpty) {
            return images[0]['imageUrl'] as String;
          }
        }
      }
      throw Exception('Failed to upload image');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to upload image');
    }
  }
}
