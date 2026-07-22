import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model.dart';
import '../../providers/customer_notification_provider.dart';
import '../../core/widgets/responsive_layout.dart';

class CustomerNotificationsScreen extends ConsumerStatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  ConsumerState<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends ConsumerState<CustomerNotificationsScreen> {
  String _selectedFilter = 'ALL';

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return Icons.shopping_bag_outlined;
      case 'PROMOTION':
      case 'OFFER':
        return Icons.local_offer_outlined;
      case 'HARVEST':
        return Icons.eco_outlined;
      case 'SYSTEM':
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return const Color(0xFF219EBC);
      case 'PROMOTION':
      case 'OFFER':
        return const Color(0xFFFF4D6D);
      case 'HARVEST':
        return const Color(0xFF2E7D32);
      case 'SYSTEM':
      default:
        return const Color(0xFFE28C43);
    }
  }

  void _onNotificationTap(AppNotificationModel notification) {
    if (!notification.isRead) {
      ref.read(customerNotificationProvider.notifier).markRead(notification.id);
    }

    final type = notification.type.toUpperCase();
    final data = notification.data;

    if (type == 'ORDER') {
      final orderId = data?['orderId'] as String?;
      if (orderId != null && mounted) {
        context.push('/order-tracking/$orderId');
      } else if (mounted) {
        context.push('/orders');
      }
    } else if (type == 'PROMOTION' || type == 'OFFER' || type == 'HARVEST') {
      if (mounted) {
        context.push('/products');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(customerNotificationProvider);
    final allNotifications = notifState.notifications;

    final filteredNotifications = allNotifications.where((n) {
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'ORDERS') return n.type.toUpperCase() == 'ORDER';
      if (_selectedFilter == 'OFFERS') return n.type.toUpperCase() == 'PROMOTION' || n.type.toUpperCase() == 'OFFER';
      if (_selectedFilter == 'HARVESTS') return n.type.toUpperCase() == 'HARVEST';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/customer-main');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF7FAF8),
                border: Border.all(color: const Color(0xFFE8F5E9)),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF23312B), size: 20),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF23312B),
              ),
            ),
            if (notifState.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${notifState.unreadCount} New',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref.read(customerNotificationProvider.notifier).markAllRead();
              },
              icon: const Icon(Icons.done_all, size: 18, color: Color(0xFF2E7D32)),
              label: Text(
                'Mark All Read',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContainer(
        child: Column(
        children: [
          // Filter pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'All Activity'),
                  const SizedBox(width: 8),
                  _buildFilterChip('ORDERS', 'Orders & Delivery'),
                  const SizedBox(width: 8),
                  _buildFilterChip('OFFERS', 'Offers & Promos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('HARVESTS', 'Farm Harvests'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFECECEC)),

          // Notifications List
          Expanded(
            child: notifState.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : RefreshIndicator(
                    color: const Color(0xFF2E7D32),
                    onRefresh: () => ref.read(customerNotificationProvider.notifier).loadNotifications(),
                    child: filteredNotifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = filteredNotifications[index];
                              return Dismissible(
                                key: Key(notification.id),
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4D6D),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  ref.read(customerNotificationProvider.notifier).deleteNotification(notification.id);
                                },
                                child: _buildNotificationCard(notification),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFF0F4F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF647C72),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotificationModel notification) {
    final themeColor = _colorForType(notification.type);
    final typeIcon = _iconForType(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFF0F7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFFEFEFEF)
              : const Color(0xFF2E7D32).withOpacity(0.25),
          width: notification.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: themeColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: const Color(0xFF23312B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(notification.createdAt),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF8D99AE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF52635B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread Dot
                if (!notification.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_outlined, size: 38, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 20),
            Text(
              'No Notifications Yet',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF23312B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We will alert you when your farm orders are dispatched, or when special fresh harvest offers arrive!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF647C72),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
