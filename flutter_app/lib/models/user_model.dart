class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePhoto;
  final String referralCode;
  final double referralEarnings;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePhoto,
    required this.referralCode,
    this.referralEarnings = 0.0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePhoto: json['profile_photo'],
      referralCode: json['referral_code'] ?? '',
      referralEarnings: (json['referral_earnings'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'profile_photo': profilePhoto,
        'referral_code': referralCode,
        'referral_earnings': referralEarnings,
        'created_at': createdAt.toIso8601String(),
      };
}
