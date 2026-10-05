import 'address_model.dart';
import 'depot_model.dart';
import 'driver_model.dart';
import 'product_model.dart';
import 'provider_model.dart';
import 'user_model.dart';

class OrderItemModel {
  final String orderItemId;
  final String orderId;
  final String productId;
  final CylinderProductModel product;
  final int quantity;
  final String orderType; // 'refill' | 'exchange'
  final double unitPrice;
  final double totalPrice;

  OrderItemModel({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.orderType,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: json['order_item_id'] ?? '',
      orderId: json['order_id'] ?? '',
      productId: json['product_id'] ?? '',
      product: json['product'] != null
          ? CylinderProductModel.fromJson(json['product'])
          : CylinderProductModel(
              productId: json['product_id'] ?? 'prod-9kg',
              size: '9KG',
              sizeKg: 9.0,
              name: '9KG Household Standard',
              description: '',
              imageUrl: '',
            ),
      quantity: json['quantity'] ?? 1,
      orderType: json['order_type'] ?? 'exchange',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_item_id': orderItemId,
        'order_id': orderId,
        'product_id': productId,
        'product': product.toJson(),
        'quantity': quantity,
        'order_type': orderType,
        'unit_price': unitPrice,
        'total_price': totalPrice,
      };
}

class OrderStatusLogModel {
  final String logId;
  final String orderId;
  final String status;
  final String? note;
  final DateTime timestamp;

  OrderStatusLogModel({
    required this.logId,
    required this.orderId,
    required this.status,
    this.note,
    required this.timestamp,
  });

  factory OrderStatusLogModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusLogModel(
      logId: json['log_id'] ?? '',
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? 'confirmed',
      note: json['note'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'log_id': logId,
        'order_id': orderId,
        'status': status,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };
}

class OrderModel {
  final String orderId;
  final String humanId;
  final String userId;
  final UserModel? user;
  final String providerId;
  final GasProviderModel? provider;
  final String addressId;
  final AddressModel? address;
  final String? driverId;
  final DriverModel? driver;
  final String depotId;
  final DepotModel? depot;
  final List<OrderItemModel> items;
  final String orderType; // 'refill' | 'exchange'
  final String status; // 'pending_payment' | 'confirmed' | 'preparing' | 'out_for_delivery' | 'delivered' | 'cancelled'
  final String paymentMethod;
  final String? paymentProvider;
  final String paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final String? promoCode;
  final double totalAmount;
  final int etaMinutes;
  final String otpCode;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderStatusLogModel> statusHistory;

  OrderModel({
    required this.orderId,
    required this.humanId,
    required this.userId,
    this.user,
    required this.providerId,
    this.provider,
    required this.addressId,
    this.address,
    this.driverId,
    this.driver,
    required this.depotId,
    this.depot,
    required this.items,
    required this.orderType,
    required this.status,
    required this.paymentMethod,
    this.paymentProvider,
    this.paymentStatus = 'completed',
    required this.subtotal,
    required this.deliveryFee,
    this.discountAmount = 0.0,
    this.promoCode,
    required this.totalAmount,
    this.etaMinutes = 25,
    this.otpCode = '8942',
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.statusHistory = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? '',
      humanId: json['human_id'] ?? '',
      userId: json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      providerId: json['provider_id'] ?? '',
      provider: json['provider'] != null
          ? GasProviderModel.fromJson(json['provider'])
          : null,
      addressId: json['address_id'] ?? '',
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
      driverId: json['driver_id'],
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'])
          : null,
      depotId: json['depot_id'] ?? '',
      depot: json['depot'] != null ? DepotModel.fromJson(json['depot']) : null,
      items: (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      orderType: json['order_type'] ?? 'exchange',
      status: json['status'] ?? 'confirmed',
      paymentMethod: json['payment_method'] ?? 'mobile_money',
      paymentProvider: json['payment_provider'],
      paymentStatus: json['payment_status'] ?? 'completed',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 25.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      promoCode: json['promo_code'],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      etaMinutes: json['eta_minutes'] ?? 25,
      otpCode: json['otp_code'] ?? '8942',
      cancellationReason: json['cancellation_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      statusHistory: (json['status_history'] as List?)
              ?.map((log) => OrderStatusLogModel.fromJson(log))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'human_id': humanId,
        'user_id': userId,
        'user': user?.toJson(),
        'provider_id': providerId,
        'provider': provider?.toJson(),
        'address_id': addressId,
        'address': address?.toJson(),
        'driver_id': driverId,
        'driver': driver?.toJson(),
        'depot_id': depotId,
        'depot': depot?.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'order_type': orderType,
        'status': status,
        'payment_method': paymentMethod,
        'payment_provider': paymentProvider,
        'payment_status': paymentStatus,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'discount_amount': discountAmount,
        'promo_code': promoCode,
        'total_amount': totalAmount,
        'eta_minutes': etaMinutes,
        'otp_code': otpCode,
        'cancellation_reason': cancellationReason,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'status_history': statusHistory.map((e) => e.toJson()).toList(),
      };

  OrderModel copyWith({
    String? status,
    String? driverId,
    DriverModel? driver,
    int? etaMinutes,
    List<OrderStatusLogModel>? statusHistory,
    String? cancellationReason,
  }) {
    return OrderModel(
      orderId: orderId,
      humanId: humanId,
      userId: userId,
      user: user,
      providerId: providerId,
      provider: provider,
      addressId: addressId,
      address: address,
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      depotId: depotId,
      depot: depot,
      items: items,
      orderType: orderType,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentProvider: paymentProvider,
      paymentStatus: paymentStatus,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
      promoCode: promoCode,
      totalAmount: totalAmount,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      otpCode: otpCode,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}
