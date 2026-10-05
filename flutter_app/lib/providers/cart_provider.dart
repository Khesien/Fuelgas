import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/promotion_model.dart';
import '../models/provider_model.dart';

class CartProvider extends ChangeNotifier {
  CylinderProductModel? _selectedProduct;
  CylinderProductModel? get selectedProduct => _selectedProduct;

  String _orderType = 'exchange'; // 'refill' or 'exchange'
  String get orderType => _orderType;

  int _quantity = 1;
  int get quantity => _quantity;

  PromotionModel? _appliedPromo;
  PromotionModel? get appliedPromo => _appliedPromo;

  void setProduct(CylinderProductModel product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void setOrderType(String type) {
    _orderType = type;
    notifyListeners();
  }

  void setQuantity(int qty) {
    if (qty >= 1 && qty <= 10) {
      _quantity = qty;
      notifyListeners();
    }
  }

  void incrementQuantity() {
    if (_quantity < 10) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  void applyPromo(PromotionModel promo) {
    _appliedPromo = promo;
    notifyListeners();
  }

  void removePromo() {
    _appliedPromo = null;
    notifyListeners();
  }

  double getUnitPrice(GasProviderModel? provider) {
    if (_selectedProduct == null) return 0.0;
    if (provider == null) return _selectedProduct!.basePrice;
    final prices = provider.prices[_selectedProduct!.productId];
    if (prices == null) return _selectedProduct!.basePrice;
    return _orderType == 'exchange' ? prices.exchange : prices.refill;
  }

  double getSubtotal(GasProviderModel? provider) {
    return getUnitPrice(provider) * _quantity;
  }

  double getDiscountAmount(GasProviderModel? provider) {
    if (_appliedPromo == null) return 0.0;
    final subtotal = getSubtotal(provider);
    if (subtotal < _appliedPromo!.minOrderAmount) return 0.0;

    if (_appliedPromo!.discountType == 'fixed') {
      return _appliedPromo!.discountValue;
    } else {
      double pct = (subtotal * _appliedPromo!.discountValue) / 100.0;
      if (_appliedPromo!.maxDiscountAmount != null) {
        pct = pct.clamp(0.0, _appliedPromo!.maxDiscountAmount!);
      }
      return pct;
    }
  }

  double getGrandTotal(GasProviderModel? provider) {
    final subtotal = getSubtotal(provider);
    final deliveryFee = provider?.baseDeliveryFee ?? 25.0;
    final discount = getDiscountAmount(provider);
    return (subtotal + deliveryFee - discount).clamp(0.0, double.infinity);
  }

  void clearCart() {
    _quantity = 1;
    _appliedPromo = null;
    notifyListeners();
  }
}
