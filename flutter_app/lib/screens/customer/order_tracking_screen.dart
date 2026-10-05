import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../common/app_avatar.dart';
import '../common/glass_container.dart';
import '../common/live_tracking_map_widget.dart';
import '../common/status_badge.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Watch for live updates of this order from state / Supabase
    final liveOrder = state.orders.firstWhere(
      (o) => o.orderId == order.orderId,
      orElse: () => order,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Track ${liveOrder.humanId}',
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
              // Live Interactive GPS Map Tracker
              LiveTrackingMapWidget(
                driver: liveOrder.driver,
                address: liveOrder.address,
                depot: liveOrder.depot,
                status: liveOrder.status,
                etaMinutes: liveOrder.etaMinutes,
                height: 230,
              ),
              const SizedBox(height: 16),

              // OTP Security Code Banner
              _buildOtpCard(liveOrder),
              const SizedBox(height: 16),

              // Driver Contact & Vehicle Info
              if (liveOrder.driver != null) ...[
                _buildDriverCard(context, liveOrder.driver!),
                const SizedBox(height: 16),
              ],

              // Order Life Cycle Stepper
              _buildDeliveryProgressStepper(liveOrder),
              const SizedBox(height: 16),

              // Order Items & Pricing Breakdown
              _buildOrderSummaryCard(state, liveOrder),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpCard(OrderModel order) {
    return GlassContainer(
      backgroundColor: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DELIVERY VERIFICATION OTP',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Share code with driver upon cylinder check',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brandOrange),
            ),
            child: Text(
              order.otpCode,
              style: const TextStyle(
                color: AppColors.brandOrange,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, dynamic driver) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AppAvatar(
            name: driver.fullName,
            imageUrl: driver.photoUrl,
            radius: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${driver.vehicleType} • ${driver.vehicleNumber}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.brandAmber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.ratingAvg}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${driver.completedOrders} deliveries',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling driver ${driver.fullName}...'),
                  backgroundColor: AppColors.brandOrange,
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.brandOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryProgressStepper(OrderModel order) {
    final steps = [
      {'status': 'confirmed', 'title': 'Order Confirmed', 'desc': 'Payment authorized'},
      {'status': 'preparing', 'title': 'Preparing at Depot', 'desc': 'Cylinder inspected & tagged'},
      {'status': 'out_for_delivery', 'title': 'Out for Delivery', 'desc': 'Driver en route to your address'},
      {'status': 'delivered', 'title': 'Delivered & Connected', 'desc': 'Safety leak test completed'},
    ];

    int currentIdx = 0;
    if (order.status == 'confirmed') currentIdx = 0;
    if (order.status == 'preparing') currentIdx = 1;
    if (order.status == 'out_for_delivery') currentIdx = 2;
    if (order.status == 'delivered') currentIdx = 3;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY STATUS TIMELINE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(steps.length, (idx) {
            final isDone = idx <= currentIdx;
            final isCurrent = idx == currentIdx;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.brandOrange
                            : Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white38,
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                    ),
                    if (idx < steps.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: idx < currentIdx
                            ? AppColors.brandOrange
                            : Colors.white12,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[idx]['title']!,
                        style: TextStyle(
                          color: isCurrent
                              ? AppColors.brandOrange
                              : (isDone ? Colors.white : AppColors.textMuted),
                          fontSize: 13,
                          fontWeight:
                              isCurrent ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      Text(
                        steps[idx]['desc']!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(AppStateProvider state, OrderModel order) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORDER DETAILS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${order.paymentMethod.toUpperCase()} (${order.paymentStatus})',
                style: const TextStyle(
                  color: AppColors.brandCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${it.quantity}x ${it.product.name} (${order.orderType})',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  Text(
                    '${state.currency}${it.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.borderColor, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Paid',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                '${state.currency}${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.brandOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
