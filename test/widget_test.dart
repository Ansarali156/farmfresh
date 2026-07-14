import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/models/user_model.dart';

void main() {
  group('UserModel Unit Tests', () {
    test('should successfully parse user model from JSON map', () {
      final json = {
        'id': 'user-abc-123',
        'name': 'Ramesh Kumar',
        'email': 'ramesh@farmfresh.com',
        'role': 'FARMER',
        'phone': '9876543210',
        'createdAt': '2026-07-14T07:13:06.527Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-abc-123');
      expect(user.name, 'Ramesh Kumar');
      expect(user.email, 'ramesh@farmfresh.com');
      expect(user.role, 'FARMER');
      expect(user.phone, '9876543210');
    });

    test('should correctly serialize user model back to JSON map', () {
      final user = UserModel(
        id: 'user-abc-123',
        name: 'Ramesh Kumar',
        email: 'ramesh@farmfresh.com',
        role: 'FARMER',
        phone: '9876543210',
      );

      final json = user.toJson();

      expect(json['id'], 'user-abc-123');
      expect(json['name'], 'Ramesh Kumar');
      expect(json['email'], 'ramesh@farmfresh.com');
      expect(json['role'], 'FARMER');
      expect(json['phone'], '9876543210');
    });
  });
}
