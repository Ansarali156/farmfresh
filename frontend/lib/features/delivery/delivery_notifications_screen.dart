import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../core/theme/delivery_theme.dart';

class DeliveryNotificationsScreen extends ConsumerStatefulWidget {
  const DeliveryNotificationsScreen({super.key});

  @override
  ConsumerState<DeliveryNotificationsScreen> createState() => _DeliveryNotificationsScreenState();
}

class _DeliveryNotificationsScreenState extends ConsumerState<DeliveryNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryNotificationProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryNotificationProvider);

    return Scaffold(
      backgroundColor: DeliveryTheme.bgCanvas,
      appBar: AppBar(
        title: Text(
          'Fleet Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: DeliveryTheme.navyDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x3D0F172A),
        actions: [
          if (state.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => ref.read(deliveryNotificationProvider.notifier).markAllRead(),
              child: Text(
                'Mark all read',
                style: GoogleFonts.plusJakartaSans(color: DeliveryTheme.orangePrimary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: DeliveryTheme.orangePrimary))
          : RefreshIndicator(
              color: DeliveryTheme.orangePrimary,
              onRefresh: () => ref.read(deliveryNotificationProvider.notifier).loadNotifications(),
              child: state.notifications.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                        Center(
                          child: Text(
                            'You have no notifications yet.',
                            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notif = state.notifications[index];
                        return Container(
                          decoration: DeliveryTheme.cardDecoration(
                            borderColor: notif.isRead ? null : DeliveryTheme.orangePrimary.withOpacity(0.4),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: DeliveryTheme.navyDark.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_active, color: DeliveryTheme.orangePrimary, size: 20),
                            ),
                            title: Text(
                              notif.title,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: DeliveryTheme.navyDark),
                            ),
                            subtitle: Text(
                              notif.body,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                            ),

                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
