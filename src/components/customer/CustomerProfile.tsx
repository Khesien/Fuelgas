import React, { useState } from 'react';
import { User, Address, Order } from '../../types';
import { MapPin, Plus, Gift, History, HelpCircle, Copy, Check, RefreshCw } from 'lucide-react';

interface CustomerProfileProps {
  user: User;
  addresses: Address[];
  onAddAddress: (newAddr: Omit<Address, 'address_id' | 'user_id'>) => void;
  orders: Order[];
  currencySymbol: string;
  onReorder: (order: Order) => void;
  onTrackOrder: (order: Order) => void;
}

export const CustomerProfile: React.FC<CustomerProfileProps> = ({
  user,
  addresses,
  onAddAddress,
  orders,
  currencySymbol,
  onReorder,
  onTrackOrder,
}) => {
  const [activeTab, setActiveTab] = useState<'addresses' | 'history' | 'referrals' | 'help'>('history');
  const [copiedCode, setCopiedCode] = useState(false);

  const [showAddModal, setShowAddModal] = useState(false);
  const [labelInput, setLabelInput] = useState('');
  const [streetInput, setStreetInput] = useState('');
  const [unitInput, setUnitInput] = useState('');

  const handleCopy = () => {
    navigator.clipboard?.writeText(user.referral_code);
    setCopiedCode(true);
    setTimeout(() => setCopiedCode(false), 2000);
  };

  const handleSaveAddress = (e: React.FormEvent) => {
    e.preventDefault();
    if (!streetInput) return;
    onAddAddress({
      label: labelInput || 'Home',
      plot_unit: unitInput || 'Plot 100',
      street: streetInput,
      city: 'Gaborone',
      district: 'Gaborone Central',
      latitude: -24.6541,
      longitude: 25.9087,
      is_default: false,
    });
    setShowAddModal(false);
    setLabelInput('');
    setStreetInput('');
    setUnitInput('');
  };

  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Profile Info Header */}
      <div className="glass-panel" style={{ padding: '16px', display: 'flex', alignItems: 'center', gap: '14px' }}>
        <img
          src={user.profile_photo}
          alt={user.full_name}
          style={{ width: '56px', height: '56px', borderRadius: '50%', objectFit: 'cover', border: '2px solid var(--brand-orange)' }}
        />
        <div style={{ flex: 1 }}>
          <h2 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>{user.full_name}</h2>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{user.email}</p>
          <p style={{ fontSize: '0.75rem', color: 'var(--brand-orange)', fontWeight: 600 }}>{user.phone}</p>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '6px' }}>
        {[
          { key: 'history', label: 'Orders', icon: <History size={14} /> },
          { key: 'addresses', label: 'Saved Addr', icon: <MapPin size={14} /> },
          { key: 'referrals', label: 'Referrals', icon: <Gift size={14} /> },
          { key: 'help', label: 'Support', icon: <HelpCircle size={14} /> },
        ].map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key as any)}
            style={{
              padding: '8px 4px',
              borderRadius: 'var(--radius-sm)',
              fontSize: '0.7rem',
              fontWeight: 700,
              background: activeTab === tab.key ? 'var(--brand-orange)' : 'rgba(255,255,255,0.08)',
              color: '#ffffff',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: '4px',
            }}
          >
            {tab.icon}
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Content: History */}
      {activeTab === 'history' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <h3 style={{ fontSize: '0.9rem', fontWeight: 800, color: '#ffffff' }}>Past Orders</h3>
          {orders.map((ord) => (
            <div key={ord.order_id} className="glass-panel" style={{ padding: '12px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>{ord.human_id}</span>
                <span className={`status-badge ${ord.status}`}>{ord.status.replace('_', ' ')}</span>
              </div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                {ord.items[0]?.quantity}x {ord.items[0]?.product.name} ({ord.order_type})
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '6px', borderTop: '1px solid var(--border-color)' }}>
                <span style={{ fontSize: '0.9rem', fontWeight: 800, color: 'var(--brand-orange)' }}>
                  {currencySymbol}{ord.total_amount.toFixed(2)}
                </span>
                <div style={{ display: 'flex', gap: '8px' }}>
                  {ord.status !== 'delivered' && ord.status !== 'cancelled' ? (
                    <button
                      onClick={() => onTrackOrder(ord)}
                      className="glow-btn"
                      style={{ padding: '6px 12px', fontSize: '0.7rem' }}
                    >
                      Track Order
                    </button>
                  ) : (
                    <button
                      onClick={() => onReorder(ord)}
                      className="secondary-btn"
                      style={{ padding: '6px 12px', fontSize: '0.7rem' }}
                    >
                      <RefreshCw size={12} /> Re-order
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Tab Content: Addresses */}
      {activeTab === 'addresses' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h3 style={{ fontSize: '0.9rem', fontWeight: 800, color: '#ffffff' }}>Saved Addresses</h3>
            <button
              onClick={() => setShowAddModal(true)}
              style={{
                background: 'var(--brand-orange)',
                color: '#ffffff',
                fontSize: '0.75rem',
                fontWeight: 700,
                padding: '6px 10px',
                borderRadius: '6px',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
              }}
            >
              <Plus size={14} /> Add New
            </button>
          </div>

          {addresses.map((addr) => (
            <div key={addr.address_id} className="glass-panel" style={{ padding: '12px', display: 'flex', gap: '10px' }}>
              <MapPin size={20} color="var(--brand-orange)" />
              <div>
                <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>
                  {addr.label} {addr.is_default && <span style={{ fontSize: '0.65rem', color: 'var(--brand-orange)' }}>(Default)</span>}
                </p>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  {addr.plot_unit}, {addr.street}, {addr.district}
                </p>
              </div>
            </div>
          ))}

          {showAddModal && (
            <form onSubmit={handleSaveAddress} className="glass-panel" style={{ padding: '14px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
              <h4 style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>New Address</h4>
              <input
                type="text"
                placeholder="Label (e.g. Aunt's House)"
                value={labelInput}
                onChange={(e) => setLabelInput(e.target.value)}
                style={{ padding: '8px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '6px', color: '#fff', fontSize: '0.8rem' }}
              />
              <input
                type="text"
                placeholder="Plot/Unit Number (e.g. Plot 8841)"
                value={unitInput}
                onChange={(e) => setUnitInput(e.target.value)}
                style={{ padding: '8px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '6px', color: '#fff', fontSize: '0.8rem' }}
              />
              <input
                type="text"
                placeholder="Street & Area (e.g. Tlokweng Main Rd)"
                value={streetInput}
                onChange={(e) => setStreetInput(e.target.value)}
                style={{ padding: '8px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '6px', color: '#fff', fontSize: '0.8rem' }}
              />
              <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end', marginTop: '6px' }}>
                <button type="button" onClick={() => setShowAddModal(false)} className="secondary-btn" style={{ padding: '6px 12px', fontSize: '0.75rem' }}>
                  Cancel
                </button>
                <button type="submit" className="glow-btn" style={{ padding: '6px 12px', fontSize: '0.75rem' }}>
                  Save Address
                </button>
              </div>
            </form>
          )}
        </div>
      )}

      {/* Tab Content: Referrals */}
      {activeTab === 'referrals' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div
            style={{
              background: 'linear-gradient(135deg, rgba(255,107,0,0.2), rgba(19,27,46,0.9))',
              border: '1px solid var(--brand-orange)',
              borderRadius: 'var(--radius-md)',
              padding: '16px',
            }}
          >
            <span style={{ fontSize: '0.7rem', color: 'var(--brand-orange)', fontWeight: 700 }}>REFERRAL REWARDS WALLET</span>
            <h2 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#ffffff', marginTop: '4px' }}>
              {currencySymbol}{user.referral_earnings.toFixed(2)}
            </h2>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
              Available to spend on your next LPG cylinder order.
            </p>
          </div>

          <div className="glass-panel" style={{ padding: '14px' }}>
            <h4 style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Your Unique Referral Code</h4>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                background: 'rgba(255,255,255,0.05)',
                border: '1px dashed var(--brand-orange)',
                borderRadius: '8px',
                padding: '10px 14px',
                marginTop: '10px',
              }}
            >
              <span style={{ fontSize: '1.1rem', fontWeight: 900, color: 'var(--brand-orange)', letterSpacing: '1px' }}>
                {user.referral_code}
              </span>
              <button onClick={handleCopy} className="secondary-btn" style={{ padding: '6px 10px', fontSize: '0.75rem' }}>
                {copiedCode ? <Check size={14} color="#4ade80" /> : <Copy size={14} />}
                {copiedCode ? 'Copied!' : 'Copy Code'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Tab Content: Support */}
      {activeTab === 'help' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <h3 style={{ fontSize: '0.9rem', fontWeight: 800, color: '#ffffff' }}>Help & Support FAQs</h3>
          {[
            { q: 'How long does a gas cylinder delivery take?', a: 'Standard delivery takes between 25 to 45 minutes depending on your district depot.' },
            { q: 'What is the difference between Refill and Exchange?', a: 'Exchange swaps your empty cylinder for a pre-filled full one immediately. Refill takes your cylinder to depot for filling.' },
            { q: 'What payment methods are supported?', a: 'We accept Orange Money, Mascom MyZaka, Visa/MasterCard, and Cash on Delivery.' },
          ].map((faq, i) => (
            <div key={i} className="glass-panel" style={{ padding: '12px' }}>
              <h4 style={{ fontSize: '0.8rem', fontWeight: 700, color: '#ffffff' }}>{faq.q}</h4>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '4px' }}>{faq.a}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
