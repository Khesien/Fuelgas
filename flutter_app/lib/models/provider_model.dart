class PriceTier {
  final double refill;
  final double exchange;

  PriceTier({required this.refill, required this.exchange});

  factory PriceTier.fromJson(Map<String, dynamic> json) {
    return PriceTier(
      refill: (json['refill'] as num?)?.toDouble() ?? 195.0,
      exchange: (json['exchange'] as num?)?.toDouble() ?? 320.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'refill': refill,
        'exchange': exchange,
      };
}

class GasProviderModel {
  final String providerId;
  final String companyName;
  final String slug;
  final String logoUrl;
  final String? bannerUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> districtsServed;
  final String complianceStatus; // 'approved', 'under_review', 'suspended'
  final String licenseNumber;
  final int safetyScore;
  final String contactPhone;
  final String contactEmail;
  final double baseDeliveryFee;
  final int estDeliveryMins;
  final Map<String, PriceTier> prices;

  GasProviderModel({
    required this.providerId,
    required this.companyName,
    required this.slug,
    required this.logoUrl,
    this.bannerUrl,
    required this.description,
    this.rating = 5.0,
    this.reviewCount = 0,
    required this.districtsServed,
    this.complianceStatus = 'approved',
    required this.licenseNumber,
    this.safetyScore = 98,
    required this.contactPhone,
    required this.contactEmail,
    this.baseDeliveryFee = 25.0,
    this.estDeliveryMins = 30,
    required this.prices,
  });

  factory GasProviderModel.fromJson(Map<String, dynamic> json) {
    Map<String, PriceTier> parsedPrices = {};
    if (json['prices'] is Map) {
      (json['prices'] as Map).forEach((key, val) {
        if (val is Map<String, dynamic>) {
          parsedPrices[key.toString()] = PriceTier.fromJson(val);
        } else if (val is Map) {
          parsedPrices[key.toString()] =
              PriceTier.fromJson(Map<String, dynamic>.from(val));
        }
      });
    }

    return GasProviderModel(
      providerId: json['provider_id'] ?? '',
      companyName: json['company_name'] ?? '',
      slug: json['slug'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      bannerUrl: json['banner_url'],
      description: json['description'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: json['review_count'] ?? 0,
      districtsServed: (json['districts_served'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      complianceStatus: json['compliance_status'] ?? 'approved',
      licenseNumber: json['license_number'] ?? '',
      safetyScore: json['safety_score'] ?? 98,
      contactPhone: json['contact_phone'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      baseDeliveryFee: (json['base_delivery_fee'] as num?)?.toDouble() ?? 25.0,
      estDeliveryMins: json['est_delivery_mins'] ?? 30,
      prices: parsedPrices,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider_id': providerId,
        'company_name': companyName,
        'slug': slug,
        'logo_url': logoUrl,
        'banner_url': bannerUrl,
        'description': description,
        'rating': rating,
        'review_count': reviewCount,
        'districts_served': districtsServed,
        'compliance_status': complianceStatus,
        'license_number': licenseNumber,
        'safety_score': safetyScore,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'base_delivery_fee': baseDeliveryFee,
        'est_delivery_mins': estDeliveryMins,
        'prices': prices.map((k, v) => MapEntry(k, v.toJson())),
      };
}
