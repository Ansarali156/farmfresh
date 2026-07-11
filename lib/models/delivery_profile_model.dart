class DeliveryProfile {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImage;
  final DeliveryVehicleInfo? vehicle;
  final DeliveryLicenseInfo? license;
  final DeliveryBankInfo? bankAccount;
  final DeliveryRatingInfo rating;
  final bool isAvailable;
  final String? createdAt;

  DeliveryProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImage,
    this.vehicle,
    this.license,
    this.bankAccount,
    required this.rating,
    required this.isAvailable,
    this.createdAt,
  });

  factory DeliveryProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      profileImage: json['profileImage'],
      vehicle: json['vehicle'] != null
          ? DeliveryVehicleInfo.fromJson(json['vehicle'])
          : null,
      license: json['license'] != null
          ? DeliveryLicenseInfo.fromJson(json['license'])
          : null,
      bankAccount: json['bankAccount'] != null
          ? DeliveryBankInfo.fromJson(json['bankAccount'])
          : null,
      rating: DeliveryRatingInfo.fromJson(json['rating'] ?? {}),
      isAvailable: json['isAvailable'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  DeliveryProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? profileImage,
    DeliveryVehicleInfo? vehicle,
    DeliveryLicenseInfo? license,
    DeliveryBankInfo? bankAccount,
    bool? isAvailable,
  }) {
    return DeliveryProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      vehicle: vehicle ?? this.vehicle,
      license: license ?? this.license,
      bankAccount: bankAccount ?? this.bankAccount,
      rating: rating,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
    );
  }
}

class DeliveryVehicleInfo {
  final String type;
  final String make;
  final String model;
  final String plateNumber;
  final String? color;

  DeliveryVehicleInfo({
    required this.type,
    required this.make,
    required this.model,
    required this.plateNumber,
    this.color,
  });

  factory DeliveryVehicleInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryVehicleInfo(
      type: json['type'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'make': make,
      'model': model,
      'plateNumber': plateNumber,
      'color': color,
    };
  }
}

class DeliveryLicenseInfo {
  final String number;
  final String? expiryDate;
  final String? verifiedAt;

  DeliveryLicenseInfo({
    required this.number,
    this.expiryDate,
    this.verifiedAt,
  });

  factory DeliveryLicenseInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryLicenseInfo(
      number: json['number'] ?? '',
      expiryDate: json['expiryDate'],
      verifiedAt: json['verifiedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'expiryDate': expiryDate,
    };
  }
}

class DeliveryBankInfo {
  final String bankName;
  final String accountNumber;
  final String? accountHolderName;
  final String? ifscCode;

  DeliveryBankInfo({
    required this.bankName,
    required this.accountNumber,
    this.accountHolderName,
    this.ifscCode,
  });

  factory DeliveryBankInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryBankInfo(
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'],
      ifscCode: json['ifscCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'ifscCode': ifscCode,
    };
  }
}

class DeliveryRatingInfo {
  final double average;
  final int totalRatings;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;

  const DeliveryRatingInfo({
    required this.average,
    required this.totalRatings,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
  });

  factory DeliveryRatingInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryRatingInfo(
      average: (json['average'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      fiveStarCount: json['fiveStarCount'] ?? 0,
      fourStarCount: json['fourStarCount'] ?? 0,
      threeStarCount: json['threeStarCount'] ?? 0,
      twoStarCount: json['twoStarCount'] ?? 0,
      oneStarCount: json['oneStarCount'] ?? 0,
    );
  }
}
