import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/provider_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
import '../common/app_avatar.dart';
import '../common/glass_container.dart';
import '../common/role_switch_sheet.dart';
import 'cylinder_selection_screen.dart';
import 'order_tracking_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final activeOrder = state.activeTrackingOrder;

    final availableProviders = state.providers
        .where((p) =>
            p.complianceStatus == 'approved' &&
            p.districtsServed.contains(state.activeDistrict))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Location & Role Switcher Bar
              _buildTopBar(context, state),
              const SizedBox(height: 16),

              // Active Delivery Banner (if any)
              if (activeOrder != null && activeOrder.status != 'delivered')
                _buildActiveDeliveryBanner(context, activeOrder),

              const SizedBox(height: 16),

              // Hero Promotional Banner
              _buildPromoBanner(context),
              const SizedBox(height: 24),

              // Verified Gas Providers Section
              _buildSectionHeader(
                title: 'Certified Gas Providers',
                subtitle: 'Serving ${state.activeDistrict}',
              ),
              const SizedBox(height: 12),
              _buildProvidersList(context, state, availableProviders),
              const SizedBox(height: 24),

              // Cylinder Catalog Grid
              _buildSectionHeader(
                title: 'Select Cylinder Size',
                subtitle: 'Instant delivery to your doorstep',
              ),
              const SizedBox(height: 12),
              _buildCylinderGrid(context, state),
              const SizedBox(height: 24),

              // Safety Guarantee Card
              _buildSafetyCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppStateProvider state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DELIVERY DISTRICT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _showDistrictPicker(context, state),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.brandOrange, size: 18),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        state.activeDistrict,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Role Switcher Button
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const RoleSwitchSheet(),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.brandOrange.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.swap_horiz, color: AppColors.brandOrange, size: 16),
                SizedBox(width: 4),
                Text(
                  'Switch Role',
                  style: TextStyle(
                    color: AppColors.brandOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDeliveryBanner(BuildContext context, dynamic order) {
    return GlassContainer(
      backgroundColor: const Color(0xFF1E293B),
      borderColor: AppColors.brandOrange,
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(order: order),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_shipping,
                color: AppColors.brandOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Order ${order.humanId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrangeDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.status.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Estimated arrival in ~${order.etaMinutes} minutes',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final activePromo = state.promotions.isNotEmpty ? state.promotions.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFB43B00)],
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activePromo != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'CODE: ${activePromo.code}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activePromo.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  const Text(
                    'CERTIFIED LPG DELIVERY',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Safe. Fast. Doorstep Delivery.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                const Text(
                  'Certified leak testing & same-day delivery.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(
      {required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersList(BuildContext context, AppStateProvider state,
      List<GasProviderModel> providers) {
    if (providers.isEmpty) {
      return const Text('No providers currently listed for this district.');
    }

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: providers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, idx) {
          final prov = providers[idx];
          final isSelected = prov.providerId == state.selectedProviderId;

          return GestureDetector(
            onTap: () => state.setSelectedProvider(prov.providerId),
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandOrange.withOpacity(0.12)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandOrange
                      : AppColors.borderColor,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProviderLogoWidget(
                        logoUrl: prov.logoUrl,
                        companyName: prov.companyName,
                        size: 34,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prov.companyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.brandAmber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${prov.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified,
                          color: AppColors.brandCyan, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '${prov.safetyScore}% Safety',
                        style: const TextStyle(
                          color: AppColors.brandCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery: ${state.currency}${prov.baseDeliveryFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '~${prov.estDeliveryMins} mins',
                        style: const TextStyle(
                          color: AppColors.brandOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCylinderGrid(BuildContext context, AppStateProvider state) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.products.length,
      itemBuilder: (context, idx) {
        final prod = state.products[idx];
        final priceTier = state.selectedProvider.prices[prod.productId];
        final refillPrice = priceTier?.refill ?? 195.0;

        return GlassContainer(
          padding: const EdgeInsets.all(12),
          onTap: () {
            final cart = Provider.of<CartProvider>(context, listen: false);
            cart.setProduct(prod);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CylinderSelectionScreen(initialProduct: prod),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (prod.popular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              const Spacer(),
              Center(
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.propane_tank,
                      color: AppColors.brandOrange, size: 38),
                ),
              ),
              const Spacer(),
              Text(
                prod.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'From ${state.currency}${refillPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.brandOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSafetyCard() {
    return GlassContainer(
      backgroundColor: const Color(0xFF131B2E),
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Icon(Icons.verified_user, color: AppColors.brandGreen, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Certified Safety Inspection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Every cylinder is pressure tested, tare-weight verified, and sealed with tamper-evident safety caps.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDistrictPicker(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Delivery District',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...state.districts.map(
                (d) => ListTile(
                  title: Text(
                    d,
                    style: TextStyle(
                      color: d == state.activeDistrict
                          ? AppColors.brandOrange
                          : Colors.white,
                      fontWeight: d == state.activeDistrict
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: d == state.activeDistrict
                      ? const Icon(Icons.check, color: AppColors.brandOrange)
                      : null,
                  onTap: () {
                    state.setActiveDistrict(d);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
