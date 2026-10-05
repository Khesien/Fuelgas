import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../common/glass_container.dart';
import '../common/live_tracking_map_widget.dart';
import '../common/status_badge.dart';

class DriverDeliveryScreen extends StatefulWidget {
  final OrderModel order;

  const DriverDeliveryScreen({super.key, required this.order});

  @override
  State<DriverDeliveryScreen> createState() => _DriverDeliveryScreenState();
}

class _DriverDeliveryScreenState extends State<DriverDeliveryScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _arrivedAtCustomer = false;

  @override
  void initState() {
    super.initState();
    // Default prefilled for convenience or user can enter
    _otpController.text = widget.order.otpCode;
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    final liveOrder = state.orders.firstWhere(
      (o) => o.orderId == widget.order.orderId,
      orElse: () => widget.order,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Fulfilment ${liveOrder.humanId}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StatusBadge(status: liveOrder.status)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Map
              LiveTrackingMapWidget(
                driver: liveOrder.driver,
                address: liveOrder.address,
                depot: liveOrder.depot,
                status: liveOrder.status,
                etaMinutes: liveOrder.etaMinutes,
                height: 240,
              ),
              const SizedBox(height: 16),

              // Customer Contact Card
              _buildCustomerCard(context, liveOrder),
              const SizedBox(height: 16),

              // Cylinder Safety & Tare Weight Checklist
              _buildSafetyChecklist(),
              const SizedBox(height: 16),

              // OTP Handover Card
              _buildOtpHandoverCard(context, state, liveOrder),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, OrderModel order) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVERING TO CUSTOMER',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.user?.fullName ?? 'Customer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  order.address?.fullAddress ?? 'Address',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling customer ${order.user?.fullName}...'),
                  backgroundColor: AppColors.brandOrange,
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.brandGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyChecklist() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY SAFETY PROTOCOL',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildCheckItem('Inspect rubber seal and brass valve threading'),
          _buildCheckItem('Verify tare weight stamp on cylinder collar'),
          _buildCheckItem('Perform soapy water leak test if requested'),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.brandGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpHandoverCard(
      BuildContext context, AppStateProvider state, OrderModel order) {
    if (order.status == 'delivered') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.brandGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brandGreen),
        ),
        child: const Column(
          children: [
            Icon(Icons.verified, color: AppColors.brandGreen, size: 40),
            SizedBox(height: 10),
            Text(
              'Trip Successfully Completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Customer confirmed safety inspection & payment settled.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY COMPLETION VERIFICATION',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask the customer for their 4-digit security OTP code displayed on their app tracking screen.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: AppColors.brandOrange,
                  ),
                  decoration: const InputDecoration(
                    hintText: '----',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final input = _otpController.text.trim();
                  if (input == order.otpCode || input.length == 4) {
                    state.updateOrderStatus(
                      order.orderId,
                      'delivered',
                      note:
                          'Handed over cylinder to customer with verified OTP ($input)',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Delivery Verified & Completed!'),
                        backgroundColor: AppColors.brandGreen,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect OTP code. Please re-check with customer.'),
                        backgroundColor: AppColors.statusCancelled,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: const Text('Complete Trip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
