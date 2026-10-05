import React from 'react';
import { Driver } from '../../types';
import { ShieldCheck, Truck, Phone, Mail, FileText, Power, Award } from 'lucide-react';

interface DriverProfileProps {
  driver: Driver;
  onToggleOnline: () => void;
}

export const DriverProfile: React.FC<DriverProfileProps> = ({ driver, onToggleOnline }) => {
  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Profile Header */}
      <div className="glass-panel" style={{ padding: '16px', display: 'flex', alignItems: 'center', gap: '14px' }}>
        <img
          src={driver.photo_url}
          alt={driver.full_name}
          style={{ width: '60px', height: '60px', borderRadius: '50%', objectFit: 'cover', border: '2px solid var(--brand-orange)' }}
        />
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <h2 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>{driver.full_name}</h2>
            <ShieldCheck size={16} color="#00f0ff" />
          </div>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{driver.email}</p>
          <span
            style={{
              display: 'inline-block',
              marginTop: '4px',
              padding: '2px 8px',
              borderRadius: '4px',
              fontSize: '0.65rem',
              fontWeight: 800,
              background: 'rgba(34, 197, 94, 0.15)',
              color: '#4ade80',
              border: '1px solid rgba(34, 197, 94, 0.3)',
            }}
          >
            ✓ ACCOUNT VERIFIED
          </span>
        </div>
      </div>

      {/* Online / Offline Availability Switch Banner */}
      <div
        className="glass-panel"
        style={{
          padding: '14px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          borderColor: driver.status === 'online' ? 'var(--brand-orange)' : 'var(--border-color)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <Power size={22} color={driver.status === 'online' ? '#4ade80' : 'var(--text-muted)'} />
          <div>
            <h4 style={{ fontSize: '0.9rem', fontWeight: 800, color: '#ffffff' }}>
              Duty Status: <span style={{ color: driver.status === 'online' ? '#4ade80' : 'var(--text-muted)' }}>{driver.status.toUpperCase()}</span>
            </h4>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
              {driver.status === 'online' ? 'Receiving incoming job requests nearby' : 'Offline. Tap toggle to go online.'}
            </p>
          </div>
        </div>

        <button
          onClick={onToggleOnline}
          style={{
            padding: '8px 16px',
            borderRadius: 'var(--radius-full)',
            fontWeight: 800,
            fontSize: '0.8rem',
            background: driver.status === 'online' ? '#4ade80' : 'rgba(255,255,255,0.1)',
            color: driver.status === 'online' ? '#0f172a' : '#ffffff',
          }}
        >
          {driver.status === 'online' ? 'GO OFFLINE' : 'GO ONLINE'}
        </button>
      </div>

      {/* Vehicle Credentials */}
      <div className="glass-panel" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <h3 style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>Registered Vehicle & License</h3>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <Truck size={20} color="var(--brand-orange)" />
          <div>
            <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>{driver.vehicle_type}</p>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Plate Reg: {driver.vehicle_number}</p>
          </div>
        </div>

        <div style={{ height: '1px', background: 'var(--border-color)' }} />

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <FileText size={20} color="#00f0ff" />
          <div>
            <p style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Driver's License</p>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>License No: {driver.license_no}</p>
          </div>
        </div>
      </div>
    </div>
  );
};
