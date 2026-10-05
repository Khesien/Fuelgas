class CylinderProductModel {
  final String productId;
  final String size;
  final double sizeKg;
  final String name;
  final String description;
  final String imageUrl;
  final bool isActive;
  final bool popular;

  CylinderProductModel({
    required this.productId,
    required this.size,
    required this.sizeKg,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isActive = true,
    this.popular = false,
  });

  factory CylinderProductModel.fromJson(Map<String, dynamic> json) {
    return CylinderProductModel(
      productId: json['product_id'] ?? '',
      size: json['size'] ?? '',
      sizeKg: (json['size_kg'] as num?)?.toDouble() ?? 9.0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isActive: json['is_active'] ?? true,
      popular: json['popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'size': size,
        'size_kg': sizeKg,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'is_active': isActive,
        'popular': popular,
      };
}
