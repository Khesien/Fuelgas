import React, { useState } from 'react';
import { Driver } from '../../types';
import { ShieldCheck, Truck, Star, CheckCircle, XCircle, FileText, UserCheck } from 'lucide-react';

interface DriverManagementProps {
  drivers: Driver[];
  onVerifyDriver: (driverId: string, approve: boolean) => void;
  onToggleStatus: (driverId: string) => void;
}

export const DriverManagement: React.FC<DriverManagementProps> = ({ drivers, onVerifyDriver, onToggleStatus }) => {
  const [selectedDriverForDoc, setSelectedDriverForDoc] = useState<Driver | null>(null);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>Driver Fleet & Verification Management</h2>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
          Review driver applications, verify license documents, and monitor performance
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '16px' }}>
        {drivers.map((driver) => (
          <div key={driver.driver_id} className="glass-panel" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <img
                src={driver.photo_url}
                alt={driver.full_name}
                style={{ width: '48px', height: '48px', borderRadius: '50%', objectFit: 'cover', border: '2px solid var(--brand-orange)' }}
              />
              <div style={{ flex: 1 }}>
                <h4 style={{ fontSize: '0.95rem', fontWeight: 800, color: '#ffffff' }}>{driver.full_name}</h4>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{driver.phone}</p>
                <div style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
                  <span className={`status-badge ${driver.status}`}>{driver.status}</span>
                  <span
                    style={{
                      fontSize: '0.65rem',
                      fontWeight: 800,
                      padding: '2px 6px',
                      borderRadius: '4px',
                      background: driver.verification_status === 'approved' ? 'rgba(34,197,94,0.15)' : 'rgba(255,183,3,0.15)',
                      color: driver.verification_status === 'approved' ? '#4ade80' : '#ffb703',
                    }}
                  >
                    {driver.verification_status.toUpperCase()}
                  </span>
                </div>
              </div>
            </div>

            <div style={{ height: '1px', background: 'var(--border-color)' }} />

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '8px', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
              <div>
                Vehicle: <strong style={{ color: '#ffffff' }}>{driver.vehicle_type}</strong>
              </div>
              <div>
                Plate: <strong style={{ color: '#ffffff' }}>{driver.vehicle_number}</strong>
              </div>
              <div>
                License: <strong style={{ color: '#ffffff' }}>{driver.license_no}</strong>
              </div>
              <div>
                Completed: <strong style={{ color: '#ffffff' }}>{driver.completed_orders} trips</strong>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '8px', marginTop: '6px' }}>
              {driver.verification_status === 'pending' ? (
                <>
                  <button
                    onClick={() => onVerifyDriver(driver.driver_id, true)}
                    className="glow-btn"
                    style={{ flex: 1, padding: '6px', fontSize: '0.75rem', background: 'linear-gradient(135deg, #22c55e, #16a34a)' }}
                  >
                    <CheckCircle size={14} /> Approve Driver
                  </button>
                  <button
                    onClick={() => onVerifyDriver(driver.driver_id, false)}
                    style={{
                      flex: 1,
                      padding: '6px',
                      fontSize: '0.75rem',
                      background: 'rgba(239,68,68,0.2)',
                      color: '#f87171',
                      borderRadius: '6px',
                    }}
                  >
                    <XCircle size={14} /> Reject
                  </button>
                </>
              ) : (
                <button
                  onClick={() => onToggleStatus(driver.driver_id)}
                  className="secondary-btn"
                  style={{ flex: 1, padding: '6px', fontSize: '0.75rem' }}
                >
                  Toggle {driver.status === 'online' ? 'Offline' : 'Online'}
                </button>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
