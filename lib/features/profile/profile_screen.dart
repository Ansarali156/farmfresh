import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            _buildProfileMenu(context),
            const SizedBox(height: 24),
            _buildLogoutButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green[100],
              child: Text(
                (user.name.isNotEmpty ? user.name[0] : 'U').toUpperCase(),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            if (user.phone != null && user.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.phone!,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                user.role,
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _menuTile(
            context,
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your name, phone number',
            onTap: () => context.push('/edit-profile'),
          ),
          const Divider(height: 1),
          _menuTile(
            context,
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => context.push('/change-password'),
          ),
          const Divider(height: 1),
          _menuTile(
            context,
            icon: Icons.location_on,
            title: 'Delivery Addresses',
            subtitle: 'Manage your addresses',
            onTap: () => context.push('/addresses'),
          ),
          const Divider(height: 1),
          _menuTile(
            context,
            icon: Icons.info,
            title: 'About FarmFresh',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          _menuTile(
            context,
            icon: Icons.description,
            title: 'Terms & Conditions',
            onTap: () => _showPlaceholderPage(context, 'Terms & Conditions'),
          ),
          const Divider(height: 1),
          _menuTile(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () => _showPlaceholderPage(context, 'Privacy Policy'),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Log Out'),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FarmFresh',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.spa, color: Colors.green, size: 32),
      ),
      children: const [
        Text(
          'FarmFresh connects you directly with local farmers for the freshest produce and dairy products.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _showPlaceholderPage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title page coming soon')),
    );
  }
}
