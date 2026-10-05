import React from 'react';
import { Driver, Order } from '../../types';
import { DollarSign, Award, CheckCircle2, TrendingUp, Calendar, Clock } from 'lucide-react';

interface DriverEarningsScreenProps {
  driver: Driver;
  orders: Order[];
  currencySymbol: string;
}

export const DriverEarningsScreen: React.FC<DriverEarningsScreenProps> = ({ driver, orders, currencySymbol }) => {
  const completedOrders = orders.filter((o) => o.driver_id === driver.driver_id && o.status === 'delivered');
  const todayEarnings = completedOrders.reduce((sum, o) => sum + (o.delivery_fee + 10), 0) + 145.00;
  const weeklyEarnings = todayEarnings + 840.00;

  return (
    <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Banner */}
      <div>
        <span style={{ fontSize: '0.7rem', color: 'var(--brand-orange)', fontWeight: 800 }}>EARNINGS & PAYOUTS</span>
        <h2 style={{ fontSize: '1.2rem', fontWeight: 900, color: '#ffffff' }}>Driver Financial Overview</h2>
      </div>

      {/* Main Earnings Card */}
      <div
        style={{
          background: 'linear-gradient(135deg, #ff6b00 0%, #1e293b 100%)',
          borderRadius: 'var(--radius-lg)',
          padding: '20px',
          boxShadow: '0 10px 25px rgba(255,107,0,0.3)',
        }}
      >
        <p style={{ fontSize: '0.75rem', opacity: 0.9, fontWeight: 600 }}>TODAY'S TOTAL EARNINGS</p>
        <h1 style={{ fontSize: '2rem', fontWeight: 900, color: '#ffffff', marginTop: '4px' }}>
          {currencySymbol}{todayEarnings.toFixed(2)}
        </h1>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', marginTop: '16px', paddingTop: '14px', borderTop: '1px solid rgba(255,255,255,0.2)' }}>
          <div>
            <p style={{ fontSize: '0.65rem', opacity: 0.8 }}>THIS WEEK</p>
            <p style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>
              {currencySymbol}{weeklyEarnings.toFixed(2)}
            </p>
          </div>
          <div>
            <p style={{ fontSize: '0.65rem', opacity: 0.8 }}>COMPLETED TRIPS</p>
            <p style={{ fontSize: '1.1rem', fontWeight: 800, color: '#ffffff' }}>
              {driver.completed_orders + completedOrders.length}
            </p>
          </div>
        </div>
      </div>

      {/* Driver Rating & Metrics */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
        <div className="glass-panel" style={{ padding: '12px', textAlign: 'center' }}>
          <span style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>Acceptance Rate</span>
          <p style={{ fontSize: '1.2rem', fontWeight: 900, color: '#4ade80', marginTop: '2px' }}>98.5%</p>
        </div>
        <div className="glass-panel" style={{ padding: '12px', textAlign: 'center' }}>
          <span style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>Avg Rating</span>
          <p style={{ fontSize: '1.2rem', fontWeight: 900, color: '#ffb703', marginTop: '2px' }}>
            ★ {driver.rating_avg}
          </p>
        </div>
      </div>

      {/* Payout History List */}
      <div>
        <h3 style={{ fontSize: '0.9rem', fontWeight: 800, color: '#ffffff', marginBottom: '10px' }}>Completed Trip Payouts</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {completedOrders.length > 0 ? (
            completedOrders.map((ord) => (
              <div key={ord.order_id} className="glass-panel" style={{ padding: '12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>Trip {ord.human_id}</p>
                  <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>
                    {ord.address.street} ({ord.items[0]?.product.size})
                  </p>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <p style={{ fontSize: '0.9rem', fontWeight: 800, color: '#4ade80' }}>
                    +{currencySymbol}{(ord.delivery_fee + 10).toFixed(2)}
                  </p>
                  <span style={{ fontSize: '0.65rem', color: 'var(--text-muted)' }}>Paid to Wallet</span>
                </div>
              </div>
            ))
          ) : (
            <div className="glass-panel" style={{ padding: '16px', textAlign: 'center', color: 'var(--text-muted)' }}>
              <Clock size={24} style={{ margin: '0 auto 6px' }} />
              <p style={{ fontSize: '0.75rem' }}>No trips completed yet today.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
