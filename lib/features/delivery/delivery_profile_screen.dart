import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
          SnackBar(
            content: Text(next.actionMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        ref.read(deliveryProfileProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFFF4D6D),
          ),
        );
        ref.read(deliveryProfileProvider.notifier).clearMessages();
      }
    });

    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Rider Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: () => ref.read(deliveryProfileProvider.notifier).loadProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    _buildProfileHeader(profile),
                    const SizedBox(height: 16),
                    _buildAvailabilityToggle(profile),
                    const SizedBox(height: 16),
                    _buildMenuItems(context),
                    const SizedBox(height: 20),
                    _buildSwitchRoleButton(context),
                    const SizedBox(height: 12),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8F5E9), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F2E5C45),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                'https://api.dicebear.com/7.x/adventurer/svg?seed=RiderAlex',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF23312B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email ?? 'rider@farmfresh.com',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF647C72),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (profile.phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              profile.phone,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF647C72),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB703), size: 16),
              const SizedBox(width: 4),
              Text(
                '${profile.rating.average.toStringAsFixed(1)} (${profile.rating.totalRatings} ratings)',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (profile.vehicle != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${profile.vehicle!.type} • ${profile.vehicle!.plateNumber}'.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle(DeliveryProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          'Online Duty Status',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        subtitle: Text(
          profile.isAvailable ? 'Available for job offers' : 'Offline (No assignments)',
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72)),
        ),
        value: profile.isAvailable,
        onChanged: (_) => ref.read(deliveryProfileProvider.notifier).toggleAvailability(),
        activeColor: const Color(0xFF2E7D32),
        secondary: Icon(
          profile.isAvailable ? Icons.wifi_outlined : Icons.wifi_off_outlined,
          color: profile.isAvailable ? const Color(0xFF2E7D32) : const Color(0xFF8D99AE),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final items = [
      _MenuItem(Icons.edit_outlined, 'Edit Profile Info', () => context.push('/delivery-edit-profile')),
      _MenuItem(Icons.directions_car_outlined, 'Vehicle Information', () => _showVehicleInfo(context)),
      _MenuItem(Icons.credit_card_outlined, 'Bank Account details', () => _showBankDetails(context)),
      _MenuItem(Icons.history_outlined, 'Delivery Jobs History', () => context.push('/delivery-history')),
      _MenuItem(Icons.notifications_none_outlined, 'Notification alerts', () => context.push('/delivery-notifications')),
      _MenuItem(Icons.star_outline, 'Rider performance reviews', () => _showRatings(context)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: const Color(0xFF2E7D32), size: 20),
                title: Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: const Color(0xFF23312B),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF647C72)),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, color: Color(0xFFF3F3F3)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSwitchRoleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(authProvider.notifier).switchRole('Customer');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Switched to Customer Marketplace Mode',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
          context.go('/customer-main');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2E7D32),
          side: const BorderSide(color: Color(0xFF2E7D32)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.swap_horiz, size: 16),
        label: Text(
          'Switch to Customer Marketplace',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: Text('Are you sure you want to log out?', style: GoogleFonts.plusJakartaSans()),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)))),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Logout', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          }
        },
        icon: const Icon(Icons.logout, size: 16),
        label: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF4D6D),
          side: const BorderSide(color: Color(0xFFFF4D6D)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        title: Text('Vehicle Information', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: typeController, style: GoogleFonts.plusJakartaSans(fontSize: 12), decoration: InputDecoration(labelText: 'Vehicle Type', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11))),
              TextField(controller: makeController, style: GoogleFonts.plusJakartaSans(fontSize: 12), decoration: InputDecoration(labelText: 'Make', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11))),
              TextField(controller: modelController, style: GoogleFonts.plusJakartaSans(fontSize: 12), decoration: InputDecoration(labelText: 'Model', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11))),
              TextField(controller: plateController, style: GoogleFonts.plusJakartaSans(fontSize: 12), decoration: InputDecoration(labelText: 'Plate Number', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)))),
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
            child: Text('Save Info', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
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
        title: Text('Bank Payout Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: bankNameController, style: GoogleFonts.plusJakartaSans(fontSize: 12), decoration: InputDecoration(labelText: 'Bank Name', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11))),
              TextField(controller: accountController, style: GoogleFonts.plusJakartaSans(fontSize: 12), decoration: InputDecoration(labelText: 'Account Number', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11))),
              TextField(controller: holderController, style: GoogleFonts.plusJakartaSans(fontSize: 12), decoration: InputDecoration(labelText: 'Account Holder Name', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)))),
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
            child: Text('Save Info', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
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
                style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => Icon(
                    i < rating.average.round() ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFB703),
                    size: 24,
                  )),
            ),
            const SizedBox(height: 6),
            Text('${rating.totalRatings} ratings', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 12)),
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
          Text('$stars', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: const Color(0xFFF0F2EF),
                color: const Color(0xFFFFB703),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), fontWeight: FontWeight.w600)),
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
