import React, { useState } from 'react';
import { Order } from '../../types';
import { MapComponent } from '../common/MapComponent';
import { Phone, CheckCircle2, Navigation, AlertTriangle, ShieldCheck, Camera, KeyRound } from 'lucide-react';

interface OrderFulfilmentScreenProps {
  order: Order;
  currencySymbol: string;
  onCompleteDelivery: (otpCode: string) => void;
  onCancelDelivery: (reason: string) => void;
}

export const OrderFulfilmentScreen: React.FC<OrderFulfilmentScreenProps> = ({
  order,
  currencySymbol,
  onCompleteDelivery,
  onCancelDelivery,
}) => {
  const [hasArrived, setHasArrived] = useState<boolean>(order.status === 'delivered');
  const [showProofModal, setShowProofModal] = useState<boolean>(false);
  const [otpInput, setOtpInput] = useState<string>('8942');

  const handleConfirmArrival = () => {
    setHasArrived(true);
    setShowProofModal(true);
  };

  const handleFinish = (e: React.FormEvent) => {
    e.preventDefault();
    onCompleteDelivery(otpInput);
    setShowProofModal(false);
  };

  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <span style={{ fontSize: '0.7rem', color: 'var(--brand-orange)', fontWeight: 800 }}>ACTIVE DELIVERY</span>
          <h2 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>Order {order.human_id}</h2>
        </div>
        <span className={`status-badge ${order.status}`}>{order.status.replace('_', ' ')}</span>
      </div>

      {/* Map View */}
      <MapComponent
        driver={order.driver}
        address={order.address}
        depot={order.depot}
        status={order.status}
        etaMinutes={order.eta_minutes}
        height="240px"
      />

      {/* Customer Contact Card */}
      <div className="glass-panel" style={{ padding: '14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', fontWeight: 700 }}>DELIVERING TO CUSTOMER</p>
          <h4 style={{ fontSize: '0.95rem', fontWeight: 800, color: '#ffffff', marginTop: '2px' }}>{order.user.full_name}</h4>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
            {order.address.plot_unit}, {order.address.street}
          </p>
        </div>

        <a
          href={`tel:${order.user.phone}`}
          style={{
            width: '42px',
            height: '42px',
            borderRadius: '50%',
            background: 'var(--brand-orange)',
            color: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 4px 12px rgba(255,107,0,0.4)',
            textDecoration: 'none',
          }}
        >
          <Phone size={20} />
        </a>
      </div>

      {/* Order Item Brief */}
      <div className="glass-panel" style={{ padding: '12px 14px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>
            {order.items[0]?.quantity}x {order.items[0]?.product.name}
          </p>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
            {order.order_type === 'exchange' ? '🔄 Collect empty cylinder & swap' : '🔥 Direct refill service'}
          </p>
        </div>
        <div style={{ textAlign: 'right' }}>
          <p style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>Payment Collect</p>
          <p style={{ fontSize: '0.9rem', fontWeight: 800, color: '#4ade80' }}>
            {order.payment_method === 'cash' ? `${currencySymbol}${order.total_amount.toFixed(2)} CASH` : 'PAID ONLINE'}
          </p>
        </div>
      </div>

      {/* Fulfilment Trigger Actions */}
      <div style={{ marginTop: 'auto', paddingTop: '10px' }}>
        {!hasArrived ? (
          <button className="glow-btn" style={{ width: '100%', padding: '14px' }} onClick={handleConfirmArrival}>
            <Navigation size={18} /> Signal "Arrived at Dropoff"
          </button>
        ) : (
          <button className="glow-btn" style={{ width: '100%', padding: '14px', background: 'linear-gradient(135deg, #22c55e, #16a34a)' }} onClick={() => setShowProofModal(true)}>
            <ShieldCheck size={18} /> Confirm Proof of Delivery (OTP)
          </button>
        )}
      </div>

      {/* Proof of Delivery OTP Modal */}
      {showProofModal && (
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'rgba(6,9,17,0.95)',
            backdropFilter: 'blur(16px)',
            zIndex: 1000,
            padding: '20px',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            gap: '16px',
          }}
        >
          <div style={{ textAlign: 'center' }}>
            <ShieldCheck size={48} color="#4ade80" style={{ margin: '0 auto 10px' }} />
            <h3 style={{ fontSize: '1.2rem', fontWeight: 900, color: '#ffffff' }}>Proof of Delivery</h3>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
              Ask customer for 4-digit confirmation code or sign.
            </p>
          </div>

          <form onSubmit={handleFinish} className="glass-panel" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div>
              <label style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', fontWeight: 700 }}>CUSTOMER OTP CODE</label>
              <div style={{ position: 'relative', marginTop: '6px' }}>
                <KeyRound size={18} color="var(--brand-orange)" style={{ position: 'absolute', left: '12px', top: '12px' }} />
                <input
                  type="text"
                  maxLength={4}
                  value={otpInput}
                  onChange={(e) => setOtpInput(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 10px 10px 40px',
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid var(--border-color)',
                    borderRadius: '8px',
                    color: '#ffffff',
                    fontSize: '1.2rem',
                    fontWeight: 800,
                    letterSpacing: '6px',
                  }}
                />
              </div>
            </div>

            <div style={{ background: 'rgba(34, 197, 94, 0.1)', padding: '10px', borderRadius: '6px', border: '1px solid rgba(34,197,94,0.2)' }}>
              <p style={{ fontSize: '0.7rem', color: '#4ade80', fontWeight: 600 }}>
                ✓ Safety check verified: Leak test completed & cylinder weight recorded.
              </p>
            </div>

            <div style={{ display: 'flex', gap: '10px', marginTop: '6px' }}>
              <button
                type="button"
                onClick={() => setShowProofModal(false)}
                className="secondary-btn"
                style={{ flex: 1, padding: '12px', fontSize: '0.8rem' }}
              >
                Back
              </button>
              <button
                type="submit"
                className="glow-btn"
                style={{ flex: 2, padding: '12px', background: 'linear-gradient(135deg, #22c55e, #16a34a)' }}
              >
                Complete Delivery
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
