import React, { useState } from 'react';
import { CylinderProduct, OrderType, GasProvider, District } from '../../types';
import { ArrowLeft, Plus, Minus, Check, Flame, RefreshCw, Building2, Star, ShieldCheck } from 'lucide-react';

interface CylinderSelectionProps {
  products: CylinderProduct[];
  selectedProductInitial?: CylinderProduct;
  providers: GasProvider[];
  selectedProviderId: string;
  onSelectProvider: (id: string) => void;
  activeDistrict: District;
  currencySymbol: string;
  onBack: () => void;
  onProceedToCheckout: (cartItems: { product: CylinderProduct; quantity: number; order_type: OrderType }[]) => void;
}

export const CylinderSelection: React.FC<CylinderSelectionProps> = ({
  products,
  selectedProductInitial,
  providers,
  selectedProviderId,
  onSelectProvider,
  activeDistrict,
  currencySymbol,
  onBack,
  onProceedToCheckout,
}) => {
  const [selectedProduct, setSelectedProduct] = useState<CylinderProduct>(selectedProductInitial || products[2]); // Default 9KG
  const [orderType, setOrderType] = useState<OrderType>('exchange');
  const [quantity, setQuantity] = useState<number>(1);
  const [showComparisonTab, setShowComparisonTab] = useState<boolean>(false);

  // Available providers in active district
  const localProviders = providers.filter(
    (p) => p.compliance_status === 'approved' && p.districts_served.includes(activeDistrict)
  );

  const currentProvider = providers.find((p) => p.provider_id === selectedProviderId) || localProviders[0] || providers[0];
  const pPrices = currentProvider.prices[selectedProduct.product_id] || { refill: 195, exchange: 320 };

  const currentPrice = orderType === 'exchange' ? pPrices.exchange : pPrices.refill;
  const subtotal = currentPrice * quantity;

  const handleProceed = () => {
    onProceedToCheckout([
      {
        product: selectedProduct,
        quantity,
        order_type: orderType,
      }
    ]);
  };

  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', minHeight: '100%', gap: '16px' }}>
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
          <h2 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>Select & Compare Gas</h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
            Supplier: <strong style={{ color: 'var(--brand-orange)' }}>{currentProvider.company_name}</strong>
          </p>
        </div>
      </div>

      {/* Refill vs Exchange Mode Selector Toggle */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          background: 'rgba(255,255,255,0.05)',
          padding: '4px',
          borderRadius: 'var(--radius-md)',
          border: '1px solid var(--border-color)',
        }}
      >
        <button
          onClick={() => setOrderType('exchange')}
          style={{
            padding: '10px',
            borderRadius: 'var(--radius-sm)',
            fontWeight: 700,
            fontSize: '0.8rem',
            background: orderType === 'exchange' ? 'var(--brand-orange)' : 'transparent',
            color: orderType === 'exchange' ? '#ffffff' : 'var(--text-secondary)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '6px',
          }}
        >
          <RefreshCw size={14} />
          Exchange Cylinder
        </button>
        <button
          onClick={() => setOrderType('refill')}
          style={{
            padding: '10px',
            borderRadius: 'var(--radius-sm)',
            fontWeight: 700,
            fontSize: '0.8rem',
            background: orderType === 'refill' ? 'var(--brand-orange)' : 'transparent',
            color: orderType === 'refill' ? '#ffffff' : 'var(--text-secondary)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '6px',
          }}
        >
          <Flame size={14} />
          Refill Only
        </button>
      </div>

      {/* Cylinder Sizes Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px' }}>
        {products.map((product) => {
          const isSelected = selectedProduct.product_id === product.product_id;
          const prices = currentProvider.prices[product.product_id] || { refill: 195, exchange: 320 };
          const price = orderType === 'exchange' ? prices.exchange : prices.refill;

          return (
            <div
              key={product.product_id}
              onClick={() => setSelectedProduct(product)}
              className="glass-panel"
              style={{
                padding: '12px 8px',
                textAlign: 'center',
                cursor: 'pointer',
                borderColor: isSelected ? 'var(--brand-orange)' : 'var(--border-color)',
                background: isSelected ? 'rgba(255,107,0,0.15)' : 'var(--bg-card)',
                boxShadow: isSelected ? '0 0 14px rgba(255,107,0,0.3)' : 'none',
                position: 'relative',
              }}
            >
              {isSelected && (
                <div
                  style={{
                    position: 'absolute',
                    top: '4px',
                    right: '4px',
                    width: '18px',
                    height: '18px',
                    borderRadius: '50%',
                    background: 'var(--brand-orange)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Check size={12} color="#ffffff" />
                </div>
              )}
              <span style={{ fontSize: '1.2rem', fontWeight: 900, color: isSelected ? 'var(--brand-orange)' : '#ffffff' }}>
                {product.size}
              </span>
              <p style={{ fontSize: '0.65rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
                {product.size_kg} KG LPG
              </p>
              <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff', marginTop: '6px' }}>
                {currencySymbol}{price.toFixed(0)}
              </p>
            </div>
          );
        })}
      </div>

      {/* Compare Prices Across Local Providers Toggle Button */}
      <button
        className="secondary-btn"
        style={{ padding: '8px', fontSize: '0.75rem', borderColor: 'var(--brand-orange)', color: 'var(--brand-orange)' }}
        onClick={() => setShowComparisonTab(!showComparisonTab)}
      >
        <Building2 size={14} />
        {showComparisonTab ? 'Hide Provider Comparison' : `Compare Provider Prices for ${selectedProduct.size}`}
      </button>

      {/* Provider Price Comparison Table */}
      {showComparisonTab && (
        <div className="glass-panel" style={{ padding: '14px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <h4 style={{ fontSize: '0.8rem', fontWeight: 800, color: '#ffffff' }}>
            Local Supplier Price Comparison ({selectedProduct.size} {orderType.toUpperCase()})
          </h4>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {localProviders.map((prov) => {
              const itemPrices = prov.prices[selectedProduct.product_id] || { refill: 195, exchange: 320 };
              const pPrice = orderType === 'exchange' ? itemPrices.exchange : itemPrices.refill;
              const isCurrent = prov.provider_id === currentProvider.provider_id;

              return (
                <div
                  key={prov.provider_id}
                  onClick={() => onSelectProvider(prov.provider_id)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '8px 10px',
                    background: isCurrent ? 'rgba(255,107,0,0.15)' : 'rgba(255,255,255,0.03)',
                    border: `1px solid ${isCurrent ? 'var(--brand-orange)' : 'var(--border-color)'}`,
                    borderRadius: '6px',
                    cursor: 'pointer',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <img src={prov.logo_url} alt={prov.company_name} style={{ width: '28px', height: '28px', borderRadius: '4px', objectFit: 'cover' }} />
                    <div>
                      <p style={{ fontSize: '0.8rem', fontWeight: 800, color: '#ffffff' }}>{prov.company_name}</p>
                      <span style={{ fontSize: '0.65rem', color: '#ffb703' }}>★ {prov.rating} • {prov.est_delivery_mins}m deliv</span>
                    </div>
                  </div>

                  <div style={{ textAlign: 'right' }}>
                    <p style={{ fontSize: '0.9rem', fontWeight: 900, color: 'var(--brand-orange)' }}>
                      {currencySymbol}{pPrice.toFixed(2)}
                    </p>
                    {isCurrent ? (
                      <span style={{ fontSize: '0.65rem', color: '#4ade80', fontWeight: 700 }}>Selected Supplier</span>
                    ) : (
                      <span style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>Tap to choose</span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Quantity Stepper */}
      <div
        className="glass-panel"
        style={{
          padding: '12px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <div>
          <span style={{ fontSize: '0.8rem', fontWeight: 700, color: '#ffffff' }}>Quantity</span>
          <p style={{ fontSize: '0.65rem', color: 'var(--text-secondary)' }}>Cylinders needed</p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <button
            onClick={() => setQuantity((q) => Math.max(1, q - 1))}
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '6px',
              background: 'rgba(255,255,255,0.1)',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Minus size={14} />
          </button>
          <span style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff', width: '20px', textAlign: 'center' }}>
            {quantity}
          </span>
          <button
            onClick={() => setQuantity((q) => q + 1)}
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '6px',
              background: 'var(--brand-orange)',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Plus size={14} />
          </button>
        </div>
      </div>

      {/* Running Subtotal Footer Button */}
      <div style={{ marginTop: 'auto', paddingTop: '10px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Item Subtotal ({currentProvider.company_name.split(' ')[0]})</span>
          <span style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>
            {currencySymbol}{subtotal.toFixed(2)}
          </span>
        </div>

        <button className="glow-btn" style={{ width: '100%', padding: '14px' }} onClick={handleProceed}>
          Proceed to Checkout ({quantity}x {selectedProduct.size})
        </button>
      </div>
    </div>
  );
};
