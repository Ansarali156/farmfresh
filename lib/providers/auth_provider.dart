import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'app_providers.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  Future<bool> login(String email, String password, String role) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).login(email, password, role);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String role, String phone) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).signup(name, email, password, role, phone);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> switchRole(String newRole) async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(role: newRole);
      state = AuthState(user: updatedUser);
    }
  }

  Future<bool> updateProfile({String? name, String? phone}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final updated = await _ref
          .read(authRepositoryProvider)
          .updateProfile(name: name, phone: phone);
      state = AuthState(user: updated, successMessage: 'Profile updated successfully');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(
      {required String currentPassword, required String newPassword}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      state = state.copyWith(isLoading: false, successMessage: 'Password changed successfully');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(authRepositoryProvider).logout();
      state = AuthState();
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
