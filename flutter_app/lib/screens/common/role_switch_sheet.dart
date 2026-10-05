import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_state_provider.dart';
import 'glass_container.dart';

class RoleSwitchSheet extends StatelessWidget {
  const RoleSwitchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Switch Operating Role',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Experience the platform from Customer, Delivery Driver, or Provider Admin perspective.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Role 1: Customer
          _buildRoleTile(
            context: context,
            title: 'Customer Experience',
            subtitle: 'Browse cylinders, select brand, order refill & track live',
            icon: Icons.person_pin,
            iconColor: AppColors.brandOrange,
            isSelected: state.activeRole == UserRole.customer,
            onTap: () {
              state.setActiveRole(UserRole.customer);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),

          // Role 2: Driver / Service Provider
          _buildRoleTile(
            context: context,
            title: 'Driver / Service Provider',
            subtitle: 'Accept jobs, navigate route, deliver with OTP & earn payouts',
            icon: Icons.local_shipping,
            iconColor: AppColors.brandCyan,
            isSelected: state.activeRole == UserRole.driver,
            onTap: () {
              state.setActiveRole(UserRole.driver);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),

          // Role 3: Provider Admin
          _buildRoleTile(
            context: context,
            title: 'Provider Admin / Depot Hub',
            subtitle: 'Manage cylinder stock levels, view active fleet & orders',
            icon: Icons.admin_panel_settings,
            iconColor: AppColors.statusPreparing,
            isSelected: state.activeRole == UserRole.providerAdmin,
            onTap: () {
              state.setActiveRole(UserRole.providerAdmin);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRoleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: isSelected
          ? iconColor.withOpacity(0.12)
          : AppColors.bgCard,
      borderColor: isSelected ? iconColor : AppColors.borderColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: iconColor, size: 20),
        ],
      ),
    );
  }
}
