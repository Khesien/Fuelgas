import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/supabase/supabase_service.dart';
import '../models/address_model.dart';
import '../models/depot_model.dart';
import '../models/driver_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/promotion_model.dart';
import '../models/provider_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

class AppStateProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();

  // App Role
  UserRole _activeRole = UserRole.customer;
  UserRole get activeRole => _activeRole;

  // Currency
  String _currency = AppConstants.defaultCurrency;
  String get currency => _currency;

  // Districts & Locations
  List<String> _districts = AppConstants.districts;
  List<String> get districts => _districts;

  String _activeDistrict = 'Gaborone Central';
  String get activeDistrict => _activeDistrict;

  // Multi-Tenant Gas Providers
  List<GasProviderModel> _providers = [];
  List<GasProviderModel> get providers => _providers;

  String _selectedProviderId = 'prov-1';
  String get selectedProviderId => _selectedProviderId;

  GasProviderModel get selectedProvider =>
      _providers.firstWhere(
        (p) => p.providerId == _selectedProviderId,
        orElse: () => _providers.isNotEmpty
            ? _providers.first
            : MockDataService.mockProviders.first,
      );

  // User & Addresses
  UserModel _currentUser = MockDataService.mockUser;
  UserModel get currentUser => _currentUser;

  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  String _selectedAddressId = 'addr-1';
  String get selectedAddressId => _selectedAddressId;

  AddressModel get selectedAddress =>
      _addresses.firstWhere(
        (a) => a.addressId == _selectedAddressId,
        orElse: () => _addresses.isNotEmpty
            ? _addresses.first
            : MockDataService.mockAddresses.first,
      );

  // Products, Depots, Drivers
  List<CylinderProductModel> _products = [];
  List<CylinderProductModel> get products => _products;

  List<DepotModel> _depots = [];
  List<DepotModel> get depots => _depots;

  List<DriverModel> _drivers = [];
  List<DriverModel> get drivers => _drivers;

  String _activeDriverId = 'drv-1';
  String get activeDriverId => _activeDriverId;

  DriverModel get activeDriver =>
      _drivers.firstWhere(
        (d) => d.driverId == _activeDriverId,
        orElse: () => _drivers.isNotEmpty
            ? _drivers.first
            : MockDataService.mockDrivers.first,
      );

  // Orders & Tracking
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  OrderModel? get activeTrackingOrder {
    try {
      return _orders.firstWhere(
        (o) => o.status != 'delivered' && o.status != 'cancelled',
      );
    } catch (_) {
      return _orders.isNotEmpty ? _orders.first : null;
    }
  }

  // Promotions
  List<PromotionModel> _promotions = [];
  List<PromotionModel> get promotions => _promotions;

  // Real-time Driver GPS Ticker
  Timer? _gpsMovementTimer;

  AppStateProvider() {
    _initData();
    _startDriverGpsSimulation();
  }

  @override
  void dispose() {
    _gpsMovementTimer?.cancel();
    super.dispose();
  }

  void _initData() {
    _providers = MockDataService.mockProviders;
    _addresses = MockDataService.mockAddresses;
    _products = MockDataService.mockProducts;
    _depots = MockDataService.mockDepots;
    _drivers = MockDataService.mockDrivers;
    _orders = MockDataService.mockOrders;
    _promotions = MockDataService.mockPromotions;
    notifyListeners();
  }

  // --- Role Management ---
  void setActiveRole(UserRole role) {
    _activeRole = role;
    notifyListeners();
  }

  // --- District & Location Filtering ---
  void setActiveDistrict(String district) {
    _activeDistrict = district;
    // Auto-select first provider serving this district
    final available = _providers.where(
        (p) => p.complianceStatus == 'approved' && p.districtsServed.contains(district)).toList();
    if (available.isNotEmpty) {
      _selectedProviderId = available.first.providerId;
    }
    notifyListeners();
  }

  void setSelectedProvider(String providerId) {
    _selectedProviderId = providerId;
    notifyListeners();
  }

  void setSelectedAddress(String addressId) {
    _selectedAddressId = addressId;
    final addr = _addresses.firstWhere((a) => a.addressId == addressId,
        orElse: () => _addresses.first);
    _activeDistrict = addr.district;
    notifyListeners();
  }

  void addAddress(AddressModel newAddress) {
    _addresses.insert(0, newAddress);
    _selectedAddressId = newAddress.addressId;
    _activeDistrict = newAddress.district;
    notifyListeners();
  }

  // --- Orders Engine ---
  OrderModel placeOrder({
    required String providerId,
    required List<OrderItemModel> items,
    required String orderType,
    required String paymentMethod,
    String? paymentProvider,
    String? promoCode,
    double discountAmount = 0.0,
    required String addressId,
  }) {
    final provider = _providers.firstWhere((p) => p.providerId == providerId,
        orElse: () => _providers.first);
    final address = _addresses.firstWhere((a) => a.addressId == addressId,
        orElse: () => _addresses.first);
    final depot = _depots.firstWhere((d) => d.providerId == provider.providerId,
        orElse: () => _depots.first);

    double subtotal = 0.0;
    for (var it in items) {
      subtotal += it.totalPrice;
    }

    final deliveryFee = provider.baseDeliveryFee;
    final total = max(0.0, subtotal + deliveryFee - discountAmount);
    final randNum = 10000 + Random().nextInt(90000);
    final orderId = 'ord-${DateTime.now().millisecondsSinceEpoch}';

    final newOrder = OrderModel(
      orderId: orderId,
      humanId: 'GAS-$randNum',
      userId: _currentUser.userId,
      user: _currentUser,
      providerId: provider.providerId,
      provider: provider,
      addressId: address.addressId,
      address: address,
      depotId: depot.depotId,
      depot: depot,
      items: items,
      orderType: orderType,
      status: 'confirmed',
      paymentMethod: paymentMethod,
      paymentProvider: paymentProvider ?? paymentMethod,
      paymentStatus: 'completed',
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
      promoCode: promoCode,
      totalAmount: total,
      etaMinutes: provider.estDeliveryMins,
      otpCode: '${1000 + Random().nextInt(9000)}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      statusHistory: [
        OrderStatusLogModel(
          logId: 'log-${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          status: 'confirmed',
          note:
              'Order confirmed with ${provider.companyName} via $paymentMethod',
          timestamp: DateTime.now(),
        ),
      ],
    );

    _orders.insert(0, newOrder);
    notifyListeners();

    // Sync to Supabase if connected
    if (_supabase.isReady) {
      _supabase.client?.from('orders').insert(newOrder.toJson()).catchError((e) {
        debugPrint('[AppState] Supabase insert order error: $e');
      });
    }

    return newOrder;
  }

  // Driver accepts order
  void acceptJob(String orderId, String driverId) {
    final driver = _drivers.firstWhere((d) => d.driverId == driverId,
        orElse: () => _drivers.first);

    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      final old = _orders[idx];
      final updatedHistory = List<OrderStatusLogModel>.from(old.statusHistory)
        ..add(
          OrderStatusLogModel(
            logId: 'log-${DateTime.now().millisecondsSinceEpoch}',
            orderId: orderId,
            status: 'out_for_delivery',
            note: 'Driver ${driver.fullName} accepted job & is en route',
            timestamp: DateTime.now(),
          ),
        );

      _orders[idx] = old.copyWith(
        status: 'out_for_delivery',
        driverId: driver.driverId,
        driver: driver,
        statusHistory: updatedHistory,
      );

      notifyListeners();

      // Sync Supabase
      _supabase.updateOrderStatus(
        orderId: orderId,
        status: 'out_for_delivery',
        note: 'Driver ${driver.fullName} accepted job',
      );
    }
  }

  // Update order status (preparing -> out_for_delivery -> delivered)
  void updateOrderStatus(String orderId, String newStatus, {String? note}) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      final old = _orders[idx];
      final updatedHistory = List<OrderStatusLogModel>.from(old.statusHistory)
        ..add(
          OrderStatusLogModel(
            logId: 'log-${DateTime.now().millisecondsSinceEpoch}',
            orderId: orderId,
            status: newStatus,
            note: note ?? 'Status updated to $newStatus',
            timestamp: DateTime.now(),
          ),
        );

      _orders[idx] = old.copyWith(
        status: newStatus,
        statusHistory: updatedHistory,
      );

      // Increment driver completed order count if delivered
      if (newStatus == 'delivered' && old.driverId != null) {
        final dIdx = _drivers.indexWhere((d) => d.driverId == old.driverId);
        if (dIdx != -1) {
          _drivers[dIdx] = _drivers[dIdx].copyWith(
            completedOrders: _drivers[dIdx].completedOrders + 1,
            status: 'online',
          );
        }
      }

      notifyListeners();

      _supabase.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
        note: note,
      );
    }
  }

  // Toggle driver online / offline status
  void toggleDriverStatus(String driverId) {
    final idx = _drivers.indexWhere((d) => d.driverId == driverId);
    if (idx != -1) {
      final current = _drivers[idx];
      final nextStatus = current.status == 'online' ? 'offline' : 'online';
      _drivers[idx] = current.copyWith(status: nextStatus);
      notifyListeners();
    }
  }

  // Update depot inventory (Provider Admin)
  void updateDepotStock(String depotId, String productId, int newQty) {
    final idx = _depots.indexWhere((d) => d.depotId == depotId);
    if (idx != -1) {
      final updatedStock = Map<String, int>.from(_depots[idx].stock);
      updatedStock[productId] = max(0, newQty);
      _depots[idx] = _depots[idx].copyWith(stock: updatedStock);
      notifyListeners();
    }
  }

  // Real-time GPS movement simulation of driver towards delivery address
  void _startDriverGpsSimulation() {
    _gpsMovementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final activeDeliveries = _orders
          .where((o) => o.status == 'out_for_delivery' && o.driverId != null)
          .toList();

      if (activeDeliveries.isEmpty) return;

      bool changed = false;
      for (var ord in activeDeliveries) {
        final dIdx = _drivers.indexWhere((d) => d.driverId == ord.driverId);
        if (dIdx != -1 && ord.address != null) {
          final targetLat = ord.address!.latitude;
          final targetLng = ord.address!.longitude;
          final drv = _drivers[dIdx];

          final latStep = (targetLat - drv.currentLat) * 0.08;
          final lngStep = (targetLng - drv.currentLng) * 0.08;

          _drivers[dIdx] = drv.copyWith(
            currentLat: drv.currentLat + latStep,
            currentLng: drv.currentLng + lngStep,
          );
          changed = true;
        }
      }

      if (changed) {
        notifyListeners();
      }
    });
  }
}
