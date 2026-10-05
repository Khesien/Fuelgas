import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../common/app_avatar.dart';
import '../common/glass_container.dart';
import '../common/role_switch_sheet.dart';
import 'driver_delivery_screen.dart';

class DriverJobsScreen extends StatefulWidget {
  const DriverJobsScreen({super.key});

  @override
  State<DriverJobsScreen> createState() => _DriverJobsScreenState();
}

class _DriverJobsScreenState extends State<DriverJobsScreen> {
  final List<String> _declinedJobIds = [];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final driver = state.activeDriver;

    if (driver == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Driver Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const RoleSwitchSheet(),
                );
              },
              icon: const Icon(Icons.swap_horiz, color: AppColors.brandCyan),
            ),
          ],
        ),
        body: const Center(
          child: Text(
            'No driver profile found.\nPlease register or log in as a driver.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Active order assigned to this driver
    OrderModel? activeOrder;
    try {
      activeOrder = state.orders.firstWhere(
        (o) => o.driverId == driver.driverId && o.status == 'out_for_delivery',
      );
    } catch (_) {}

    // Incoming pending orders
    final availableJobs = state.orders
        .where((o) =>
            (o.status == 'confirmed' || o.status == 'preparing') &&
            o.driverId == null &&
            !_declinedJobIds.contains(o.orderId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AppAvatar(
              name: driver.fullName,
              imageUrl: driver.photoUrl,
              radius: 16,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.fullName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                Text('${driver.vehicleType} • ${driver.vehicleNumber}',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          // Online / Offline Toggle
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => state.toggleDriverStatus(driver.driverId),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: driver.status == 'online'
                      ? AppColors.brandGreen.withOpacity(0.15)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: driver.status == 'online'
                        ? AppColors.brandGreen
                        : AppColors.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: driver.status == 'online'
                            ? AppColors.brandGreen
                            : Colors.white38,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driver.status == 'online' ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        color: driver.status == 'online'
                            ? AppColors.brandGreen
                            : Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const RoleSwitchSheet(),
              );
            },
            icon: const Icon(Icons.swap_horiz, color: AppColors.brandCyan),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Delivery Banner
              if (activeOrder != null) ...[
                const Text(
                  'ACTIVE ASSIGNED TRIP',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _buildActiveOrderCard(context, activeOrder),
                const SizedBox(height: 20),
              ],

              // Driver Quick Stats
              _buildDriverStatsRow(driver, state),
              const SizedBox(height: 20),

              // Available Jobs Dispatch Queue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DISPATCH RADAR (NEW JOBS)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${availableJobs.length} Available',
                      style: const TextStyle(
                        color: AppColors.brandCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (availableJobs.isEmpty)
                _buildEmptyRadar()
              else
                ...availableJobs.map((job) => _buildJobCard(context, state, job)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard(BuildContext context, OrderModel order) {
    return GlassContainer(
      backgroundColor: const Color(0xFF1E293B),
      borderColor: AppColors.brandCyan,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.navigation,
                      color: AppColors.brandCyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Trip ${order.humanId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandCyan.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'EN ROUTE',
                  style: TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Deliver to: ${order.user?.fullName ?? 'Customer'}',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          Text(
            '${order.address?.plotUnit}, ${order.address?.street}, ${order.address?.district}',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverDeliveryScreen(order: order),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Open Fulfilment Screen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandCyan,
                foregroundColor: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatsRow(dynamic driver, AppStateProvider state) {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TODAY EARNINGS',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '${state.currency}185.00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
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
                const Text('ACCEPTANCE RATE',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(
                  '98.5%',
                  style: TextStyle(
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

  Widget _buildEmptyRadar() {
    return GlassContainer(
      padding: const EdgeInsets.all(28),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.radar, color: AppColors.textMuted, size: 40),
            SizedBox(height: 12),
            Text(
              'Radar Active & Scanning',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'New customer gas refill orders will appear here automatically.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(
      BuildContext context, AppStateProvider state, OrderModel job) {
    final driverPayout = job.deliveryFee + 10.0; // delivery fee + bonus

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.brandOrange.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEW DELIVERY JOB',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                'Payout: ${state.currency}${driverPayout.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.brandGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pickup Depot
          Row(
            children: [
              const Icon(Icons.storefront,
                  color: Color(0xFF3B82F6), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pickup: ${job.depot?.name ?? 'Main Depot'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Customer Dropoff
          Row(
            children: [
              const Icon(Icons.home, color: AppColors.brandGreen, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dropoff: ${job.address?.fullAddress ?? 'Customer Address'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Cylinder payload
          Row(
            children: [
              const Icon(Icons.propane_tank,
                  color: AppColors.brandOrange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payload: ${job.items.firstOrNull?.quantity ?? 1}x ${job.items.firstOrNull?.product.name ?? '9KG Cylinder'} (${job.orderType})',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Actions: Accept / Decline
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _declinedJobIds.add(job.orderId));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: AppColors.borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    state.acceptJob(job.orderId, state.activeDriverId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DriverDeliveryScreen(order: job),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Accept Trip'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
