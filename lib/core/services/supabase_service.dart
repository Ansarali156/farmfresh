// This file provides centralized access to the Supabase client instance across the application.
// No authentication or business logic is implemented here.
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Private constructor to prevent instantiation
  SupabaseService._();

  // Provides a global getter for the initialized Supabase client.
  // This allows repositories to easily access the database and storage services.
  static SupabaseClient get client => Supabase.instance.client;
}
