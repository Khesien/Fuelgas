import React from 'react';
import { Settings, Globe, Shield, CreditCard, Bell, MapPin } from 'lucide-react';

interface SettingsViewProps {
  currencySymbol: string;
  setCurrencySymbol: (sym: string) => void;
  deliveryFee: number;
}

export const SettingsView: React.FC<SettingsViewProps> = ({
  currencySymbol,
  setCurrencySymbol,
  deliveryFee,
}) => {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', maxWidth: '800px' }}>
      <div>
        <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>System & Operational Settings</h2>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
          Configure currency localization, delivery pricing rules, and third-party integrations
        </p>
      </div>

      {/* Localisation */}
      <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Globe size={20} color="var(--brand-orange)" />
          <h3 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>Currency & Market Localisation</h3>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Active Market Currency</p>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Format displayed across all apps</p>
          </div>

          <select
            value={currencySymbol}
            onChange={(e) => setCurrencySymbol(e.target.value)}
            style={{
              padding: '8px 12px',
              background: 'rgba(255,255,255,0.08)',
              border: '1px solid var(--border-color)',
              borderRadius: '6px',
              color: '#ffffff',
              fontWeight: 700,
            }}
          >
            <option value="P">Botswana Pula (P)</option>
            <option value="$">USD ($)</option>
            <option value="R">South African Rand (R)</option>
            <option value="KSh">Kenya Shilling (KSh)</option>
          </select>
        </div>
      </div>

      {/* Delivery Fee Rule */}
      <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <MapPin size={20} color="#00f0ff" />
          <h3 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>Delivery Pricing Rules</h3>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Base Delivery Fee</p>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Standard charge per order delivery</p>
          </div>

          <span style={{ fontSize: '1.1rem', fontWeight: 800, color: 'var(--brand-orange)' }}>
            {currencySymbol}{deliveryFee.toFixed(2)}
          </span>
        </div>
      </div>

      {/* Payment Integration Gateways */}
      <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <CreditCard size={20} color="#4ade80" />
          <h3 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>Connected Gateways</h3>
        </div>

        {[
          { name: 'Orange Money Webhook API', status: 'ACTIVE', color: '#4ade80' },
          { name: 'Mascom MyZaka Merchant API', status: 'ACTIVE', color: '#4ade80' },
          { name: 'Stripe / Card 3D-Secure', status: 'ACTIVE', color: '#4ade80' },
          { name: 'Google Maps Routing Service', status: 'CONNECTED', color: '#00f0ff' },
        ].map((gw, idx) => (
          <div key={idx} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 0', borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>{gw.name}</span>
            <span style={{ fontSize: '0.7rem', fontWeight: 800, color: gw.color }}>✓ {gw.status}</span>
          </div>
        ))}
      </div>
    </div>
  );
};
