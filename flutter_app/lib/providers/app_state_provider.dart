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

/// Central application state provider.
/// All data is loaded from Supabase — there is no demo or mock data.
class AppStateProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();

  // ── App Role ──────────────────────────────────────────────────────────────
  UserRole _activeRole = UserRole.customer;
  UserRole get activeRole => _activeRole;

  // ── Loading / Error State ─────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Current Authenticated User ────────────────────────────────────────────
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Districts & Locations ─────────────────────────────────────────────────
  final List<String> _districts = AppConstants.districts;
  List<String> get districts => _districts;

  String _activeDistrict = AppConstants.districts.first;
  String get activeDistrict => _activeDistrict;

  // ── Gas Providers ─────────────────────────────────────────────────────────
  List<GasProviderModel> _providers = [];
  List<GasProviderModel> get providers => _providers;

  String? _selectedProviderId;
  String? get selectedProviderId => _selectedProviderId;

  GasProviderModel? get selectedProvider {
    if (_selectedProviderId == null || _providers.isEmpty) return null;
    try {
      return _providers.firstWhere((p) => p.providerId == _selectedProviderId);
    } catch (_) {
      return _providers.isNotEmpty ? _providers.first : null;
    }
  }

  // ── Addresses ─────────────────────────────────────────────────────────────
  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  String? _selectedAddressId;
  String? get selectedAddressId => _selectedAddressId;

  AddressModel? get selectedAddress {
    if (_selectedAddressId == null || _addresses.isEmpty) return null;
    try {
      return _addresses.firstWhere((a) => a.addressId == _selectedAddressId);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  // ── Products ──────────────────────────────────────────────────────────────
  List<CylinderProductModel> _products = [];
  List<CylinderProductModel> get products => _products;

  // ── Depots ────────────────────────────────────────────────────────────────
  List<DepotModel> _depots = [];
  List<DepotModel> get depots => _depots;

  // ── Drivers ───────────────────────────────────────────────────────────────
  List<DriverModel> _drivers = [];
  List<DriverModel> get drivers => _drivers;

  String? _activeDriverId;
  String? get activeDriverId => _activeDriverId;

  DriverModel? get activeDriver {
    if (_activeDriverId == null || _drivers.isEmpty) return null;
    try {
      return _drivers.firstWhere((d) => d.driverId == _activeDriverId);
    } catch (_) {
      return _drivers.isNotEmpty ? _drivers.first : null;
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────────
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  OrderModel? get activeTrackingOrder {
    try {
      return _orders.firstWhere(
        (o) => o.status != 'delivered' && o.status != 'cancelled',
      );
    } catch (_) {
      return null;
    }
  }

  // ── Promotions ────────────────────────────────────────────────────────────
  List<PromotionModel> _promotions = [];
  List<PromotionModel> get promotions => _promotions;

  // ── Realtime GPS ticker ───────────────────────────────────────────────────
  Timer? _gpsMovementTimer;
  StreamSubscription? _ordersSubscription;
  StreamSubscription? _driverSubscription;

  AppStateProvider() {
    // Nothing is loaded until the user authenticates.
    // Call loadUserData(userId) after login.
  }

  @override
  void dispose() {
    _gpsMovementTimer?.cancel();
    _ordersSubscription?.cancel();
    _driverSubscription?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH — Called by auth screens after Supabase sign-in
  // ══════════════════════════════════════════════════════════════════════════

  /// Load all user-specific data from Supabase after a successful login.
  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_supabase.isReady) {
        _isLoading = false;
        _errorMessage = 'Not connected to Supabase. Please configure credentials.';
        notifyListeners();
        return;
      }

      // Load user profile
      final userRow = await _supabase.client!
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (userRow != null) {
        _currentUser = UserModel.fromJson(userRow);
      }

      // Load addresses
      final addrRows = await _supabase.client!
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);
      _addresses = (addrRows as List).map((r) => AddressModel.fromJson(r)).toList();
      if (_addresses.isNotEmpty) {
        _selectedAddressId = _addresses.first.addressId;
        _activeDistrict = _addresses.first.district;
      }

      // Load platform data (providers, products, promotions)
      await _loadPlatformData();

      // Load user's order history
      await _loadOrders(userId);

      // Set up Supabase realtime subscriptions
      _subscribeToOrders(userId);

    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      debugPrint('[AppState] loadUserData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load driver-specific data from Supabase after driver login.
  Future<void> loadDriverData(String driverId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_supabase.isReady) {
        _isLoading = false;
        _errorMessage = 'Not connected to Supabase. Please configure credentials.';
        notifyListeners();
        return;
      }

      final driverRow = await _supabase.client!
          .from('drivers')
          .select()
          .eq('driver_id', driverId)
          .maybeSingle();

      if (driverRow != null) {
        _drivers = [DriverModel.fromJson(driverRow)];
        _activeDriverId = driverId;
      }

      // Load all active/pending orders for this driver's provider
      final orderRows = await _supabase.client!
          .from('orders')
          .select('*, users(*), providers(*), addresses(*), depots(*), drivers(*), order_items(*, products(*)), order_status_logs(*)')
          .inFilter('status', ['confirmed', 'preparing', 'out_for_delivery'])
          .order('created_at', ascending: false);
      _orders = (orderRows as List).map((r) => OrderModel.fromJson(r)).toList();

      _subscribeToDriverOrders(driverId);

    } catch (e) {
      _errorMessage = 'Failed to load driver data: ${e.toString()}';
      debugPrint('[AppState] loadDriverData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sign out — clear all state.
  void signOut() {
    _currentUser = null;
    _addresses = [];
    _orders = [];
    _drivers = [];
    _products = [];
    _providers = [];
    _depots = [];
    _promotions = [];
    _selectedProviderId = null;
    _selectedAddressId = null;
    _activeDriverId = null;
    _ordersSubscription?.cancel();
    _driverSubscription?.cancel();
    _gpsMovementTimer?.cancel();
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE — Platform data loading
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _loadPlatformData() async {
    // Products
    final productRows = await _supabase.client!
        .from('products')
        .select()
        .order('size_kg', ascending: true);
    _products = (productRows as List)
        .map((r) => CylinderProductModel.fromJson(r))
        .toList();

    // Providers (with pricing)
    final providerRows = await _supabase.client!
        .from('providers')
        .select('*, provider_prices(*)')
        .eq('compliance_status', 'approved')
        .order('rating', ascending: false);
    _providers = (providerRows as List)
        .map((r) => GasProviderModel.fromJson(r))
        .toList();

    if (_providers.isNotEmpty) {
      _selectedProviderId = _providers.first.providerId;
    }

    // Depots
    final depotRows = await _supabase.client!
        .from('depots')
        .select('*, depot_stock(*)');
    _depots = (depotRows as List).map((r) => DepotModel.fromJson(r)).toList();

    // Active promotions
    final promoRows = await _supabase.client!
        .from('promotions')
        .select()
        .eq('is_active', true)
        .gte('valid_until', DateTime.now().toIso8601String());
    _promotions = (promoRows as List)
        .map((r) => PromotionModel.fromJson(r))
        .toList();
  }

  Future<void> _loadOrders(String userId) async {
    final orderRows = await _supabase.client!
        .from('orders')
        .select('*, users(*), providers(*), addresses(*), depots(*), drivers(*), order_items(*, products(*)), order_status_logs(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    _orders = (orderRows as List).map((r) => OrderModel.fromJson(r)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REALTIME SUBSCRIPTIONS
  // ══════════════════════════════════════════════════════════════════════════

  void _subscribeToOrders(String userId) {
    final stream = _supabase.streamActiveOrders(userId);
    if (stream == null) return;
    _ordersSubscription = stream.listen((rows) {
      final updated = rows.map((r) => OrderModel.fromJson(r)).toList();
      // Merge realtime updates into local order list
      for (final upd in updated) {
        final idx = _orders.indexWhere((o) => o.orderId == upd.orderId);
        if (idx != -1) {
          _orders[idx] = upd;
        } else {
          _orders.insert(0, upd);
        }
      }
      notifyListeners();
    });
  }

  void _subscribeToDriverOrders(String driverId) {
    final stream = _supabase.streamDriverLocation(driverId);
    if (stream == null) return;
    _driverSubscription = stream.listen((rows) {
      if (rows.isNotEmpty) {
        final updatedDriver = DriverModel.fromJson(rows.first);
        final idx = _drivers.indexWhere((d) => d.driverId == driverId);
        if (idx != -1) {
          _drivers[idx] = updatedDriver;
        } else {
          _drivers = [updatedDriver];
        }
        notifyListeners();
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ROLE & LOCATION
  // ══════════════════════════════════════════════════════════════════════════

  void setActiveRole(UserRole role) {
    _activeRole = role;
    notifyListeners();
  }

  void setActiveDistrict(String district) {
    _activeDistrict = district;
    final available = _providers.where((p) =>
        p.complianceStatus == 'approved' &&
        p.districtsServed.contains(district)).toList();
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
    final addr = _addresses.firstWhere(
      (a) => a.addressId == addressId,
      orElse: () => _addresses.first,
    );
    _activeDistrict = addr.district;
    notifyListeners();
  }

  Future<void> addAddress(AddressModel newAddress) async {
    _addresses.insert(0, newAddress);
    _selectedAddressId = newAddress.addressId;
    _activeDistrict = newAddress.district;
    notifyListeners();

    // Persist to Supabase
    if (_supabase.isReady) {
      try {
        await _supabase.client!.from('addresses').insert(newAddress.toJson());
      } catch (e) {
        debugPrint('[AppState] addAddress Supabase error: $e');
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ORDERS
  // ══════════════════════════════════════════════════════════════════════════

  Future<OrderModel?> placeOrder({
    required String providerId,
    required List<OrderItemModel> items,
    required String orderType,
    required String paymentMethod,
    String? paymentProvider,
    String? promoCode,
    double discountAmount = 0.0,
    required String addressId,
  }) async {
    if (_currentUser == null) return null;

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
      userId: _currentUser!.userId,
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
          note: 'Order confirmed with ${provider.companyName} via $paymentMethod',
          timestamp: DateTime.now(),
        ),
      ],
    );

    _orders.insert(0, newOrder);
    notifyListeners();

    // Persist to Supabase
    if (_supabase.isReady) {
      try {
        await _supabase.client!.from('orders').insert(newOrder.toJson());
      } catch (e) {
        debugPrint('[AppState] placeOrder Supabase error: $e');
      }
    }

    return newOrder;
  }

  void acceptJob(String orderId, String driverId) {
    if (activeDriver == null) return;
    final driver = activeDriver!;

    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      final old = _orders[idx];
      final updatedHistory = List<OrderStatusLogModel>.from(old.statusHistory)
        ..add(OrderStatusLogModel(
          logId: 'log-${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          status: 'out_for_delivery',
          note: 'Driver accepted job and is en route',
          timestamp: DateTime.now(),
        ));

      _orders[idx] = old.copyWith(
        status: 'out_for_delivery',
        driverId: driver.driverId,
        driver: driver,
        statusHistory: updatedHistory,
      );
      notifyListeners();

      _supabase.updateOrderStatus(
        orderId: orderId,
        status: 'out_for_delivery',
        note: 'Driver accepted job',
      );
    }
  }

  void updateOrderStatus(String orderId, String newStatus, {String? note}) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      final old = _orders[idx];
      final updatedHistory = List<OrderStatusLogModel>.from(old.statusHistory)
        ..add(OrderStatusLogModel(
          logId: 'log-${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          status: newStatus,
          note: note ?? 'Status updated to $newStatus',
          timestamp: DateTime.now(),
        ));

      _orders[idx] = old.copyWith(
        status: newStatus,
        statusHistory: updatedHistory,
      );

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

  void toggleDriverStatus(String driverId) {
    final idx = _drivers.indexWhere((d) => d.driverId == driverId);
    if (idx != -1) {
      final current = _drivers[idx];
      final nextStatus = current.status == 'online' ? 'offline' : 'online';
      _drivers[idx] = current.copyWith(status: nextStatus);
      notifyListeners();

      if (_supabase.isReady) {
        _supabase.client!
            .from('drivers')
            .update({'status': nextStatus}).eq('driver_id', driverId);
      }
    }
  }

  void updateDepotStock(String depotId, String productId, int newQty) {
    final idx = _depots.indexWhere((d) => d.depotId == depotId);
    if (idx != -1) {
      final updatedStock = Map<String, int>.from(_depots[idx].stock);
      updatedStock[productId] = max(0, newQty);
      _depots[idx] = _depots[idx].copyWith(stock: updatedStock);
      notifyListeners();

      if (_supabase.isReady) {
        _supabase.client!.from('depot_stock').upsert({
          'depot_id': depotId,
          'product_id': productId,
          'quantity': max(0, newQty),
        });
      }
    }
  }
}
