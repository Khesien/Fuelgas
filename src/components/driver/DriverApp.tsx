import React, { useState } from 'react';
import { useAppStore } from '../../store/useStore';
import { MobileFrame } from '../common/MobileFrame';
import { NewJobRequestModal } from './NewJobRequestModal';
import { OrderFulfilmentScreen } from './OrderFulfilmentScreen';
import { DriverEarningsScreen } from './DriverEarningsScreen';
import { DriverProfile } from './DriverProfile';
import { Navigation, DollarSign, User, Truck, Power } from 'lucide-react';

export const DriverApp: React.FC = () => {
  const store = useAppStore();
  const [driverTab, setDriverTab] = useState<'jobs' | 'earnings' | 'profile'>('jobs');
  const [declinedJobIds, setDeclinedJobIds] = useState<string[]>([]);

  const activeDriver = store.drivers.find((d) => d.driver_id === store.activeDriverId) || store.drivers[0];

  // Find incoming job (unassigned confirmed order) or active order for this driver
  const pendingUnassignedOrder = store.orders.find(
    (o) => (o.status === 'confirmed' || o.status === 'preparing') && !o.driver_id && !declinedJobIds.includes(o.order_id)
  );

  const activeDriverOrder = store.orders.find(
    (o) => o.driver_id === activeDriver.driver_id && o.status === 'out_for_delivery'
  );

  return (
    <MobileFrame
      mode={store.mobileViewMode}
      bottomNav={
        <div className="mobile-bottom-nav">
          <button
            className={`nav-item-btn ${driverTab === 'jobs' ? 'active' : ''}`}
            onClick={() => setDriverTab('jobs')}
          >
            <Navigation size={20} />
            Jobs
          </button>
          <button
            className={`nav-item-btn ${driverTab === 'earnings' ? 'active' : ''}`}
            onClick={() => setDriverTab('earnings')}
          >
            <DollarSign size={20} />
            Earnings
          </button>
          <button
            className={`nav-item-btn ${driverTab === 'profile' ? 'active' : ''}`}
            onClick={() => setDriverTab('profile')}
          >
            <User size={20} />
            Profile
          </button>
        </div>
      }
    >
      {/* Driver Top Header Status Bar */}
      <div
        style={{
          background: 'rgba(15,23,42,0.9)',
          padding: '10px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          borderBottom: '1px solid var(--border-color)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <img
            src={activeDriver.photo_url}
            alt={activeDriver.full_name}
            style={{ width: '32px', height: '32px', borderRadius: '50%', objectFit: 'cover' }}
          />
          <div>
            <span style={{ fontSize: '0.8rem', fontWeight: 800, color: '#ffffff' }}>{activeDriver.full_name}</span>
            <p style={{ fontSize: '0.65rem', color: 'var(--text-secondary)' }}>{activeDriver.vehicle_type}</p>
          </div>
        </div>

        <button
          onClick={() => store.toggleDriverOnline(activeDriver.driver_id)}
          style={{
            background: activeDriver.status === 'online' ? 'rgba(34,197,94,0.2)' : 'rgba(255,255,255,0.08)',
            border: `1px solid ${activeDriver.status === 'online' ? 'rgba(34,197,94,0.4)' : 'var(--border-color)'}`,
            color: activeDriver.status === 'online' ? '#4ade80' : 'var(--text-muted)',
            fontWeight: 800,
            fontSize: '0.7rem',
            padding: '4px 10px',
            borderRadius: '12px',
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
          }}
        >
          <Power size={12} />
          {activeDriver.status === 'online' ? 'ONLINE' : 'OFFLINE'}
        </button>
      </div>

      {/* Main Tab Views */}
      {driverTab === 'jobs' && (
        <>
          {activeDriverOrder ? (
            <OrderFulfilmentScreen
              order={activeDriverOrder}
              currencySymbol={store.currencySymbol}
              onCompleteDelivery={(otp) => {
                store.updateOrderStatus(activeDriverOrder.order_id, 'delivered', `OTP confirmed (${otp})`);
              }}
              onCancelDelivery={(reason) => {
                store.cancelOrder(activeDriverOrder.order_id, reason);
              }}
            />
          ) : (
            <div style={{ padding: '20px', textAlign: 'center', marginTop: '40px' }}>
              <div
                style={{
                  width: '70px',
                  height: '70px',
                  borderRadius: '50%',
                  background: 'rgba(255,107,0,0.15)',
                  color: 'var(--brand-orange)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 16px',
                }}
              >
                <Truck size={36} />
              </div>
              <h3 style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>Searching for Nearby Jobs...</h3>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '6px' }}>
                You are online and eligible for instant LPG delivery dispatches.
              </p>

              <button
                className="demo-action-btn"
                onClick={store.simulateNewCustomerOrder}
                style={{ marginTop: '20px', padding: '10px 16px' }}
              >
                ⚡ Trigger Test Customer Order
              </button>
            </div>
          )}
        </>
      )}

      {driverTab === 'earnings' && (
        <DriverEarningsScreen
          driver={activeDriver}
          orders={store.orders}
          currencySymbol={store.currencySymbol}
        />
      )}

      {driverTab === 'profile' && (
        <DriverProfile
          driver={activeDriver}
          onToggleOnline={() => store.toggleDriverOnline(activeDriver.driver_id)}
        />
      )}

      {/* Popup Job Request Alert Modal */}
      {pendingUnassignedOrder && activeDriver.status === 'online' && !activeDriverOrder && (
        <NewJobRequestModal
          order={pendingUnassignedOrder}
          currencySymbol={store.currencySymbol}
          onAccept={() => {
            store.acceptJob(pendingUnassignedOrder.order_id, activeDriver.driver_id);
            setDriverTab('jobs');
          }}
          onDecline={() => {
            setDeclinedJobIds((prev) => [...prev, pendingUnassignedOrder.order_id]);
          }}
        />
      )}
    </MobileFrame>
  );
};
