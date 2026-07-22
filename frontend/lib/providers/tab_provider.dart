import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the selected tab index in CustomerMainScreen.
/// This allows child screens (e.g. CartScreen) to switch tabs programmatically.
final customerTabIndexProvider = StateProvider<int>((ref) => 0);
final mainTabProvider = customerTabIndexProvider;
