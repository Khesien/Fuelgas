import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
import 'cylinder_selection_screen.dart';
import 'checkout_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const CustomerHomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final user = state.currentUser;
    final firstName = user?.fullName.split(' ').first ?? 'Kesego';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Royal Blue Header ─────────────────────────────────────────────
          Container(
            color: AppColors.primaryBlue,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo & Text
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FuelGas',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    // Actions: Notification Bell + Avatar
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No new notifications')),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => onNavigateTab?.call(4),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white54, width: 1.2),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable Content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Location
                  Text(
                    'Good Morning,',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    firstName,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Location Row
                  InkWell(
                    onTap: () => _showLocationDialog(context, state),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primaryBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.activeDistrict,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Hero Promotional Card ("Need Gas?") ───────────────────
                  _buildHeroBanner(context, state),

                  const SizedBox(height: 22),

                  // ── Quick Action Tiles (4-grid) ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionTile(
                        icon: Icons.location_on,
                        title: 'Nearby\nSuppliers',
                        bgColor: AppColors.tileBlueBg,
                        iconColor: AppColors.tileBlueIcon,
                        onTap: () => onNavigateTab?.call(1),
                      ),
                      _buildQuickActionTile(
                        icon: Icons.assignment_outlined,
                        title: 'My Orders',
                        bgColor: AppColors.tileGreenBg,
                        iconColor: AppColors.tileGreenIcon,
                        onTap: () => onNavigateTab?.call(2),
                      ),
                      _buildQuickActionTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Wallet',
                        bgColor: AppColors.tileOrangeBg,
                        iconColor: AppColors.tileOrangeIcon,
                        onTap: () => onNavigateTab?.call(3),
                      ),
                      _buildQuickActionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        bgColor: AppColors.tilePurpleBg,
                        iconColor: AppColors.tilePurpleIcon,
                        onTap: () => onNavigateTab?.call(4),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Popular Cylinder Sizes Section ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Cylinder Sizes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CylinderSelectionScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'View All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Cylinder Sizes Cards Grid/Row
                  _buildCylinderRow(context, state),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, AppStateProvider state) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF091F44),
            Color(0xFF0E387A),
            Color(0xFF1350AB),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Text Content on Left
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Need Gas?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order now and get\nit delivered to your door!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CylinderSelectionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.flameYellow,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Order Now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cylinder on Right
          Positioned(
            right: 12,
            bottom: 6,
            top: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/cylinder.jpg',
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 68,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCylinderRow(BuildContext context, AppStateProvider state) {
    if (state.products.isNotEmpty) {
      final displayProducts = state.products.take(4).toList();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: displayProducts.map((prod) {
          final price = state.selectedProvider?.prices[prod.productId]?.refill ??
              (prod.sizeKg * 11.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildCylinderCard(
                context: context,
                state: state,
                size: prod.size,
                price: price,
                kg: prod.sizeKg,
                existingProduct: prod,
              ),
            ),
          );
        }).toList(),
      );
    }

    final sizes = [
      {'size': '6kg', 'price': 70.0, 'kg': 6.0},
      {'size': '9kg', 'price': 95.0, 'kg': 9.0},
      {'size': '14kg', 'price': 135.0, 'kg': 14.0},
      {'size': '19kg', 'price': 165.0, 'kg': 19.0},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: sizes.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildCylinderCard(
              context: context,
              state: state,
              size: item['size'] as String,
              price: item['price'] as double,
              kg: item['kg'] as double,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCylinderCard({
    required BuildContext context,
    required AppStateProvider state,
    required String size,
    required double price,
    required double kg,
    CylinderProductModel? existingProduct,
  }) {
    return InkWell(
      onTap: () {
        final cart = Provider.of<CartProvider>(context, listen: false);
        final product = existingProduct ??
            state.products.firstWhere(
              (p) => p.size.toLowerCase() == size.toLowerCase(),
              orElse: () => CylinderProductModel(
                productId: 'prod_$size',
                size: size,
                sizeKg: kg,
                name: '$size LPG Cylinder',
                description: 'Genuine certified LPG gas cylinder.',
                imageUrl: 'assets/images/cylinder.jpg',
              ),
            );
        cart.setProduct(product);
        cart.setQuantity(1);
        cart.setOrderType('exchange');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/cylinder.jpg',
              height: 52,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              size,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${state.currency}${price.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Select Location',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primaryBlue),
              title: const Text('Gaborone, Botswana'),
              onTap: () {
                state.setActiveDistrict('Gaborone, Botswana');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primaryBlue),
              title: const Text('Gaborone West'),
              onTap: () {
                state.setActiveDistrict('Gaborone West');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primaryBlue),
              title: const Text('Broadhurst'),
              onTap: () {
                state.setActiveDistrict('Broadhurst');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
