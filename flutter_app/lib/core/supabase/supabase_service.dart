import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;

  bool get isReady => _isInitialized && _client != null;
  SupabaseClient? get client => _client;

  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[Supabase] No credentials configured. Running in Mock/Offline Mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('[Supabase] Successfully connected to Supabase.');
    } catch (e) {
      debugPrint('[Supabase] Initialization error: $e. Falling back to Mock Mode.');
    }
  }

  // --- Realtime Streams ---

  Stream<List<Map<String, dynamic>>>? streamActiveOrders(String? userId) {
    if (!isReady) return null;
    try {
      var query = _client!.from('orders').stream(primaryKey: ['order_id']);
      if (userId != null) {
        return query.eq('user_id', userId);
      }
      return query;
    } catch (e) {
      debugPrint('[Supabase] Stream orders error: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>>? streamDriverLocation(String driverId) {
    if (!isReady) return null;
    try {
      return _client!
          .from('drivers')
          .stream(primaryKey: ['driver_id'])
          .eq('driver_id', driverId);
    } catch (e) {
      debugPrint('[Supabase] Stream driver error: $e');
      return null;
    }
  }

  // --- Order Mutations ---

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? note,
  }) async {
    if (!isReady) return;
    try {
      await _client!.from('orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('order_id', orderId);

      if (note != null) {
        await _client!.from('order_status_logs').insert({
          'order_id': orderId,
          'status': status,
          'note': note,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('[Supabase] Update order status failed: $e');
    }
  }

  Future<void> updateDriverLocation({
    required String driverId,
    required double lat,
    required double lng,
  }) async {
    if (!isReady) return;
    try {
      await _client!.from('drivers').update({
        'current_lat': lat,
        'current_lng': lng,
      }).eq('driver_id', driverId);
    } catch (e) {
      debugPrint('[Supabase] Update driver location failed: $e');
    }
  }
}
