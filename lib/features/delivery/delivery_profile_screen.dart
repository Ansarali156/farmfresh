import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/delivery_profile_model.dart';

class DeliveryProfileScreen extends ConsumerStatefulWidget {
  const DeliveryProfileScreen({super.key});

  @override
  ConsumerState<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends ConsumerState<DeliveryProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryProfileProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(deliveryProfileProvider);

    ref.listen<DeliveryProfileState>(deliveryProfileProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!), backgroundColor: Colors.green),
        );
        ref.read(deliveryProfileProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(deliveryProfileProvider.notifier).clearMessages();
      }
    });

    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveryProfileProvider.notifier).loadProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(profile),
                    const SizedBox(height: 8),
                    _buildAvailabilityToggle(profile),
                    const SizedBox(height: 8),
                    _buildMenuItems(context),
                    const SizedBox(height: 8),
                    _buildLogoutButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(DeliveryProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: profile.profileImage != null
                ? NetworkImage(profile.profileImage!)
                : null,
            child: profile.profileImage == null
                ? const Icon(Icons.person, size: 45, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(profile.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(profile.phone, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          if (profile.email != null)
            Text(profile.email!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber[300], size: 20),
              const SizedBox(width: 4),
              Text(
                '${profile.rating.average.toStringAsFixed(1)} (${profile.rating.totalRatings} ratings)',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          if (profile.vehicle != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${profile.vehicle!.type} • ${profile.vehicle!.plateNumber}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle(DeliveryProfile profile) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text('Available for deliveries'),
        subtitle: Text(profile.isAvailable ? 'You are online' : 'You are offline'),
        value: profile.isAvailable,
        onChanged: (_) => ref.read(deliveryProfileProvider.notifier).toggleAvailability(),
        activeColor: Colors.green,
        secondary: Icon(
          profile.isAvailable ? Icons.wifi : Icons.wifi_off,
          color: profile.isAvailable ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final items = [
      _MenuItem(Icons.person_outline, 'Edit Profile', () => context.push('/delivery-edit-profile')),
      _MenuItem(Icons.directions_car_outlined, 'Vehicle Information', () => _showVehicleInfo(context)),
      _MenuItem(Icons.credit_card_outlined, 'Bank Details', () => _showBankDetails(context)),
      _MenuItem(Icons.history, 'Delivery History', () => context.push('/delivery-history')),
      _MenuItem(Icons.notifications_outlined, 'Notifications', () => context.push('/delivery-notifications')),
      _MenuItem(Icons.star_outline, 'Ratings', () => _showRatings(context)),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: Icon(item.icon, color: Colors.green),
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: item.onTap,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            }
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Logout', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _showVehicleInfo(BuildContext context) {
    final profile = ref.read(deliveryProfileProvider).profile;
    final vehicle = profile.vehicle;
    final makeController = TextEditingController(text: vehicle?.make ?? '');
    final modelController = TextEditingController(text: vehicle?.model ?? '');
    final typeController = TextEditingController(text: vehicle?.type ?? '');
    final plateController = TextEditingController(text: vehicle?.plateNumber ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vehicle Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Vehicle Type')),
              TextField(controller: makeController, decoration: const InputDecoration(labelText: 'Make')),
              TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Model')),
              TextField(controller: plateController, decoration: const InputDecoration(labelText: 'Plate Number')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(deliveryProfileProvider.notifier).updateProfile(
                vehicle: DeliveryVehicleInfo(
                  type: typeController.text.trim(),
                  make: makeController.text.trim(),
                  model: modelController.text.trim(),
                  plateNumber: plateController.text.trim(),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showBankDetails(BuildContext context) {
    final profile = ref.read(deliveryProfileProvider).profile;
    final bank = profile.bankAccount;
    final bankNameController = TextEditingController(text: bank?.bankName ?? '');
    final accountController = TextEditingController(text: bank?.accountNumber ?? '');
    final holderController = TextEditingController(text: bank?.accountHolderName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: bankNameController, decoration: const InputDecoration(labelText: 'Bank Name')),
              TextField(controller: accountController, decoration: const InputDecoration(labelText: 'Account Number')),
              TextField(controller: holderController, decoration: const InputDecoration(labelText: 'Account Holder Name')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(deliveryProfileProvider.notifier).updateProfile(
                bankAccount: DeliveryBankInfo(
                  bankName: bankNameController.text.trim(),
                  accountNumber: accountController.text.trim(),
                  accountHolderName: holderController.text.trim(),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showRatings(BuildContext context) {
    final profile = ref.read(deliveryProfileProvider).profile;
    final rating = profile.rating;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rating.average.toStringAsFixed(1),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => Icon(
                    i < rating.average.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  )),
            ),
            Text('${rating.totalRatings} ratings', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            _buildRatingBar(5, rating.fiveStarCount, rating.totalRatings),
            _buildRatingBar(4, rating.fourStarCount, rating.totalRatings),
            _buildRatingBar(3, rating.threeStarCount, rating.totalRatings),
            _buildRatingBar(2, rating.twoStarCount, rating.totalRatings),
            _buildRatingBar(1, rating.oneStarCount, rating.totalRatings),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final fraction = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Expanded(
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: Colors.grey[200],
              color: Colors.amber,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.title, this.onTap);
}
