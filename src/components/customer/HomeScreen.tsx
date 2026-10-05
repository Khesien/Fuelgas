import React, { useState } from 'react';
import { User, Address, CylinderProduct, Order, GasProvider, District } from '../../types';
import { MapPin, Bell, ChevronRight, Flame, ArrowRight, Zap, Gift, Clock, ShieldCheck, Star, Building2, Compass, Info, CheckCircle2 } from 'lucide-react';

interface HomeScreenProps {
  user: User;
  addresses: Address[];
  selectedAddressId: string;
  onChangeAddress: () => void;
  districts: District[];
  activeDistrict: District;
  onSelectDistrict: (district: District) => void;
  providers: GasProvider[];
  selectedProviderId: string;
  onSelectProvider: (providerId: string) => void;
  products: CylinderProduct[];
  activeOrder?: Order;
  currencySymbol: string;
  onSelectProduct: (product: CylinderProduct) => void;
  onViewAllProducts: () => void;
  onTrackOrder: () => void;
  onViewOffers: () => void;
  unreadNotifsCount: number;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({
  user,
  addresses,
  selectedAddressId,
  onChangeAddress,
  districts,
  activeDistrict,
  onSelectDistrict,
  providers,
  selectedProviderId,
  onSelectProvider,
  products,
  activeOrder,
  currencySymbol,
  onSelectProduct,
  onViewAllProducts,
  onTrackOrder,
  onViewOffers,
  unreadNotifsCount,
}) => {
  const [selectedProviderForModal, setSelectedProviderForModal] = useState<GasProvider | null>(null);
  const currentAddress = addresses.find((a) => a.address_id === selectedAddressId) || addresses[0];

  // Filter approved providers serving active district
  const localProviders = providers.filter(
    (p) => p.compliance_status === 'approved' && p.districts_served.includes(activeDistrict)
  );

  const currentProvider = providers.find((p) => p.provider_id === selectedProviderId) || localProviders[0] || providers[0];

  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Top Address & District Location Bar */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', fontWeight: 600 }}>DELIVERY DISTRICT LOCATION</p>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '2px' }}>
            <MapPin size={16} color="var(--brand-orange)" />
            <select
              value={activeDistrict}
              onChange={(e) => onSelectDistrict(e.target.value as District)}
              style={{
                background: 'rgba(255,255,255,0.08)',
                color: '#ffffff',
                border: '1px solid var(--border-color)',
                padding: '4px 8px',
                borderRadius: '6px',
                fontSize: '0.85rem',
                fontWeight: 700,
                cursor: 'pointer',
              }}
            >
              {districts.map((d) => (
                <option key={d} value={d} style={{ background: '#0f172a', color: '#fff' }}>
                  {d}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div style={{ position: 'relative' }}>
          <div
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '50%',
              background: 'rgba(255,255,255,0.08)',
              border: '1px solid var(--border-color)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
            }}
          >
            <Bell size={18} color="#ffffff" />
            {unreadNotifsCount > 0 && (
              <span
                style={{
                  position: 'absolute',
                  top: '0',
                  right: '0',
                  width: '10px',
                  height: '10px',
                  borderRadius: '50%',
                  background: 'var(--brand-orange)',
                  border: '2px solid #0f172a',
                }}
              />
            )}
          </div>
        </div>
      </div>

      {/* Greeting Banner */}
      <div>
        <h2 style={{ fontSize: '1.25rem', fontWeight: 800, color: '#ffffff' }}>
          Hello, {user.full_name.split(' ')[0]} 👋
        </h2>
        <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
          Showing certified LPG gas suppliers in <strong style={{ color: 'var(--brand-orange)' }}>{activeDistrict}</strong>.
        </p>
      </div>

      {/* Registered Gas Providers Carousel / Selector */}
      <div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Building2 size={16} color="var(--brand-orange)" />
            <h3 style={{ fontSize: '0.9rem', fontWeight: 800, color: '#ffffff' }}>
              Registered Gas Providers ({localProviders.length})
            </h3>
          </div>
        </div>

        <div style={{ display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '6px' }}>
          {localProviders.map((prov) => {
            const isSelected = prov.provider_id === currentProvider.provider_id;
            return (
              <div
                key={prov.provider_id}
                onClick={() => onSelectProvider(prov.provider_id)}
                className="glass-panel"
                style={{
                  minWidth: '220px',
                  padding: '12px',
                  cursor: 'pointer',
                  borderColor: isSelected ? 'var(--brand-orange)' : 'var(--border-color)',
                  background: isSelected ? 'rgba(255,107,0,0.15)' : 'var(--bg-card)',
                  boxShadow: isSelected ? '0 0 16px rgba(255,107,0,0.3)' : 'none',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '8px',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <img
                      src={prov.logo_url}
                      alt={prov.company_name}
                      style={{ width: '32px', height: '32px', borderRadius: '6px', objectFit: 'cover' }}
                    />
                    <div>
                      <h4 style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff', lineHeight: 1.1 }}>
                        {prov.company_name}
                      </h4>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '2px' }}>
                        <Star size={10} color="#ffb703" fill="#ffb703" />
                        <span style={{ fontSize: '0.65rem', color: '#ffb703', fontWeight: 700 }}>
                          {prov.rating} ({prov.review_count})
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.65rem', color: 'var(--text-secondary)' }}>
                  <span>Deliv: {currencySymbol}{prov.base_delivery_fee.toFixed(0)}</span>
                  <span>ETA: ~{prov.est_delivery_mins}m</span>
                  <span style={{ color: '#4ade80', fontWeight: 700 }}>✓ {prov.safety_score}% Safety</span>
                </div>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setSelectedProviderForModal(prov);
                  }}
                  style={{
                    background: 'rgba(255,255,255,0.06)',
                    color: 'var(--brand-orange)',
                    fontSize: '0.65rem',
                    fontWeight: 700,
                    padding: '4px',
                    borderRadius: '4px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '4px',
                  }}
                >
                  <Info size={12} /> Company Profile & License
                </button>
              </div>
            );
          })}
        </div>
      </div>

      {/* Selected Provider Storefront Banner */}
      <div
        style={{
          background: 'linear-gradient(135deg, rgba(255,107,0,0.2) 0%, rgba(19,27,46,0.95) 100%)',
          border: '1px solid var(--brand-orange)',
          borderRadius: 'var(--radius-md)',
          padding: '14px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <img
            src={currentProvider.logo_url}
            alt={currentProvider.company_name}
            style={{ width: '44px', height: '44px', borderRadius: '8px', objectFit: 'cover', border: '2px solid var(--brand-orange)' }}
          />
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <h3 style={{ fontSize: '0.95rem', fontWeight: 800, color: '#ffffff' }}>{currentProvider.company_name}</h3>
              <CheckCircle2 size={14} color="#00f0ff" />
            </div>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
              License: <strong style={{ color: '#ffffff' }}>{currentProvider.license_number}</strong>
            </p>
          </div>
        </div>

        <button onClick={onViewAllProducts} className="glow-btn" style={{ padding: '8px 12px', fontSize: '0.75rem' }}>
          Order From {currentProvider.company_name.split(' ')[0]}
        </button>
      </div>

      {/* Active Order Banner if present */}
      {activeOrder && activeOrder.status !== 'delivered' && activeOrder.status !== 'cancelled' && (
        <div
          onClick={onTrackOrder}
          style={{
            background: 'linear-gradient(135deg, rgba(0,240,255,0.2), rgba(19,27,46,0.9))',
            border: '1px solid #00f0ff',
            borderRadius: 'var(--radius-md)',
            padding: '12px 14px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            cursor: 'pointer',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Zap size={20} color="#00f0ff" className="pulse-marker" />
            <div>
              <p style={{ fontSize: '0.65rem', color: '#00f0ff', fontWeight: 700 }}>
                LIVE ORDER • {activeOrder.human_id}
              </p>
              <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>
                {activeOrder.status === 'out_for_delivery' ? 'Driver on the way' : 'Order Confirmed & Staged'}
              </p>
            </div>
          </div>
          <ArrowRight size={18} color="#00f0ff" />
        </div>
      )}

      {/* Popular Cylinder Sizes Grid for Selected Provider */}
      <div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
          <h3 style={{ fontSize: '0.95rem', fontWeight: 700, color: '#ffffff' }}>
            Cylinder Sizes ({currentProvider.company_name.split(' ')[0]} Prices)
          </h3>
          <button onClick={onViewAllProducts} style={{ background: 'transparent', color: 'var(--brand-orange)', fontSize: '0.75rem', fontWeight: 700 }}>
            Compare All
          </button>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '10px' }}>
          {products.slice(0, 4).map((product) => {
            const pPrices = currentProvider.prices[product.product_id] || { refill: 195, exchange: 320 };
            return (
              <div
                key={product.product_id}
                onClick={() => onSelectProduct(product)}
                className="glass-panel"
                style={{
                  padding: '12px',
                  cursor: 'pointer',
                  display: 'flex',
                  flexDirection: 'column',
                  justifyContent: 'space-between',
                }}
              >
                <div style={{ position: 'relative', height: '80px', borderRadius: '6px', overflow: 'hidden', marginBottom: '8px' }}>
                  <img src={product.image_url} alt={product.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  <span style={{ position: 'absolute', top: '4px', left: '4px', background: 'var(--brand-orange)', color: '#fff', fontWeight: 800, fontSize: '0.65rem', padding: '2px 6px', borderRadius: '4px' }}>
                    {product.size}
                  </span>
                </div>

                <div>
                  <h4 style={{ fontSize: '0.8rem', fontWeight: 700, color: '#ffffff', lineHeight: 1.1 }}>{product.name}</h4>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginTop: '6px' }}>
                    <span style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>Refill</span>
                    <span style={{ fontSize: '0.9rem', fontWeight: 800, color: 'var(--brand-orange)' }}>
                      {currencySymbol}{pPrices.refill.toFixed(0)}
                    </span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginTop: '2px' }}>
                    <span style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>Exchange</span>
                    <span style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>
                      {currencySymbol}{pPrices.exchange.toFixed(0)}
                    </span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Provider Company Profile Modal */}
      {selectedProviderForModal && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'rgba(0,0,0,0.85)',
            backdropFilter: 'blur(12px)',
            zIndex: 2000,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div className="glass-panel" style={{ width: '100%', maxWidth: '380px', padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <img
                src={selectedProviderForModal.logo_url}
                alt={selectedProviderForModal.company_name}
                style={{ width: '50px', height: '50px', borderRadius: '10px', objectFit: 'cover' }}
              />
              <div>
                <h3 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>{selectedProviderForModal.company_name}</h3>
                <p style={{ fontSize: '0.75rem', color: '#4ade80', fontWeight: 700 }}>✓ Official Compliance License Approved</p>
              </div>
            </div>

            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{selectedProviderForModal.description}</p>

            <div style={{ height: '1px', background: 'var(--border-color)' }} />

            <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
              <div>License Reg: <strong style={{ color: '#ffffff' }}>{selectedProviderForModal.license_number}</strong></div>
              <div>Safety Score: <strong style={{ color: '#00f0ff' }}>{selectedProviderForModal.safety_score}% Verified</strong></div>
              <div>Districts Served: <strong style={{ color: '#ffffff' }}>{selectedProviderForModal.districts_served.join(', ')}</strong></div>
              <div>Contact Phone: <strong style={{ color: '#ffffff' }}>{selectedProviderForModal.contact_phone}</strong></div>
            </div>

            <button
              onClick={() => {
                onSelectProvider(selectedProviderForModal.provider_id);
                setSelectedProviderForModal(null);
              }}
              className="glow-btn"
              style={{ padding: '10px', fontSize: '0.8rem', marginTop: '6px' }}
            >
              Select {selectedProviderForModal.company_name.split(' ')[0]} as Supplier
            </button>

            <button
              onClick={() => setSelectedProviderForModal(null)}
              className="secondary-btn"
              style={{ padding: '8px', fontSize: '0.75rem' }}
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
