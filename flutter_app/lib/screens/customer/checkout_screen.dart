import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
import '../common/glass_container.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'mobile_money';
  String _selectedMobileProvider = 'Orange Money';
  final TextEditingController _promoController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final provider = state.selectedProvider;

    final subtotal = cart.getSubtotal(provider);
    final deliveryFee = provider.baseDeliveryFee;
    final discount = cart.getDiscountAmount(provider);
    final grandTotal = cart.getGrandTotal(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout & Delivery',
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
                    // Delivery Address Card
                    _buildAddressCard(state),
                    const SizedBox(height: 20),

                    // Order Summary Item
                    _buildOrderItemsCard(cart, provider, state),
                    const SizedBox(height: 20),

                    // Promo Code Section
                    _buildPromoSection(cart, state),
                    const SizedBox(height: 20),

                    // Payment Methods Selector
                    const Text(
                      'PAYMENT METHOD',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentSelector(),
                    const SizedBox(height: 20),

                    // Price Breakdown Card
                    _buildPriceBreakdown(
                      state: state,
                      subtotal: subtotal,
                      deliveryFee: deliveryFee,
                      discount: discount,
                      grandTotal: grandTotal,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Confirm Button
            _buildStickyPlaceOrderBar(
              context: context,
              state: state,
              cart: cart,
              grandTotal: grandTotal,
              discount: discount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(AppStateProvider state) {
    final addr = state.selectedAddress;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DELIVERY ADDRESS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () => _showAddressPicker(context, state),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.brandOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on,
                  color: AppColors.brandOrange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addr.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addr.fullAddress,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(
      CartProvider cart, dynamic provider, AppStateProvider state) {
    final prod = cart.selectedProduct;
    if (prod == null) return const SizedBox.shrink();

    final unitPrice = cart.getUnitPrice(provider);

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.propane_tank,
                color: AppColors.brandOrange, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cart.quantity}x ${prod.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cart.orderType.toUpperCase()} • ${provider.companyName}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${state.currency}${(unitPrice * cart.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(CartProvider cart, AppStateProvider state) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.discount,
                  color: AppColors.brandAmber, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Promotions & Discounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Enter code: e.g. GAS20',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final code = _promoController.text.trim().toUpperCase();
                  final found = state.promotions.firstWhere(
                    (p) => p.code == code && p.isActive,
                    orElse: () => state.promotions.first,
                  );
                  if (found.code == code) {
                    cart.applyPromo(found);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Promo ${found.code} applied!'),
                        backgroundColor: AppColors.brandGreen,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid code. Try GAS20'),
                        backgroundColor: AppColors.statusCancelled,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
          if (cart.appliedPromo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.brandGreen, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Applied: ${cart.appliedPromo!.code} (${cart.appliedPromo!.description})',
                  style: const TextStyle(
                      color: AppColors.brandGreen, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Column(
      children: [
        _buildPaymentOption(
          id: 'mobile_money',
          title: 'Mobile Money (Express)',
          subtitle: 'Orange Money, Mascom MyZaka',
          icon: Icons.phone_android,
        ),
        if (_selectedPaymentMethod == 'mobile_money')
          Padding(
            padding: const EdgeInsets.only(left: 36, bottom: 8, top: 4),
            child: Row(
              children: [
                _buildSubProviderChip('Orange Money'),
                const SizedBox(width: 8),
                _buildSubProviderChip('Mascom MyZaka'),
              ],
            ),
          ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          id: 'card',
          title: 'Credit / Debit Card',
          subtitle: 'Visa, Mastercard, Instant EFT',
          icon: Icons.credit_card,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          id: 'cash',
          title: 'Cash on Delivery',
          subtitle: 'Pay exact cash upon inspection',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: isSelected
          ? AppColors.brandOrange.withOpacity(0.12)
          : AppColors.bgCard,
      borderColor: isSelected ? AppColors.brandOrange : AppColors.borderColor,
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Row(
        children: [
          Icon(icon,
              color: isSelected ? AppColors.brandOrange : Colors.white70,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Radio<String>(
            value: id,
            groupValue: _selectedPaymentMethod,
            activeColor: AppColors.brandOrange,
            onChanged: (val) =>
                setState(() => _selectedPaymentMethod = val ?? 'mobile_money'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubProviderChip(String name) {
    final isSelected = _selectedMobileProvider == name;
    return ChoiceChip(
      label: Text(name),
      selected: isSelected,
      selectedColor: AppColors.brandOrange,
      backgroundColor: AppColors.bgCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => setState(() => _selectedMobileProvider = name),
    );
  }

  Widget _buildPriceBreakdown({
    required AppStateProvider state,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double grandTotal,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRow('Subtotal', '${state.currency}${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildRow(
              'Delivery Fee', '${state.currency}${deliveryFee.toStringAsFixed(2)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildRow(
              'Discount',
              '-${state.currency}${discount.toStringAsFixed(2)}',
              valueColor: AppColors.brandGreen,
            ),
          ],
          const Divider(color: AppColors.borderColor, height: 24),
          _buildRow(
            'Grand Total',
            '${state.currency}${grandTotal.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.brandOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : AppColors.textSecondary,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStickyPlaceOrderBar({
    required BuildContext context,
    required AppStateProvider state,
    required CartProvider cart,
    required double grandTotal,
    required double discount,
  }) {
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
                'AMOUNT DUE',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                '${state.currency}${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () async {
                    setState(() => _isProcessing = true);
                    await Future.delayed(const Duration(milliseconds: 700));

                    final prod = cart.selectedProduct!;
                    final unitPrice =
                        cart.getUnitPrice(state.selectedProvider);

                    final order = state.placeOrder(
                      providerId: state.selectedProviderId,
                      items: [
                        OrderItemModel(
                          orderItemId:
                              'item-${DateTime.now().millisecondsSinceEpoch}',
                          orderId: '',
                          productId: prod.productId,
                          product: prod,
                          quantity: cart.quantity,
                          orderType: cart.orderType,
                          unitPrice: unitPrice,
                          totalPrice: unitPrice * cart.quantity,
                        ),
                      ],
                      orderType: cart.orderType,
                      paymentMethod: _selectedPaymentMethod,
                      paymentProvider: _selectedPaymentMethod == 'mobile_money'
                          ? _selectedMobileProvider
                          : _selectedPaymentMethod.toUpperCase(),
                      promoCode: cart.appliedPromo?.code,
                      discountAmount: discount,
                      addressId: state.selectedAddressId,
                    );

                    cart.clearCart();

                    if (!mounted) return;
                    setState(() => _isProcessing = false);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(order: order),
                      ),
                    );
                  },
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    children: [
                      Text('Confirm & Pay'),
                      SizedBox(width: 8),
                      Icon(Icons.shield, size: 18),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddressPicker(BuildContext context, AppStateProvider state) {
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
                'Choose Saved Delivery Address',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...state.addresses.map(
                (a) => ListTile(
                  title: Text(a.label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text(a.fullAddress,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  trailing: a.addressId == state.selectedAddressId
                      ? const Icon(Icons.check, color: AppColors.brandOrange)
                      : null,
                  onTap: () {
                    state.setSelectedAddress(a.addressId);
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
