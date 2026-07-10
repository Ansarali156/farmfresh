import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'Customer'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.spa, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'FarmFresh Portal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connecting farms directly with you',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Role Selector Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Select Portal Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Customer', child: Text('Customer Marketplace')),
                  DropdownMenuItem(value: 'Farmer', child: Text('Farmer Dashboard')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRole = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Email Field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password Field
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              
              // Login button
              ElevatedButton(
                onPressed: () {
                  if (_selectedRole == 'Farmer') {
                    context.go('/farmer-main');
                  } else {
                    context.go('/customer-main');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Login as $_selectedRole', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              
              // Switch to Sign Up
              TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                child: const Text('Don\'t have an account? Sign Up', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
