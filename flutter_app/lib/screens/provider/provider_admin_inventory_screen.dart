import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../common/app_avatar.dart';
import '../common/glass_container.dart';
import '../common/role_switch_sheet.dart';

class ProviderAdminInventoryScreen extends StatefulWidget {
  const ProviderAdminInventoryScreen({super.key});

  @override
  State<ProviderAdminInventoryScreen> createState() =>
      _ProviderAdminInventoryScreenState();
}

class _ProviderAdminInventoryScreenState
    extends State<ProviderAdminInventoryScreen> {
  String _selectedDepotId = 'depot-1';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final provider = state.selectedProvider;

    final depots = state.depots
        .where((d) => d.providerId == provider.providerId)
        .toList();

    final activeDepot = state.depots.firstWhere(
      (d) => d.depotId == _selectedDepotId,
      orElse: () => state.depots.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${provider.companyName} Admin',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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
            icon: const Icon(Icons.swap_horiz, color: AppColors.statusPreparing),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compliance & Safety Header Card
              _buildComplianceCard(provider),
              const SizedBox(height: 16),

              // Depot Selector Tabs
              const Text(
                'DISTRIBUTION DEPOT HUB',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildDepotChips(depots),
              const SizedBox(height: 16),

              // Depot Location Info
              GlassContainer(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.storefront,
                        color: Color(0xFF3B82F6), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeDepot.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${activeDepot.address} • Phone: ${activeDepot.contactPhone}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Inventory Stock Levels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CYLINDER STOCK INVENTORY',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Total Units: ${activeDepot.stock.values.fold(0, (a, b) => a + b)}',
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...state.products.map(
                (p) => _buildStockRow(state, activeDepot, p),
              ),
              const SizedBox(height: 20),

              // Active Drivers Fleet Roster
              const Text(
                'ACTIVE FLEET ROSTER',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ...state.drivers.map((drv) => _buildDriverRosterTile(drv)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceCard(dynamic provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Color(0xFF818CF8), size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.companyName} • Certified',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'License: ${provider.licenseNumber} • Safety Score: ${provider.safetyScore}%',
                  style: const TextStyle(
                    color: Color(0xFFC7D2FE),
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

  Widget _buildDepotChips(List<dynamic> depots) {
    if (depots.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: depots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final d = depots[idx];
          final isSelected = d.depotId == _selectedDepotId;

          return ChoiceChip(
            label: Text(d.name.split(' ').take(2).join(' ')),
            selected: isSelected,
            selectedColor: AppColors.statusPreparing,
            backgroundColor: AppColors.bgCard,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color:
                  isSelected ? AppColors.statusPreparing : AppColors.borderColor,
            ),
            onSelected: (val) {
              if (val) setState(() => _selectedDepotId = d.depotId);
            },
          );
        },
      ),
    );
  }

  Widget _buildStockRow(
      AppStateProvider state, dynamic depot, dynamic product) {
    final currentQty = depot.stock[product.productId] ?? 0;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.propane_tank,
                  color: AppColors.brandOrange, size: 20),
              const SizedBox(width: 10),
              Text(
                '${product.size} (${product.name})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  state.updateDepotStock(
                      depot.depotId, product.productId, currentQty - 5);
                },
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.white60, size: 20),
              ),
              Text(
                '$currentQty',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  state.updateDepotStock(
                      depot.depotId, product.productId, currentQty + 10);
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.brandOrange, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverRosterTile(dynamic driver) {
    final isOnline = driver.status == 'online';

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          AppAvatar(
            name: driver.fullName,
            imageUrl: driver.photoUrl,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.fullName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  '${driver.vehicleType} • ${driver.vehicleNumber}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOnline
                  ? AppColors.brandGreen.withOpacity(0.15)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isOnline
                    ? AppColors.brandGreen.withOpacity(0.4)
                    : Colors.white24,
              ),
            ),
            child: Text(
              isOnline ? 'ACTIVE ON ROUTE' : 'OFFLINE',
              style: TextStyle(
                color: isOnline ? AppColors.brandGreen : Colors.white60,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
