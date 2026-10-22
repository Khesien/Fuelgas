import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Select Cylinder',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Banner
                    _buildProviderBadge(provider),
                    const SizedBox(height: 18),

                    // Cylinder Size Selector Carousel
                    Text(
                      'POPULAR CYLINDER SIZES',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSizeChips(state, cart),
                    const SizedBox(height: 20),

                    // Product Hero Card
                    _buildProductHeroCard(state, cart, unitPrice),
                    const SizedBox(height: 20),

                    // Order Type Toggle: Refill vs Exchange
                    Text(
                      'SERVICE TYPE',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildOrderTypeToggle(cart, provider),
                    const SizedBox(height: 20),

                    // Quantity Stepper
                    Text(
                      'QUANTITY',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tileBlueBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_rounded,
              color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Supplied by ${provider?.companyName ?? 'QuickGas Supplies'}',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.verified, color: AppColors.primaryBlue, size: 16),
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
            selectedColor: AppColors.primaryBlue,
            backgroundColor: Colors.white,
            labelStyle: GoogleFonts.plusJakartaSans(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/cylinder.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentProduct.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _currentProduct.description,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${state.currency}${unitPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primaryBlue,
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
    final prices = provider?.prices[_currentProduct.productId];
    final refillPrice = prices?.refill ?? 135.0;
    final exchangePrice = prices?.exchange ?? 135.0;

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tileBlueBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle,
                      color: AppColors.primaryBlue, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'P${price.toStringAsFixed(0)}',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Number of cylinders',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: cart.decrementQuantity,
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.primaryBlue),
              ),
              Text(
                '${cart.quantity}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                onPressed: cart.incrementQuantity,
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primaryBlue),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SUBTOTAL',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${state.currency}${subtotal.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Checkout',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
