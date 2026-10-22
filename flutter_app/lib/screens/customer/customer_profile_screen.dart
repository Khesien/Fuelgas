import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../common/auth_screen.dart';
import 'addresses_management_screen.dart';
import 'order_details_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  final bool showBackButton;

  const CustomerProfileScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final user = state.currentUser;
    final fullName = user?.fullName ?? 'Kesego Molosiwa';
    final phone = user?.phone ?? '+267 77 123 456';
    final email = user?.email ?? 'kesego@example.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Text(
          'My Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            // ── User Profile Header Card ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Circular Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Name & Contact
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          phone,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          email,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Button
                  SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () {
                        _showEditProfileDialog(context, state);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(
                            color: AppColors.primaryBlue, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Divider(color: AppColors.borderColor, thickness: 1),
            const SizedBox(height: 10),

            // ── Menu List Options ───────────────────────────────────────────
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'My Addresses',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddressesManagementScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.credit_card_outlined,
              title: 'Payment Methods',
              onTap: () {
                _showPaymentMethodsSheet(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.receipt_long_outlined,
              title: 'Order History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderDetailsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications are up to date.')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {
                _showSupportDialog(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About FuelGas',
              onTap: () {
                _showAboutDialog(context);
              },
            ),

            const SizedBox(height: 8),

            // Log Out Button
            InkWell(
              onTap: () => _confirmSignOut(context, state),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.danger,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Log Out',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppStateProvider state) {
    final nameCtrl =
        TextEditingController(text: state.currentUser?.fullName ?? 'Kesego Molosiwa');
    final phoneCtrl =
        TextEditingController(text: state.currentUser?.phone ?? '+267 77 123 456');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Profile',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.orange),
              title: const Text('Orange Money'),
              subtitle: const Text('Active • +267 77 123 456'),
              trailing: const Icon(Icons.check_circle, color: AppColors.statusDelivered),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.yellow),
              title: const Text('Mascom MyZaka'),
              subtitle: const Text('Connect mobile wallet'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppColors.primaryBlue),
              title: const Text('Visa / Mastercard'),
              subtitle: const Text('Ending in 4021'),
              trailing: const Icon(Icons.check_circle, color: AppColors.statusDelivered),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Help & Support',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: const Text(
          'For 24/7 gas emergency or order inquiries:\n\n'
          '📞 Toll-Free: 0800 123 456\n'
          '📧 Email: support@fuelgas.co.bw\n'
          '💬 WhatsApp: +267 71 234 567',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('About FuelGas',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: const Text(
          'FuelGas v1.0.0\n'
          'Safe Gas. Warm Homes.\n\n'
          'Your trusted LPG gas delivery partner across Botswana. Certified compliance, genuine cylinder exchanges, and doorstep delivery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log Out',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out of FuelGas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              state.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
