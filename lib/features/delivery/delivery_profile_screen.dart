import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/delivery_profile_model.dart';

class DeliveryProfileScreen extends ConsumerStatefulWidget {
  const DeliveryProfileScreen({super.key});

  @override
  ConsumerState<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends ConsumerState<DeliveryProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(deliveryProfileProvider.notifier).loadProfile();
      final profile = ref.read(deliveryProfileProvider).profile;
      _populateFields(profile);
    });
  }

  void _populateFields(DeliveryProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _vehicleTypeController.text = profile.vehicle?.type ?? '';
    _vehicleNumberController.text = profile.vehicle?.plateNumber ?? '';
    _licenseNumberController.text = profile.license?.number ?? '';
    _bankNameController.text = profile.bankAccount?.bankName ?? '';
    _accountNumberController.text = profile.bankAccount?.accountNumber ?? '';
    _routingNumberController.text = profile.bankAccount?.ifscCode ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryProfileProvider);

    ref.listen<DeliveryProfileState>(deliveryProfileProvider, (previous, next) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Driver Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDriverHeader(state.profile),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Personal Contact Details'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Contact Phone Number', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Phone required' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Vehicle Information'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vehicleTypeController,
                      decoration: const InputDecoration(labelText: 'Vehicle Type (e.g. Motorcycle, Van)', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Vehicle type required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vehicleNumberController,
                      decoration: const InputDecoration(labelText: 'Vehicle Number Plate', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Vehicle plate required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(labelText: 'Driving License Number', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'License number required' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Bank Settlement Account'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Bank name required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Account number required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _routingNumberController,
                      decoration: const InputDecoration(labelText: 'IFSC / Routing Code', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'IFSC code required' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDriverHeader(DeliveryProfile profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green.shade50,
            child: const Icon(Icons.person, size: 48, color: Colors.green),
          ),
          const SizedBox(height: 12),
          Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '${profile.rating.average.toStringAsFixed(1)} Rating',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(deliveryProfileProvider.notifier);
      final ok = await notifier.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicle: DeliveryVehicleInfo(
          type: _vehicleTypeController.text.trim(),
          plateNumber: _vehicleNumberController.text.trim(),
          make: 'N/A',
          model: 'N/A',
        ),
        license: DeliveryLicenseInfo(
          number: _licenseNumberController.text.trim(),
        ),
        bankAccount: DeliveryBankInfo(
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          ifscCode: _routingNumberController.text.trim(),
        ),
      );
      if (mounted && ok) {
        FocusScope.of(context).unfocus();
      }
    }
  }
}
