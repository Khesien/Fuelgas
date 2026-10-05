class AddressModel {
  final String addressId;
  final String userId;
  final String label;
  final String plotUnit;
  final String street;
  final String city;
  final String district;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.addressId,
    required this.userId,
    required this.label,
    required this.plotUnit,
    required this.street,
    required this.city,
    required this.district,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['address_id'] ?? '',
      userId: json['user_id'] ?? '',
      label: json['label'] ?? '',
      plotUnit: json['plot_unit'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? 'Gaborone Central',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -24.6580,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 25.9120,
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'address_id': addressId,
        'user_id': userId,
        'label': label,
        'plot_unit': plotUnit,
        'street': street,
        'city': city,
        'district': district,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };

  String get fullAddress => '$plotUnit, $street, $district, $city';
}
