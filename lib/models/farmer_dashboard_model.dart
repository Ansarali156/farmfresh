class FarmerDashboardModel {
  final double todaySales;
  final double totalRevenue;
  final int pendingOrders;
  final int acceptedOrders;
  final int deliveredOrders;
  final int activeProducts;
  final int outOfStockProducts;
  final List<MonthlyRevenue> monthlyRevenue;
  final List<WeeklyOrders> weeklyOrders;
  final int unreadNotifications;

  const FarmerDashboardModel({
    this.todaySales = 0,
    this.totalRevenue = 0,
    this.pendingOrders = 0,
    this.acceptedOrders = 0,
    this.deliveredOrders = 0,
    this.activeProducts = 0,
    this.outOfStockProducts = 0,
    this.monthlyRevenue = const [],
    this.weeklyOrders = const [],
    this.unreadNotifications = 0,
  });

  factory FarmerDashboardModel.fromJson(Map<String, dynamic> json) {
    return FarmerDashboardModel(
      todaySales: (json['todaySales'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? 0,
      acceptedOrders: json['acceptedOrders'] as int? ?? 0,
      deliveredOrders: json['deliveredOrders'] as int? ?? 0,
      activeProducts: json['activeProducts'] as int? ?? 0,
      outOfStockProducts: json['outOfStockProducts'] as int? ?? 0,
      monthlyRevenue: json['monthlyRevenue'] != null
          ? (json['monthlyRevenue'] as List)
              .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      weeklyOrders: json['weeklyOrders'] != null
          ? (json['weeklyOrders'] as List)
              .map((e) => WeeklyOrders.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      unreadNotifications: json['unreadNotifications'] as int? ?? 0,
    );
  }
}

class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue({required this.month, required this.revenue});

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      month: json['month'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WeeklyOrders {
  final String day;
  final int count;

  WeeklyOrders({required this.day, required this.count});

  factory WeeklyOrders.fromJson(Map<String, dynamic> json) {
    return WeeklyOrders(
      day: json['day'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class FarmerStatisticsModel {
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double dailyEarnings;
  final double pendingWithdrawals;
  final double completedWithdrawals;
  final int totalOrders;
  final int totalProducts;

  const FarmerStatisticsModel({
    this.totalEarnings = 0,
    this.monthlyEarnings = 0,
    this.weeklyEarnings = 0,
    this.dailyEarnings = 0,
    this.pendingWithdrawals = 0,
    this.completedWithdrawals = 0,
    this.totalOrders = 0,
    this.totalProducts = 0,
  });

  factory FarmerStatisticsModel.fromJson(Map<String, dynamic> json) {
    return FarmerStatisticsModel(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      monthlyEarnings: (json['monthlyEarnings'] as num?)?.toDouble() ?? 0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0,
      dailyEarnings: (json['dailyEarnings'] as num?)?.toDouble() ?? 0,
      pendingWithdrawals: (json['pendingWithdrawals'] as num?)?.toDouble() ?? 0,
      completedWithdrawals: (json['completedWithdrawals'] as num?)?.toDouble() ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalProducts: json['totalProducts'] as int? ?? 0,
    );
  }
}
