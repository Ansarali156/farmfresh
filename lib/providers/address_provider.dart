import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_model.dart';
import 'app_providers.dart';

class AddressState {
  final List<AddressModel> addresses;
  final bool isLoading;
  final String? errorMessage;

  AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AddressState copyWith({
    List<AddressModel>? addresses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  AddressModel? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull ??
      (addresses.isNotEmpty ? addresses.first : null);
}

class AddressNotifier extends StateNotifier<AddressState> {
  final Ref _ref;

  AddressNotifier(this._ref) : super(AddressState()) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _ref.read(addressRepositoryProvider).getAddresses();
      state = AddressState(addresses: list);
    } catch (e) {
      state = AddressState(errorMessage: e.toString());
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final created =
          await _ref.read(addressRepositoryProvider).addAddress(address);
      state = state.copyWith(
        addresses: [...state.addresses, created],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateAddress(String addressId, AddressModel address) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated =
          await _ref.read(addressRepositoryProvider).updateAddress(address);
      final newList = state.addresses
          .map((a) => a.id == addressId ? updated : a)
          .toList();
      state = state.copyWith(addresses: newList, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(addressRepositoryProvider).deleteAddress(addressId);
      state = state.copyWith(
        addresses: state.addresses.where((a) => a.id != addressId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> setDefault(String addressId) async {
    final updatedList = state.addresses
        .map((a) => a.copyWith(isDefault: a.id == addressId))
        .toList();
    state = state.copyWith(addresses: updatedList);

    final target = state.addresses.firstWhere((a) => a.id == addressId);
    return updateAddress(addressId, target.copyWith(isDefault: true));
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier(ref);
});
