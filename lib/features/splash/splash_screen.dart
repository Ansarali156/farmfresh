import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // 1. Establish a minimum visual delay of 2 seconds for branding exposure
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 2. Fetch current auth state
    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user != null) {
      final role = user.role.toUpperCase();
      if (role == 'FARMER') {
        context.go('/farmer-main');
      } else if (role == 'DELIVERY_PARTNER') {
        context.go('/delivery-main');
      } else {
        context.go('/customer-main');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'FarmFresh',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
