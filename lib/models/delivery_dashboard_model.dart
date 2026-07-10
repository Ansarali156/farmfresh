class DeliveryDashboardModel {
  final DeliveryStats stats;
  final List<DeliveryEarningsSummary> recentEarnings;
  final int unreadNotifications;

  DeliveryDashboardModel({
    required this.stats,
    required this.recentEarnings,
    required this.unreadNotifications,
  });

  factory DeliveryDashboardModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDashboardModel(
      stats: DeliveryStats.fromJson(json['stats'] ?? {}),
      recentEarnings: (json['recentEarnings'] as List?)
              ?.map((e) => DeliveryEarningsSummary.fromJson(e))
              .toList() ??
          [],
      unreadNotifications: json['unreadNotifications'] ?? 0,
    );
  }
}

class DeliveryStats {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final int activeDeliveries;
  final int pendingDeliveries;
  final int completedToday;
  final int cancelledToday;
  final double averageRating;
  final int totalDeliveries;

  DeliveryStats({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.activeDeliveries,
    required this.pendingDeliveries,
    required this.completedToday,
    required this.cancelledToday,
    required this.averageRating,
    required this.totalDeliveries,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      todayEarnings: (json['todayEarnings'] ?? 0).toDouble(),
      weeklyEarnings: (json['weeklyEarnings'] ?? 0).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] ?? 0).toDouble(),
      activeDeliveries: json['activeDeliveries'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      completedToday: json['completedToday'] ?? 0,
      cancelledToday: json['cancelledToday'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalDeliveries: json['totalDeliveries'] ?? 0,
    );
  }
}

class DeliveryEarningsSummary {
  final String period;
  final double amount;
  final int deliveries;

  DeliveryEarningsSummary({
    required this.period,
    required this.amount,
    required this.deliveries,
  });

  factory DeliveryEarningsSummary.fromJson(Map<String, dynamic> json) {
    return DeliveryEarningsSummary(
      period: json['period'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      deliveries: json['deliveries'] ?? 0,
    );
  }
}
