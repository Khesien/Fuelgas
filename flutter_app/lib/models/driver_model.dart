class DriverModel {
  final String driverId;
  final String providerId;
  final String fullName;
  final String phone;
  final String email;
  final String photoUrl;
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNo;
  final double ratingAvg;
  final int completedOrders;
  final String status; // 'online', 'offline', 'on_delivery'
  final double currentLat;
  final double currentLng;
  final String verificationStatus;

  DriverModel({
    required this.driverId,
    required this.providerId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNo,
    this.ratingAvg = 4.9,
    this.completedOrders = 0,
    this.status = 'online',
    required this.currentLat,
    required this.currentLng,
    this.verificationStatus = 'approved',
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      driverId: json['driver_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      vehicleType: json['vehicle_type'] ?? 'Delivery Van',
      vehicleNumber: json['vehicle_number'] ?? '',
      licenseNo: json['license_no'] ?? '',
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 4.9,
      completedOrders: json['completed_orders'] ?? 0,
      status: json['status'] ?? 'online',
      currentLat: (json['current_lat'] as num?)?.toDouble() ?? -24.6490,
      currentLng: (json['current_lng'] as num?)?.toDouble() ?? 25.9180,
      verificationStatus: json['verification_status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'provider_id': providerId,
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'photo_url': photoUrl,
        'vehicle_type': vehicleType,
        'vehicle_number': vehicleNumber,
        'license_no': licenseNo,
        'rating_avg': ratingAvg,
        'completed_orders': completedOrders,
        'status': status,
        'current_lat': currentLat,
        'current_lng': currentLng,
        'verification_status': verificationStatus,
      };

  DriverModel copyWith({
    String? status,
    double? currentLat,
    double? currentLng,
    int? completedOrders,
  }) {
    return DriverModel(
      driverId: driverId,
      providerId: providerId,
      fullName: fullName,
      phone: phone,
      email: email,
      photoUrl: photoUrl,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNo: licenseNo,
      ratingAvg: ratingAvg,
      completedOrders: completedOrders ?? this.completedOrders,
      status: status ?? this.status,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      verificationStatus: verificationStatus,
    );
  }
}
