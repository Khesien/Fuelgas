import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../common/glass_container.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final driver = state.activeDriver;

    if (driver == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No driver profile found.\nPlease log in as a driver.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Only real completed deliveries from Supabase-loaded orders
    final completedOrders = state.orders
        .where((o) => o.driverId == driver.driverId && o.status == 'delivered')
        .toList();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    final todayOrders = completedOrders
        .where((o) => o.updatedAt.isAfter(todayStart))
        .toList();
    final weekOrders = completedOrders
        .where((o) => o.updatedAt.isAfter(weekStart))
        .toList();

    // Earnings = delivery fee portion paid to driver (configurable in production)
    final double todayEarnings =
        todayOrders.fold(0.0, (sum, o) => sum + o.deliveryFee);
    final double weeklyEarnings =
        weekOrders.fold(0.0, (sum, o) => sum + o.deliveryFee);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Wallet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Earnings Gradient Card
              _buildEarningsHeroCard(
                state: state,
                todayEarnings: todayEarnings,
                weeklyEarnings: weeklyEarnings,
                completedCount: driver.completedOrders,
                todayCount: todayOrders.length,
              ),
              const SizedBox(height: 16),

              // Payout Action Bar
              _buildPayoutButton(context, todayEarnings),
              const SizedBox(height: 16),

              // Metrics Row: Rating & Completion
              _buildMetricsRow(driver, completedOrders.length),
              const SizedBox(height: 20),

              // Delivered trips ledger
              const Text(
                'DELIVERY HISTORY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              _buildLedgerList(state, completedOrders),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsHeroCard({
    required AppStateProvider state,
    required double todayEarnings,
    required double weeklyEarnings,
    required int completedCount,
    required int todayCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandOrange.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S EARNINGS",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${state.currency}${todayEarnings.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '$todayCount deliveries today',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('THIS WEEK',
                        style:
                            TextStyle(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      '${state.currency}${weeklyEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL TRIPS',
                        style:
                            TextStyle(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      '$completedCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutButton(BuildContext context, double amount) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: amount > 0
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Payout request submitted. Funds will be transferred to your mobile wallet.'),
                    backgroundColor: AppColors.brandGreen,
                  ),
                );
              }
            : null,
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('Request Payout (Orange Money / MyZaka)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandCyan,
          foregroundColor: AppColors.textDark,
          disabledBackgroundColor: AppColors.brandCyan.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(dynamic driver, int sessionCompleted) {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CUSTOMER RATING',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.brandAmber, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      driver.ratingAvg.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL COMPLETED',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '${driver.completedOrders}',
                  style: const TextStyle(
                    color: AppColors.brandGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerList(
      AppStateProvider state, List<OrderModel> completedOrders) {
    if (completedOrders.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  color: AppColors.textMuted, size: 36),
              SizedBox(height: 12),
              Text(
                'No completed deliveries yet.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'Completed trips will appear here.',
                style:
                    TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: completedOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final o = completedOrders[idx];
        final formattedTime =
            DateFormat('dd MMM • h:mm a').format(o.updatedAt);

        return GlassContainer(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_downward,
                        color: AppColors.brandGreen, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.humanId,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800),
                      ),
                      Text(
                        o.address?.district ?? 'Delivery',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${state.currency}${o.deliveryFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.brandGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
