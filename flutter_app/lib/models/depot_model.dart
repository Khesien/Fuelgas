class DepotModel {
  final String depotId;
  final String providerId;
  final String name;
  final String location;
  final String address;
  final String district;
  final double latitude;
  final double longitude;
  final String contactPhone;
  final Map<String, int> stock;

  DepotModel({
    required this.depotId,
    required this.providerId,
    required this.name,
    required this.location,
    required this.address,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.contactPhone,
    required this.stock,
  });

  factory DepotModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> stockMap = {};
    if (json['stock'] is Map) {
      (json['stock'] as Map).forEach((k, v) {
        stockMap[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }

    return DepotModel(
      depotId: json['depot_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? 'Gaborone Central',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -24.6225,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 25.9280,
      contactPhone: json['contact_phone'] ?? '',
      stock: stockMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'depot_id': depotId,
        'provider_id': providerId,
        'name': name,
        'location': location,
        'address': address,
        'district': district,
        'latitude': latitude,
        'longitude': longitude,
        'contact_phone': contactPhone,
        'stock': stock,
      };

  DepotModel copyWith({Map<String, int>? stock}) {
    return DepotModel(
      depotId: depotId,
      providerId: providerId,
      name: name,
      location: location,
      address: address,
      district: district,
      latitude: latitude,
      longitude: longitude,
      contactPhone: contactPhone,
      stock: stock ?? this.stock,
    );
  }
}
