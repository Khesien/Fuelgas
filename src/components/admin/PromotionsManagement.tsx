import React, { useState } from 'react';
import { Promotion } from '../../types';
import { Tag, Plus, CheckCircle, Gift, TrendingUp } from 'lucide-react';

interface PromotionsManagementProps {
  promotions: Promotion[];
  currencySymbol: string;
  onAddPromotion: (promo: Omit<Promotion, 'promo_id' | 'redemption_count'>) => void;
}

export const PromotionsManagement: React.FC<PromotionsManagementProps> = ({
  promotions,
  currencySymbol,
  onAddPromotion,
}) => {
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [code, setCode] = useState('');
  const [desc, setDesc] = useState('');
  const [discountType, setDiscountType] = useState<'fixed' | 'percentage'>('fixed');
  const [discountVal, setDiscountVal] = useState<number>(20);
  const [minOrder, setMinOrder] = useState<number>(150);

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!code) return;
    onAddPromotion({
      code: code.toUpperCase(),
      description: desc || `${discountVal} discount code`,
      discount_type: discountType,
      discount_value: Number(discountVal),
      min_order_amount: Number(minOrder),
      valid_until: '2026-12-31',
      max_redemptions: 500,
      is_active: true,
    });
    setShowCreateModal(false);
    setCode('');
    setDesc('');
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>Promotions & Discount Campaigns</h2>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
            Create promo codes, set usage limits, and track redemption revenue impact
          </p>
        </div>

        <button onClick={() => setShowCreateModal(true)} className="glow-btn">
          <Plus size={16} /> Create Coupon Code
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px' }}>
        {promotions.map((promo) => (
          <div key={promo.promo_id} className="glass-panel" style={{ padding: '18px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Tag size={18} color="var(--brand-orange)" />
                <span style={{ fontSize: '1.1rem', fontWeight: 900, color: 'var(--brand-orange)', letterSpacing: '1px' }}>
                  {promo.code}
                </span>
              </div>
              <span
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 800,
                  padding: '2px 8px',
                  borderRadius: '4px',
                  background: promo.is_active ? 'rgba(34,197,94,0.15)' : 'rgba(255,255,255,0.08)',
                  color: promo.is_active ? '#4ade80' : 'var(--text-muted)',
                }}
              >
                {promo.is_active ? 'ACTIVE' : 'EXPIRED'}
              </span>
            </div>

            <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{promo.description}</p>

            <div style={{ height: '1px', background: 'var(--border-color)' }} />

            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
              <span>
                Discount:{' '}
                <strong style={{ color: '#ffffff' }}>
                  {promo.discount_type === 'fixed' ? `${currencySymbol}${promo.discount_value}` : `${promo.discount_value}%`}
                </strong>
              </span>
              <span>
                Min Order: <strong style={{ color: '#ffffff' }}>{currencySymbol}{promo.min_order_amount}</strong>
              </span>
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
              <span>Redeemed: <strong style={{ color: '#00f0ff' }}>{promo.redemption_count} times</strong></span>
              <span>Valid Until: <strong style={{ color: '#ffffff' }}>{promo.valid_until}</strong></span>
            </div>
          </div>
        ))}
      </div>

      {showCreateModal && (
        <form onSubmit={handleCreate} className="glass-panel" style={{ padding: '20px', maxWidth: '480px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <h3 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>Create New Promo Code</h3>
          <input
            type="text"
            placeholder="Coupon Code (e.g. SUMMER30)"
            value={code}
            onChange={(e) => setCode(e.target.value)}
            style={{ padding: '10px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '6px', color: '#fff', fontSize: '0.85rem' }}
          />
          <input
            type="text"
            placeholder="Description"
            value={desc}
            onChange={(e) => setDesc(e.target.value)}
            style={{ padding: '10px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '6px', color: '#fff', fontSize: '0.85rem' }}
          />
          <div style={{ display: 'flex', gap: '10px' }}>
            <input
              type="number"
              placeholder="Discount Value"
              value={discountVal}
              onChange={(e) => setDiscountVal(Number(e.target.value))}
              style={{ flex: 1, padding: '10px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '6px', color: '#fff' }}
            />
            <select
              value={discountType}
              onChange={(e) => setDiscountType(e.target.value as any)}
              style={{ padding: '10px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '6px', color: '#fff' }}
            >
              <option value="fixed">Fixed ({currencySymbol})</option>
              <option value="percentage">Percentage (%)</option>
            </select>
          </div>
          <div style={{ display: 'flex', gap: '10px', justifyContent: 'flex-end', marginTop: '10px' }}>
            <button type="button" onClick={() => setShowCreateModal(false)} className="secondary-btn">Cancel</button>
            <button type="submit" className="glow-btn">Save Promo</button>
          </div>
        </form>
      )}
    </div>
  );
};
