import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/notification_model.dart';
import '../../providers/farmer_provider.dart';

class FarmerNotificationsScreen extends ConsumerStatefulWidget {
  const FarmerNotificationsScreen({super.key});

  @override
  ConsumerState<FarmerNotificationsScreen> createState() =>
      _FarmerNotificationsScreenState();
}

class _FarmerNotificationsScreenState
    extends ConsumerState<FarmerNotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(farmerNotificationProvider.notifier).loadMore();
    }
  }

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
        return Icons.shopping_bag;
      case 'PRODUCT':
        return Icons.inventory_2;
      case 'STOCK':
        return Icons.warning_amber;
      case 'WITHDRAWAL':
        return Icons.account_balance;
      case 'PROMOTION':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return Colors.blue;
      case 'PRODUCT':
        return Colors.teal;
      case 'STOCK':
        return Colors.orange;
      case 'WITHDRAWAL':
        return Colors.purple;
      case 'PROMOTION':
        return Colors.pink;
      default:
        return Colors.green;
    }
  }

  void _onNotificationTap(AppNotificationModel notification) {
    if (!notification.isRead) {
      ref.read(farmerNotificationProvider.notifier).markRead(notification.id);
    }

    final type = notification.type.toUpperCase();
    final data = notification.data;

    switch (type) {
      case 'ORDER':
        final orderId = data?['orderId'] as String? ?? data?['order_id'];
        if (orderId != null && mounted) {
          context.push('/farmer-orders');
        }
        break;
      case 'PRODUCT':
        context.push('/farmer-products');
        break;
      case 'STOCK':
        context.push('/farmer-inventory');
        break;
      case 'WITHDRAWAL':
        context.push('/farmer-withdrawal');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerNotificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref
                    .read(farmerNotificationProvider.notifier)
                    .markAllRead();
              },
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: state.isLoading && state.notifications.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : state.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(farmerNotificationProvider.notifier)
                        .loadNotifications();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.notifications.length +
                        (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      final notification = state.notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        timeAgo: _timeAgo(notification.createdAt),
                        icon: _iconForType(notification.type),
                        iconColor: _colorForType(notification.type),
                        onTap: () => _onNotificationTap(notification),
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: notification.isRead ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: notification.isRead
            ? BorderSide.none
            : const BorderSide(color: Colors.green, width: 1.5),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
