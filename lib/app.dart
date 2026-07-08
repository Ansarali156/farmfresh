// The core application widget that configures themes and declarative routing.
import 'package:flutter/material.dart';
import 'package:ecommerce_app/routes/app_router.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router is used to support GoRouter for navigation.
    return MaterialApp.router(
      title: 'E-Commerce App',
      
      // Apply the centralized Light Theme
      theme: AppTheme.lightTheme,
      
      // Apply the centralized Dark Theme
      darkTheme: AppTheme.darkTheme,
      
      // Automatically switch between light and dark themes based on system preferences
      themeMode: ThemeMode.system,
      
      // Connect GoRouter configuration to the app
      routerConfig: appRouter,
      
      // Hide the debug banner in the top right corner
      debugShowCheckedModeBanner: false,
    );
  }
}
