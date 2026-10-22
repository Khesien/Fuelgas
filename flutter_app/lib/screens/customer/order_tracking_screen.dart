import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../common/app_avatar.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Track ${liveOrder.humanId}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StatusBadge(status: liveOrder.status)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tileBlueBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DELIVERY VERIFICATION OTP',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Share code with driver upon cylinder check',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBlue, width: 1.5),
            ),
            child: Text(
              order.otpCode,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryBlue,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
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
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${driver.vehicleType} • ${driver.vehicleNumber}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.flameAmber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.ratingAvg}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${driver.completedOrders} deliveries',
                      style: GoogleFonts.plusJakartaSans(
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
                SnackBar(content: Text('Calling ${driver.phone}...')),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.tileBlueBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone,
                  color: AppColors.primaryBlue, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryProgressStepper(OrderModel order) {
    final steps = [
      {'status': 'confirmed', 'title': 'Order Confirmed', 'desc': 'Depot preparing'},
      {'status': 'preparing', 'title': 'Filled & Inspected', 'desc': 'Safety checked'},
      {'status': 'out_for_delivery', 'title': 'On The Way', 'desc': 'Driver en route'},
      {'status': 'delivered', 'title': 'Delivered', 'desc': 'Enjoy your cooking gas'},
    ];

    final statusOrder = ['pending_payment', 'confirmed', 'preparing', 'out_for_delivery', 'delivered'];
    final currentIdx = statusOrder.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DELIVERY STATUS',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final stepIdx = statusOrder.indexOf(step['status']!);
            final isDone = currentIdx >= stepIdx;
            final isCurrent = currentIdx == stepIdx;

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
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? AppColors.primaryBlue
                              : AppColors.borderColor,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 28,
                        color: isDone
                            ? AppColors.primaryBlue
                            : AppColors.borderColor,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: GoogleFonts.plusJakartaSans(
                            color: isDone
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        Text(
                          step['desc']!,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER DETAILS',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.quantity}x ${item.product.name} (${order.orderType})',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${state.currency}${item.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderColor, thickness: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${state.currency}${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryBlue,
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
