import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
import '../common/app_avatar.dart';
import '../common/glass_container.dart';
import '../common/role_switch_sheet.dart';
import '../common/status_badge.dart';
import 'addresses_management_screen.dart';
import 'checkout_screen.dart';
import 'order_tracking_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final user = state.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
            icon: const Icon(Icons.swap_horiz, color: AppColors.brandOrange),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Info Card
              _buildUserInfoCard(user),
              const SizedBox(height: 16),

              // Referral Bonus Card
              _buildReferralCard(context, user, state),
              const SizedBox(height: 16),

              // Saved Addresses Row
              _buildAddressesNavigationTile(context, state),
              const SizedBox(height: 20),

              // Past Orders List
              const Text(
                'ORDER HISTORY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              _buildOrdersHistoryList(context, state),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppAvatar(
            name: user.fullName,
            imageUrl: user.profilePhoto,
            radius: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.phone,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit, color: Colors.white70, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(
      BuildContext context, dynamic user, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandAmber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard,
                color: AppColors.brandAmber, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Refer Friends, Earn Gas Credit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share code ${user.referralCode} • ${state.currency}${user.referralEarnings.toStringAsFixed(0)} Earned',
                  style: const TextStyle(
                    color: AppColors.brandAmber,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral link copied to clipboard!'),
                  backgroundColor: AppColors.brandGreen,
                ),
              );
            },
            icon: const Icon(Icons.share, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesNavigationTile(
      BuildContext context, AppStateProvider state) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddressesManagementScreen(),
          ),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.brandOrange, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved Delivery Addresses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${state.addresses.length} saved locations',
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

  Widget _buildOrdersHistoryList(
      BuildContext context, AppStateProvider state) {
    if (state.orders.isEmpty) {
      return const Text('No previous orders found.');
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final ord = state.orders[idx];

        return GlassContainer(
          padding: const EdgeInsets.all(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(order: ord),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ord.humanId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  StatusBadge(status: ord.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${ord.items.firstOrNull?.quantity ?? 1}x ${ord.items.firstOrNull?.product.name ?? 'Cylinder'} (${ord.orderType})',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.currency}${ord.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.brandOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      final cart =
                          Provider.of<CartProvider>(context, listen: false);
                      if (ord.items.isNotEmpty) {
                        cart.setProduct(ord.items.first.product);
                        cart.setOrderType(ord.orderType);
                        cart.setQuantity(ord.items.first.quantity);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Reorder',
                        style: TextStyle(
                          color: AppColors.brandOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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
