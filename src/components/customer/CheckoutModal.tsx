import React, { useState } from 'react';
import { CylinderProduct, OrderType, PaymentMethod, Address, Promotion, GasProvider } from '../../types';
import { ArrowLeft, MapPin, CreditCard, Smartphone, Banknote, Tag, Check, ShieldCheck, Loader2, Building2 } from 'lucide-react';

interface CheckoutModalProps {
  cartItems: { product: CylinderProduct; quantity: number; order_type: OrderType }[];
  provider: GasProvider;
  addresses: Address[];
  selectedAddressId: string;
  onSelectAddress: (id: string) => void;
  promotions: Promotion[];
  deliveryFee: number;
  currencySymbol: string;
  onBack: () => void;
  onConfirmOrder: (params: {
    provider_id: string;
    payment_method: PaymentMethod;
    payment_provider?: string;
    promo_code?: string;
    discount_amount: number;
    address_id: string;
  }) => void;
}

export const CheckoutModal: React.FC<CheckoutModalProps> = ({
  cartItems,
  provider,
  addresses,
  selectedAddressId,
  onSelectAddress,
  promotions,
  deliveryFee,
  currencySymbol,
  onBack,
  onConfirmOrder,
}) => {
  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>('mobile_money');
  const [mobileProvider, setMobileProvider] = useState<string>('Orange Money');
  const [promoCodeInput, setPromoCodeInput] = useState<string>('');
  const [appliedPromo, setAppliedPromo] = useState<Promotion | null>(null);
  const [isProcessing, setIsProcessing] = useState<boolean>(false);

  const selectedAddr = addresses.find((a) => a.address_id === selectedAddressId) || addresses[0];

  const subtotal = cartItems.reduce((sum, item) => {
    const pPrices = provider.prices[item.product.product_id] || { refill: 195, exchange: 320 };
    const unitPrice = item.order_type === 'exchange' ? pPrices.exchange : pPrices.refill;
    return sum + unitPrice * item.quantity;
  }, 0);

  let discountAmount = 0;
  if (appliedPromo) {
    if (appliedPromo.discount_type === 'fixed') {
      discountAmount = appliedPromo.discount_value;
    } else {
      discountAmount = (subtotal * appliedPromo.discount_value) / 100;
      if (appliedPromo.max_discount_amount) {
        discountAmount = Math.min(discountAmount, appliedPromo.max_discount_amount);
      }
    }
  }

  const grandTotal = Math.max(0, subtotal + deliveryFee - discountAmount);

  const handleApplyPromo = () => {
    const found = promotions.find((p) => p.code.toUpperCase() === promoCodeInput.trim().toUpperCase() && p.is_active);
    if (found) {
      if (subtotal >= found.min_order_amount) {
        setAppliedPromo(found);
      } else {
        alert(`Minimum order amount for code ${found.code} is ${currencySymbol}${found.min_order_amount}`);
      }
    } else {
      alert('Invalid promo code. Try GAS20 or WINTERWARM');
    }
  };

  const handlePay = () => {
    setIsProcessing(true);
    setTimeout(() => {
      setIsProcessing(false);
      onConfirmOrder({
        provider_id: provider.provider_id,
        payment_method: paymentMethod,
        payment_provider: paymentMethod === 'mobile_money' ? mobileProvider : paymentMethod.toUpperCase(),
        promo_code: appliedPromo?.code,
        discount_amount: discountAmount,
        address_id: selectedAddr.address_id,
      });
    }, 1500);
  };

  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '14px', minHeight: '100%' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <button
          onClick={onBack}
          style={{
            width: '36px',
            height: '36px',
            borderRadius: '50%',
            background: 'rgba(255,255,255,0.08)',
            color: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <ArrowLeft size={18} />
        </button>
        <div>
          <h2 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>Checkout & Order Confirmation</h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Fulfilling Supplier: {provider.company_name}</p>
        </div>
      </div>

      {/* Selected Provider Card */}
      <div
        style={{
          background: 'rgba(255,107,0,0.1)',
          border: '1px solid var(--brand-orange)',
          borderRadius: 'var(--radius-md)',
          padding: '10px 14px',
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
        }}
      >
        <Building2 size={20} color="var(--brand-orange)" />
        <div>
          <h4 style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>{provider.company_name}</h4>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
            License: {provider.license_number} • {provider.safety_score}% Verified Safety Score
          </p>
        </div>
      </div>

      {/* Address Card */}
      <div className="glass-panel" style={{ padding: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '6px' }}>
          <span style={{ fontSize: '0.7rem', fontWeight: 700, color: 'var(--brand-orange)', textTransform: 'uppercase' }}>
            Delivery Destination
          </span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <MapPin size={18} color="var(--brand-orange)" />
          <div>
            <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>{selectedAddr.label}</p>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
              {selectedAddr.plot_unit}, {selectedAddr.street}, {selectedAddr.district}
            </p>
          </div>
        </div>
      </div>

      {/* Items Summary */}
      <div className="glass-panel" style={{ padding: '12px' }}>
        <h4 style={{ fontSize: '0.8rem', fontWeight: 700, color: '#ffffff', marginBottom: '8px' }}>Order Items</h4>
        {cartItems.map((item, idx) => {
          const pPrices = provider.prices[item.product.product_id] || { refill: 195, exchange: 320 };
          const unitPrice = item.order_type === 'exchange' ? pPrices.exchange : pPrices.refill;
          return (
            <div key={idx} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div>
                <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>
                  {item.quantity}x {item.product.name}
                </p>
                <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', textTransform: 'capitalize' }}>
                  {item.order_type} Service
                </p>
              </div>
              <span style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>
                {currencySymbol}
                {(unitPrice * item.quantity).toFixed(2)}
              </span>
            </div>
          );
        })}
      </div>

      {/* Payment Method Selector */}
      <div>
        <h4 style={{ fontSize: '0.8rem', fontWeight: 700, color: '#ffffff', marginBottom: '8px' }}>
          Select Payment Method
        </h4>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
          {/* Mobile Money Option */}
          <div
            onClick={() => setPaymentMethod('mobile_money')}
            className="glass-panel"
            style={{
              padding: '10px',
              cursor: 'pointer',
              borderColor: paymentMethod === 'mobile_money' ? 'var(--brand-orange)' : 'var(--border-color)',
              background: paymentMethod === 'mobile_money' ? 'rgba(255,107,0,0.1)' : 'var(--bg-card)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Smartphone size={18} color="var(--brand-orange)" />
                <div>
                  <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Mobile Money</p>
                  <p style={{ fontSize: '0.65rem', color: 'var(--text-secondary)' }}>Orange Money / Mascom MyZaka</p>
                </div>
              </div>
              {paymentMethod === 'mobile_money' && <Check size={16} color="var(--brand-orange)" />}
            </div>

            {paymentMethod === 'mobile_money' && (
              <div style={{ marginTop: '8px', display: 'flex', gap: '6px', paddingTop: '6px', borderTop: '1px solid var(--border-color)' }}>
                {['Orange Money', 'Mascom MyZaka'].map((prov) => (
                  <button
                    key={prov}
                    onClick={(e) => {
                      e.stopPropagation();
                      setMobileProvider(prov);
                    }}
                    style={{
                      flex: 1,
                      padding: '4px',
                      borderRadius: '4px',
                      fontSize: '0.7rem',
                      fontWeight: 700,
                      background: mobileProvider === prov ? 'var(--brand-orange)' : 'rgba(255,255,255,0.08)',
                      color: '#ffffff',
                    }}
                  >
                    {prov}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Debit/Credit Card */}
          <div
            onClick={() => setPaymentMethod('card')}
            className="glass-panel"
            style={{
              padding: '10px',
              cursor: 'pointer',
              borderColor: paymentMethod === 'card' ? 'var(--brand-orange)' : 'var(--border-color)',
              background: paymentMethod === 'card' ? 'rgba(255,107,0,0.1)' : 'var(--bg-card)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <CreditCard size={18} color="#00f0ff" />
              <div>
                <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Debit / Credit Card</p>
                <p style={{ fontSize: '0.65rem', color: 'var(--text-secondary)' }}>Visa, MasterCard (3D Secure)</p>
              </div>
            </div>
            {paymentMethod === 'card' && <Check size={16} color="var(--brand-orange)" />}
          </div>

          {/* Cash on Delivery */}
          <div
            onClick={() => setPaymentMethod('cash')}
            className="glass-panel"
            style={{
              padding: '10px',
              cursor: 'pointer',
              borderColor: paymentMethod === 'cash' ? 'var(--brand-orange)' : 'var(--border-color)',
              background: paymentMethod === 'cash' ? 'rgba(255,107,0,0.1)' : 'var(--bg-card)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Banknote size={18} color="#4ade80" />
              <div>
                <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Cash / POS on Delivery</p>
                <p style={{ fontSize: '0.65rem', color: 'var(--text-secondary)' }}>Pay driver upon cylinder swap</p>
              </div>
            </div>
            {paymentMethod === 'cash' && <Check size={16} color="var(--brand-orange)" />}
          </div>
        </div>
      </div>

      {/* Price Summary Breakdown */}
      <div className="glass-panel" style={{ padding: '12px', display: 'flex', flexDirection: 'column', gap: '6px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
          <span>Cylinder Subtotal ({provider.company_name.split(' ')[0]})</span>
          <span>{currencySymbol}{subtotal.toFixed(2)}</span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
          <span>Supplier Delivery Fee</span>
          <span>{currencySymbol}{deliveryFee.toFixed(2)}</span>
        </div>
        {discountAmount > 0 && (
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#4ade80' }}>
            <span>Promo Discount</span>
            <span>-{currencySymbol}{discountAmount.toFixed(2)}</span>
          </div>
        )}
        <div style={{ height: '1px', background: 'var(--border-color)', margin: '2px 0' }} />
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.95rem', fontWeight: 800, color: '#ffffff' }}>
          <span>Total Amount</span>
          <span style={{ color: 'var(--brand-orange)' }}>{currencySymbol}{grandTotal.toFixed(2)}</span>
        </div>
      </div>

      {/* Pay Button */}
      <div style={{ marginTop: 'auto', paddingTop: '6px' }}>
        <button
          className="glow-btn"
          style={{ width: '100%', padding: '14px' }}
          onClick={handlePay}
          disabled={isProcessing}
        >
          {isProcessing ? (
            <>
              <Loader2 size={18} className="spinning" />
              Authorizing Payment...
            </>
          ) : (
            <>
              <ShieldCheck size={18} />
              Pay {currencySymbol}{grandTotal.toFixed(2)} & Confirm Order
            </>
          )}
        </button>
      </div>
    </div>
  );
};
