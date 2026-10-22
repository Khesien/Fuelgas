import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_state_provider.dart';

class RoleSwitchSheet extends StatelessWidget {
  const RoleSwitchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Switch Operating Role',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Experience the platform from Customer, Delivery Driver, or Provider Admin perspective.',
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Role 1: Customer
          _buildRoleTile(
            context: context,
            title: 'Customer Experience',
            subtitle: 'Browse cylinders, select brand, order refill & track live',
            icon: Icons.person_pin,
            iconColor: AppColors.primaryBlue,
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
            iconColor: AppColors.statusOpen,
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
            iconColor: AppColors.tilePurpleIcon,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? iconColor : AppColors.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
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
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}
