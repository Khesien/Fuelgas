import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cart_provider.dart';
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
    final deliveryFee = provider?.baseDeliveryFee ?? 25.0;
    final discount = cart.getDiscountAmount(provider);
    final grandTotal = cart.getGrandTotal(provider);

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
          'Checkout & Delivery',
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
                    // Delivery Address Card
                    _buildAddressCard(state),
                    const SizedBox(height: 18),

                    // Order Summary Item
                    _buildOrderItemsCard(cart, provider, state),
                    const SizedBox(height: 18),

                    // Promo Code Section
                    _buildPromoSection(cart, state),
                    const SizedBox(height: 18),

                    // Payment Methods Selector
                    Text(
                      'PAYMENT METHOD',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentSelector(),
                    const SizedBox(height: 18),

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DELIVERY ADDRESS',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () => _showAddressPicker(context, state),
                child: Text(
                  'Change',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primaryBlue,
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
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.tileBlueBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on,
                    color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addr?.label ?? 'Home',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addr?.fullAddress ??
                          '123 Molepolole Road, Gaborone',
                      style: GoogleFonts.plusJakartaSans(
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/images/cylinder.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cart.quantity}x ${prod.name}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cart.orderType.toUpperCase()} • ${provider?.companyName ?? 'QuickGas Supplies'}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${state.currency}${(unitPrice * cart.quantity).toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(CartProvider cart, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.discount_outlined,
                  color: AppColors.flameAmber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Promotions & Discounts',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
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
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _promoController,
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code (e.g. WELCOME)',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    final code = _promoController.text.trim();
                    if (code.isNotEmpty) {
                      cart.applyPromoCode(code, state.promotions);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Promo code applied!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Column(
      children: [
        _buildPaymentOptionTile(
          value: 'mobile_money',
          title: 'Mobile Money (Orange / Mascom)',
          icon: Icons.phone_android,
          iconColor: const Color(0xFFFF6600),
          extraWidget: _selectedPaymentMethod == 'mobile_money'
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Orange Money'),
                        selected: _selectedMobileProvider == 'Orange Money',
                        selectedColor: AppColors.tileOrangeBg,
                        labelStyle: TextStyle(
                          color: _selectedMobileProvider == 'Orange Money'
                              ? AppColors.tileOrangeIcon
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        onSelected: (_) => setState(
                            () => _selectedMobileProvider = 'Orange Money'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Mascom MyZaka'),
                        selected: _selectedMobileProvider == 'Mascom MyZaka',
                        selectedColor: const Color(0xFFFEFCE8),
                        labelStyle: TextStyle(
                          color: _selectedMobileProvider == 'Mascom MyZaka'
                              ? const Color(0xFFCA8A04)
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        onSelected: (_) => setState(
                            () => _selectedMobileProvider = 'Mascom MyZaka'),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        _buildPaymentOptionTile(
          value: 'card',
          title: 'Credit / Debit Card',
          icon: Icons.credit_card,
          iconColor: AppColors.primaryBlue,
        ),
        const SizedBox(height: 10),
        _buildPaymentOptionTile(
          value: 'cash_on_delivery',
          title: 'Cash on Delivery',
          icon: Icons.payments_outlined,
          iconColor: AppColors.statusDelivered,
        ),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required String value,
    required String title,
    required IconData icon,
    required Color iconColor,
    Widget? extraWidget,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tileBlueBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: _selectedPaymentMethod,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPaymentMethod = val);
                    }
                  },
                ),
              ],
            ),
            if (extraWidget != null) extraWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown({
    required AppStateProvider state,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double grandTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal',
              '${state.currency}${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildRow('Delivery Fee',
              '${state.currency}${deliveryFee.toStringAsFixed(2)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildRow('Discount',
                '-${state.currency}${discount.toStringAsFixed(2)}',
                valueColor: AppColors.statusDelivered),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderColor, thickness: 1),
          const SizedBox(height: 10),
          _buildRow(
            'Total Amount',
            '${state.currency}${grandTotal.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: valueColor ??
                (isBold ? AppColors.primaryBlue : AppColors.textPrimary),
            fontSize: isBold ? 16 : 13,
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
                'AMOUNT DUE',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${state.currency}${grandTotal.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
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
                    await Future.delayed(const Duration(milliseconds: 600));

                    final prod = cart.selectedProduct!;
                    final unitPrice =
                        cart.getUnitPrice(state.selectedProvider);

                    final order = await state.placeOrder(
                      providerId: state.selectedProviderId ?? '',
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
                      addressId: state.selectedAddressId ?? '',
                    );

                    cart.clearCart();

                    if (!mounted) return;
                    setState(() => _isProcessing = false);

                    if (order != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(order: order),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        'Confirm & Pay',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.shield_outlined,
                          size: 18, color: Colors.white),
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
      backgroundColor: Colors.white,
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
              Text(
                'Choose Saved Delivery Address',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ...state.addresses.map(
                (a) => ListTile(
                  title: Text(a.label,
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700)),
                  subtitle: Text(a.fullAddress,
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary, fontSize: 11)),
                  trailing: a.addressId == state.selectedAddressId
                      ? const Icon(Icons.check, color: AppColors.primaryBlue)
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
