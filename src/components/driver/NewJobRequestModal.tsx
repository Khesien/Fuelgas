import React, { useState, useEffect } from 'react';
import { Order } from '../../types';
import { MapPin, Warehouse, Check, X, Clock, DollarSign, Package } from 'lucide-react';

interface NewJobRequestModalProps {
  order: Order;
  currencySymbol: string;
  onAccept: () => void;
  onDecline: () => void;
}

export const NewJobRequestModal: React.FC<NewJobRequestModalProps> = ({
  order,
  currencySymbol,
  onAccept,
  onDecline,
}) => {
  const [secondsLeft, setSecondsLeft] = useState<number>(30);

  useEffect(() => {
    if (secondsLeft <= 0) {
      onDecline();
      return;
    }
    const timer = setInterval(() => {
      setSecondsLeft((prev) => prev - 1);
    }, 1000);
    return () => clearInterval(timer);
  }, [secondsLeft, onDecline]);

  const driverPayout = order.delivery_fee + 10; // delivery fee + tip/bonus

  return (
    <div
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background: 'rgba(6, 9, 17, 0.92)',
        backdropFilter: 'blur(16px)',
        zIndex: 1000,
        padding: '20px',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        gap: '16px',
      }}
    >
      {/* Alert Header */}
      <div style={{ textAlign: 'center' }}>
        <span
          style={{
            background: 'var(--brand-orange)',
            color: '#ffffff',
            fontWeight: 800,
            fontSize: '0.7rem',
            padding: '4px 12px',
            borderRadius: '20px',
            textTransform: 'uppercase',
            letterSpacing: '1px',
          }}
          className="pulse-marker"
        >
          🔥 NEW DELIVERY JOB REQUEST
        </span>

        <h2 style={{ fontSize: '1.4rem', fontWeight: 900, color: '#ffffff', marginTop: '10px' }}>
          {currencySymbol}{driverPayout.toFixed(2)} Payout
        </h2>
        <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
          Order {order.human_id} • Est. distance 4.2 km
        </p>
      </div>

      {/* Countdown Progress Circle */}
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        <div
          style={{
            width: '64px',
            height: '64px',
            borderRadius: '50%',
            border: '4px solid var(--brand-orange)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '1.3rem',
            fontWeight: 900,
            color: '#ffffff',
            boxShadow: '0 0 20px rgba(255,107,0,0.5)',
          }}
        >
          {secondsLeft}s
        </div>
      </div>

      {/* Pickup & Dropoff Route Details Card */}
      <div className="glass-panel" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
        {/* Pickup Depot */}
        <div style={{ display: 'flex', gap: '12px' }}>
          <div
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '50%',
              background: 'rgba(0,240,255,0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Warehouse size={16} color="#00f0ff" />
          </div>
          <div>
            <span style={{ fontSize: '0.65rem', color: '#00f0ff', fontWeight: 700 }}>PICKUP DEPOT</span>
            <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>{order.depot?.name}</p>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>{order.depot?.address}</p>
          </div>
        </div>

        <div style={{ height: '1px', background: 'var(--border-color)' }} />

        {/* Dropoff Customer */}
        <div style={{ display: 'flex', gap: '12px' }}>
          <div
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '50%',
              background: 'rgba(255,107,0,0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <MapPin size={16} color="var(--brand-orange)" />
          </div>
          <div>
            <span style={{ fontSize: '0.65rem', color: 'var(--brand-orange)', fontWeight: 700 }}>DROPOFF LOCATION</span>
            <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>
              {order.address.label} ({order.user.full_name})
            </p>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
              {order.address.plot_unit}, {order.address.street}
            </p>
          </div>
        </div>
      </div>

      {/* Items Summary Card */}
      <div className="glass-panel" style={{ padding: '12px 14px', display: 'flex', alignItems: 'center', gap: '10px' }}>
        <Package size={20} color="var(--brand-orange)" />
        <div>
          <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>
            {order.items[0]?.quantity}x {order.items[0]?.product.name}
          </p>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
            Service Type: <strong style={{ textTransform: 'capitalize', color: '#ffffff' }}>{order.order_type}</strong>
          </p>
        </div>
      </div>

      {/* Action Buttons */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '12px', marginTop: '10px' }}>
        <button
          onClick={onDecline}
          style={{
            background: 'rgba(239, 68, 68, 0.15)',
            color: '#f87171',
            border: '1px solid rgba(239, 68, 68, 0.3)',
            fontWeight: 800,
            borderRadius: 'var(--radius-md)',
            padding: '14px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '6px',
          }}
        >
          <X size={18} /> Decline
        </button>

        <button
          onClick={onAccept}
          className="glow-btn"
          style={{ padding: '14px', fontSize: '0.95rem' }}
        >
          <Check size={20} /> ACCEPT JOB
        </button>
      </div>
    </div>
  );
};
