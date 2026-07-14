import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';
import '../../models/notification_model.dart';

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
    final notifState = ref.watch(deliveryNotificationProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2F8F4),
            Color(0xFFE6F2EA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (notifState.unreadCount > 0)
              TextButton(
                onPressed: () => ref.read(deliveryNotificationProvider.notifier).markAllRead(),
                child: Text(
                  'Mark All Read',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
          ],
        ),
        body: notifState.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : RefreshIndicator(
                color: const Color(0xFF2E7D32),
                onRefresh: () => ref.read(deliveryNotificationProvider.notifier).loadNotifications(),
                child: notifState.notifications.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEAF6EC),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_outlined,
                                  size: 28,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF23312B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'We will alert you on updates regarding delivery routing status.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: notifState.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifState.notifications[index];
                          return _buildNotificationTile(notif);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildNotificationTile(AppNotificationModel notif) {
    String dateStr = '';
    try {
      dateStr = DateFormat('dd/MM • HH:mm').format(notif.createdAt);
    } catch (_) {
      dateStr = notif.createdAt.toString();
    }

    final accentColor = _getNotificationColor(notif.type);
    final iconBg = accentColor.withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: notif.isRead
            ? null
            : Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (!notif.isRead) {
              ref.read(deliveryNotificationProvider.notifier).markRead(notif.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getNotificationIcon(notif.type), color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: notif.isRead ? FontWeight.bold : FontWeight.w800,
                                fontSize: 13,
                                color: const Color(0xFF23312B),
                              ),
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notif.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF647C72),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF8D99AE),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF647C72),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order_assigned':
        return Icons.assignment_outlined;
      case 'order_accepted':
        return Icons.check_circle_outline;
      case 'order_delivered':
        return Icons.flag_outlined;
      case 'payment':
        return Icons.attach_money;
      case 'rating':
        return Icons.star_outline;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'order_assigned':
        return const Color(0xFF219EBC);
      case 'order_accepted':
        return const Color(0xFF2E7D32);
      case 'order_delivered':
        return const Color(0xFF2E7D32);
      case 'payment':
        return const Color(0xFFE28C43);
      case 'rating':
        return const Color(0xFFFFB703);
      default:
        return const Color(0xFF2E7D32);
    }
  }
}
