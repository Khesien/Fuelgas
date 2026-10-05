import React from 'react';
import { Order, OrderStatus } from '../../types';
import { MapComponent } from '../common/MapComponent';
import { ArrowLeft, Phone, Star, ShieldCheck, CheckCircle2, Clock, Truck, Warehouse } from 'lucide-react';

interface OrderTrackingScreenProps {
  order: Order;
  currencySymbol: string;
  onBack: () => void;
}

export const OrderTrackingScreen: React.FC<OrderTrackingScreenProps> = ({ order, currencySymbol, onBack }) => {
  const steps: { status: OrderStatus; label: string; desc: string; icon: React.ReactNode }[] = [
    { status: 'confirmed', label: 'Order Confirmed', desc: 'Order received & payment authorized', icon: <CheckCircle2 size={16} /> },
    { status: 'preparing', label: 'Preparing at Depot', desc: 'Cylinder inspected & staged for driver', icon: <Warehouse size={16} /> },
    { status: 'out_for_delivery', label: 'Out for Delivery', desc: 'Driver on the way to your address', icon: <Truck size={16} /> },
    { status: 'delivered', label: 'Delivered', desc: 'Safety check & handed over to customer', icon: <ShieldCheck size={16} /> },
  ];

  const getStepIndex = (status: OrderStatus) => {
    switch (status) {
      case 'pending_payment': return 0;
      case 'confirmed': return 0;
      case 'preparing': return 1;
      case 'out_for_delivery': return 2;
      case 'delivered': return 3;
      default: return 0;
    }
  };

  const currentStepIdx = getStepIndex(order.status);

  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <button
            onClick={onBack}
            style={{
              width: '34px',
              height: '34px',
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
            <h2 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>Track Delivery</h2>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>Order {order.human_id}</p>
          </div>
        </div>

        <span className={`status-badge ${order.status}`}>
          {order.status.replace('_', ' ')}
        </span>
      </div>

      {/* Interactive Map Component */}
      <MapComponent
        driver={order.driver}
        address={order.address}
        depot={order.depot}
        status={order.status}
        etaMinutes={order.eta_minutes}
        height="220px"
      />

      {/* Driver Info Card */}
      {order.driver && (
        <div className="glass-panel" style={{ padding: '14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <img
              src={order.driver.photo_url}
              alt={order.driver.full_name}
              style={{ width: '48px', height: '48px', borderRadius: '50%', objectFit: 'cover', border: '2px solid var(--brand-orange)' }}
            />
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <h4 style={{ fontSize: '0.9rem', fontWeight: 800, color: '#ffffff' }}>{order.driver.full_name}</h4>
                <div style={{ display: 'flex', alignItems: 'center', gap: '2px', background: 'rgba(255,183,3,0.15)', padding: '2px 6px', borderRadius: '4px' }}>
                  <Star size={12} color="#ffb703" fill="#ffb703" />
                  <span style={{ fontSize: '0.7rem', fontWeight: 700, color: '#ffb703' }}>{order.driver.rating_avg}</span>
                </div>
              </div>
              <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
                {order.driver.vehicle_type} • <strong style={{ color: '#ffffff' }}>{order.driver.vehicle_number}</strong>
              </p>
            </div>
          </div>

          <a
            href={`tel:${order.driver.phone}`}
            style={{
              width: '40px',
              height: '40px',
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
            <Phone size={18} />
          </a>
        </div>
      )}

      {/* Order Item Overview */}
      <div className="glass-panel" style={{ padding: '12px 14px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <p style={{ fontSize: '0.8rem', fontWeight: 700, color: '#ffffff' }}>
              {order.items[0]?.quantity}x {order.items[0]?.product.name}
            </p>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
              Service: <span style={{ textTransform: 'capitalize', color: 'var(--brand-orange)' }}>{order.order_type}</span>
            </p>
          </div>
          <p style={{ fontSize: '0.95rem', fontWeight: 800, color: '#ffffff' }}>
            {currencySymbol}{order.total_amount.toFixed(2)}
          </p>
        </div>
      </div>

      {/* Vertical Status Timeline */}
      <div className="glass-panel" style={{ padding: '16px' }}>
        <h4 style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff', marginBottom: '16px' }}>
          Live Status Timeline
        </h4>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', position: 'relative' }}>
          {steps.map((step, idx) => {
            const isDone = idx <= currentStepIdx;
            const isCurrent = idx === currentStepIdx;
            const logMatch = order.status_history.find((l) => l.status === step.status);

            return (
              <div key={step.status} style={{ display: 'flex', gap: '14px', position: 'relative' }}>
                {/* Timeline connector vertical line */}
                {idx < steps.length - 1 && (
                  <div
                    style={{
                      position: 'absolute',
                      left: '13px',
                      top: '26px',
                      bottom: '-16px',
                      width: '2px',
                      background: isDone && idx < currentStepIdx ? 'var(--brand-orange)' : 'var(--border-color)',
                      zIndex: 1,
                    }}
                  />
                )}

                {/* Dot */}
                <div
                  style={{
                    width: '28px',
                    height: '28px',
                    borderRadius: '50%',
                    background: isDone ? 'var(--brand-orange)' : 'rgba(255,255,255,0.08)',
                    color: isDone ? '#ffffff' : 'var(--text-muted)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    zIndex: 2,
                    border: isCurrent ? '3px solid #ffffff' : 'none',
                    boxShadow: isCurrent ? '0 0 12px rgba(255,107,0,0.6)' : 'none',
                  }}
                >
                  {step.icon}
                </div>

                {/* Text Details */}
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <h5 style={{ fontSize: '0.85rem', fontWeight: 700, color: isDone ? '#ffffff' : 'var(--text-muted)' }}>
                      {step.label}
                    </h5>
                    {logMatch && (
                      <span style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>
                        {new Date(logMatch.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </span>
                    )}
                  </div>
                  <p style={{ fontSize: '0.7rem', color: isDone ? 'var(--text-secondary)' : 'var(--text-muted)', marginTop: '2px' }}>
                    {logMatch?.note || step.desc}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
