import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConstants.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: EcommerceApp(),
    ),
  );
}
