class PromotionModel {
  final String promoId;
  final String code;
  final String description;
  final String discountType; // 'percentage' | 'fixed'
  final double discountValue;
  final double minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime validUntil;
  final bool isActive;

  PromotionModel({
    required this.promoId,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.maxDiscountAmount,
    required this.validUntil,
    this.isActive = true,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      promoId: json['promo_id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discount_type'] ?? 'fixed',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until']) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'promo_id': promoId,
        'code': code,
        'description': description,
        'discount_type': discountType,
        'discount_value': discountValue,
        'min_order_amount': minOrderAmount,
        'max_discount_amount': maxDiscountAmount,
        'valid_until': validUntil.toIso8601String(),
        'is_active': isActive,
      };
}
