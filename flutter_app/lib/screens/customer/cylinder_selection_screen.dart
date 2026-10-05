import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
import '../common/app_avatar.dart';
import '../common/glass_container.dart';
import 'checkout_screen.dart';

class CylinderSelectionScreen extends StatefulWidget {
  final CylinderProductModel? initialProduct;

  const CylinderSelectionScreen({super.key, this.initialProduct});

  @override
  State<CylinderSelectionScreen> createState() =>
      _CylinderSelectionScreenState();
}

class _CylinderSelectionScreenState extends State<CylinderSelectionScreen> {
  late CylinderProductModel _currentProduct;

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    _currentProduct = widget.initialProduct ??
        cart.selectedProduct ??
        Provider.of<AppStateProvider>(context, listen: false).products[2];
    cart.setProduct(_currentProduct);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final provider = state.selectedProvider;

    final unitPrice = cart.getUnitPrice(provider);
    final subtotal = cart.getSubtotal(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Cylinder Order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Banner
                    _buildProviderBadge(provider),
                    const SizedBox(height: 16),

                    // Cylinder Size Selector Carousel
                    const Text(
                      'CYLINDER SIZE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSizeChips(state, cart),
                    const SizedBox(height: 20),

                    // Product Hero Card
                    _buildProductHeroCard(state, cart, unitPrice),
                    const SizedBox(height: 20),

                    // Order Type Toggle: Refill vs Exchange
                    const Text(
                      'SERVICE TYPE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOrderTypeToggle(cart, provider),
                    const SizedBox(height: 20),

                    // Quantity Stepper
                    const Text(
                      'QUANTITY',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildQuantityStepper(cart),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Checkout Bar
            _buildBottomBar(context, state, cart, subtotal),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderBadge(dynamic provider) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ProviderLogoWidget(
            logoUrl: provider.logoUrl,
            companyName: provider.companyName,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Supplied by ${provider.companyName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.verified, color: AppColors.brandCyan, size: 16),
        ],
      ),
    );
  }

  Widget _buildSizeChips(AppStateProvider state, CartProvider cart) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final prod = state.products[idx];
          final isSelected = prod.productId == _currentProduct.productId;

          return ChoiceChip(
            label: Text(prod.size),
            selected: isSelected,
            selectedColor: AppColors.brandOrange,
            backgroundColor: AppColors.bgCard,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.brandOrange : AppColors.borderColor,
            ),
            onSelected: (val) {
              if (val) {
                setState(() => _currentProduct = prod);
                cart.setProduct(prod);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildProductHeroCard(
      AppStateProvider state, CartProvider cart, double unitPrice) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFF131B2E),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.propane_tank,
                color: AppColors.brandOrange, size: 44),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentProduct.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentProduct.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.currency}${unitPrice.toStringAsFixed(2)} / cylinder',
                  style: const TextStyle(
                    color: AppColors.brandCyan,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeToggle(CartProvider cart, dynamic provider) {
    final prices = provider.prices[_currentProduct.productId];
    final refillPrice = prices?.refill ?? 195.0;
    final exchangePrice = prices?.exchange ?? 320.0;

    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            title: 'Exchange',
            subtitle: 'Swap empty bottle for full',
            price: exchangePrice,
            isSelected: cart.orderType == 'exchange',
            onTap: () => cart.setOrderType('exchange'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton(
            title: 'Refill',
            subtitle: 'Express onsite bottle refill',
            price: refillPrice,
            isSelected: cart.orderType == 'refill',
            onTap: () => cart.setOrderType('refill'),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String title,
    required String subtitle,
    required double price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      backgroundColor: isSelected
          ? AppColors.brandOrange.withOpacity(0.15)
          : AppColors.bgCard,
      borderColor: isSelected ? AppColors.brandOrange : AppColors.borderColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle,
                    color: AppColors.brandOrange, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Text(
            'P${price.toStringAsFixed(0)}',
            style: TextStyle(
              color: isSelected ? AppColors.brandOrange : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(CartProvider cart) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Number of cylinders',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              IconButton(
                onPressed: cart.decrementQuantity,
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.brandOrange),
              ),
              Text(
                '${cart.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                onPressed: cart.incrementQuantity,
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.brandOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppStateProvider state,
      CartProvider cart, double subtotal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SUBTOTAL',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                '${state.currency}${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CheckoutScreen(),
                ),
              );
            },
            child: const Row(
              children: [
                Text('Checkout'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
