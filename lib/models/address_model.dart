class AddressModel {
  final String id;
  final String label;
  final String street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? contactPhone;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.contactPhone,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? 'Home',
      street: json['street'] as String? ?? json['address'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
      contactPhone: json['contactPhone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zipCode != null) 'zipCode': zipCode,
      if (country != null) 'country': country,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    final parts = <String>[street];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? contactPhone,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      contactPhone: contactPhone ?? this.contactPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
