import React from 'react';
import { UserRole } from '../../types';
import { Flame, Smartphone, Truck, ShieldCheck, Zap, Maximize2, Minimize2, RefreshCw, Crown, Building2 } from 'lucide-react';

interface HeaderProps {
  activeRole: UserRole;
  setActiveRole: (role: UserRole) => void;
  mobileViewMode: 'frame' | 'fullscreen';
  setMobileViewMode: (mode: 'frame' | 'fullscreen') => void;
  onSimulateOrder: () => void;
  onAdvanceDriver: () => void;
  currencySymbol: string;
  setCurrencySymbol: (sym: string) => void;
}

export const Header: React.FC<HeaderProps> = ({
  activeRole,
  setActiveRole,
  mobileViewMode,
  setMobileViewMode,
  onSimulateOrder,
  onAdvanceDriver,
  currencySymbol,
  setCurrencySymbol,
}) => {
  return (
    <header className="role-switcher-bar">
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <div
          style={{
            width: '38px',
            height: '38px',
            borderRadius: '10px',
            background: 'linear-gradient(135deg, #ff6b00, #ff8833)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 0 12px rgba(255,107,0,0.5)',
          }}
        >
          <Flame size={22} color="#ffffff" />
        </div>
        <div>
          <h1 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff', lineHeight: 1.1 }}>
            GAS DELIVERY
          </h1>
          <p style={{ fontSize: '0.65rem', color: 'var(--brand-orange)', fontWeight: 600, letterSpacing: '0.5px' }}>
            ON-DEMAND LPG MARKETPLACE
          </p>
        </div>
      </div>

      {/* Role Switcher Tabs */}
      <div className="role-switcher-tabs">
        <button
          className={`role-tab-btn ${activeRole === 'customer' ? 'active' : ''}`}
          onClick={() => setActiveRole('customer')}
        >
          <Smartphone size={16} />
          Customer App
        </button>

        <button
          className={`role-tab-btn ${activeRole === 'driver' ? 'active' : ''}`}
          onClick={() => setActiveRole('driver')}
        >
          <Truck size={16} />
          Driver App
        </button>

        <button
          className={`role-tab-btn ${activeRole === 'provider_admin' ? 'active' : ''}`}
          onClick={() => setActiveRole('provider_admin')}
        >
          <Building2 size={16} />
          Provider Admin
        </button>

        <button
          className={`role-tab-btn ${activeRole === 'super_admin' ? 'active' : ''}`}
          onClick={() => setActiveRole('super_admin')}
          style={{
            background: activeRole === 'super_admin' ? 'linear-gradient(135deg, #00f0ff, #0088ff)' : 'transparent',
            color: activeRole === 'super_admin' ? '#ffffff' : 'var(--text-secondary)',
          }}
        >
          <Crown size={16} />
          Super Admin
        </button>
      </div>

      {/* Controls & Quick Simulations */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
        <select
          value={currencySymbol}
          onChange={(e) => setCurrencySymbol(e.target.value)}
          style={{
            background: 'rgba(255,255,255,0.08)',
            color: '#cbd5e1',
            border: '1px solid var(--border-color)',
            padding: '6px 10px',
            borderRadius: '6px',
            fontSize: '0.8rem',
            fontWeight: 600,
            cursor: 'pointer',
          }}
          title="Switch Market Currency"
        >
          <option value="P">BWP (Pula P)</option>
          <option value="$">USD ($)</option>
          <option value="R">ZAR (Rand R)</option>
          <option value="KSh">KES (KSh)</option>
        </select>

        {activeRole === 'customer' || activeRole === 'driver' ? (
          <button
            className="secondary-btn"
            style={{ padding: '6px 10px', fontSize: '0.8rem' }}
            onClick={() => setMobileViewMode(mobileViewMode === 'frame' ? 'fullscreen' : 'frame')}
            title="Toggle Device Frame vs Full View"
          >
            {mobileViewMode === 'frame' ? <Maximize2 size={14} /> : <Minimize2 size={14} />}
            {mobileViewMode === 'frame' ? 'Full View' : 'Device Frame'}
          </button>
        ) : null}

        <button
          className="demo-action-btn"
          onClick={onSimulateOrder}
          title="Trigger a new customer order instantly"
        >
          <Zap size={14} />
          Simulate Order
        </button>

        <button
          className="demo-action-btn"
          onClick={onAdvanceDriver}
          style={{ borderColor: 'rgba(255,107,0,0.4)', color: 'var(--brand-orange)', background: 'rgba(255,107,0,0.1)' }}
          title="Advance live order to next state"
        >
          <RefreshCw size={14} />
          Advance State
        </button>
      </div>
    </header>
  );
};
