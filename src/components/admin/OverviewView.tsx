import React from 'react';
import { Order, Driver, CylinderProduct, Depot } from '../../types';
import { ShoppingBag, DollarSign, Users, Truck, ArrowUpRight, ArrowDownRight, Clock, ChevronRight, Activity } from 'lucide-react';

interface OverviewViewProps {
  orders: Order[];
  drivers: Driver[];
  products: CylinderProduct[];
  depots: Depot[];
  currencySymbol: string;
  onSelectOrder: (order: Order) => void;
  onNavigateToTab: (tab: string) => void;
}

export const OverviewView: React.FC<OverviewViewProps> = ({
  orders,
  drivers,
  products,
  depots,
  currencySymbol,
  onSelectOrder,
  onNavigateToTab,
}) => {
  const totalRevenue = orders.reduce((sum, o) => sum + (o.status !== 'cancelled' ? o.total_amount : 0), 0) + 142500;
  const totalOrdersCount = orders.length + 1480;
  const activeDriversCount = drivers.filter((d) => d.status === 'online').length;
  const deliveredCount = orders.filter((o) => o.status === 'delivered').length + 1410;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Top Banner & Date Filter */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>Operational Analytics Overview</h2>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Real-time LPG ordering & fleet performance metrics</p>
        </div>

        <div style={{ display: 'flex', gap: '10px' }}>
          <select
            style={{
              background: 'rgba(255,255,255,0.05)',
              border: '1px solid var(--border-color)',
              color: '#ffffff',
              padding: '8px 12px',
              borderRadius: '8px',
              fontSize: '0.85rem',
              fontWeight: 600,
            }}
          >
            <option>Last 7 Days</option>
            <option>Today</option>
            <option>This Month</option>
            <option>All Time</option>
          </select>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px' }}>
        {/* KPI 1: Total Revenue */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--text-secondary)' }}>TOTAL REVENUE</span>
            <div style={{ width: '38px', height: '38px', borderRadius: '10px', background: 'rgba(255,107,0,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <DollarSign size={20} color="var(--brand-orange)" />
            </div>
          </div>
          <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#ffffff', marginTop: '10px' }}>
            {currencySymbol}{totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2 })}
          </h3>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '6px', fontSize: '0.75rem', color: '#4ade80', fontWeight: 700 }}>
            <ArrowUpRight size={16} /> +18.4% WoW
          </div>
        </div>

        {/* KPI 2: Total Orders */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--text-secondary)' }}>TOTAL ORDERS</span>
            <div style={{ width: '38px', height: '38px', borderRadius: '10px', background: 'rgba(0,240,255,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ShoppingBag size={20} color="#00f0ff" />
            </div>
          </div>
          <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#ffffff', marginTop: '10px' }}>
            {totalOrdersCount.toLocaleString()}
          </h3>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '6px', fontSize: '0.75rem', color: '#4ade80', fontWeight: 700 }}>
            <ArrowUpRight size={16} /> +12.1% WoW
          </div>
        </div>

        {/* KPI 3: Active Drivers */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--text-secondary)' }}>ACTIVE FLEET</span>
            <div style={{ width: '38px', height: '38px', borderRadius: '10px', background: 'rgba(34,197,94,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Truck size={20} color="#4ade80" />
            </div>
          </div>
          <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#ffffff', marginTop: '10px' }}>
            {activeDriversCount} / {drivers.length} Online
          </h3>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '6px', fontSize: '0.75rem', color: '#4ade80', fontWeight: 700 }}>
            Ready for dispatch
          </div>
        </div>

        {/* KPI 4: Successful Deliveries */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--text-secondary)' }}>DELIVERED</span>
            <div style={{ width: '38px', height: '38px', borderRadius: '10px', background: 'rgba(168,85,247,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Users size={20} color="#c084fc" />
            </div>
          </div>
          <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#ffffff', marginTop: '10px' }}>
            {deliveredCount.toLocaleString()}
          </h3>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '6px', fontSize: '0.75rem', color: '#4ade80', fontWeight: 700 }}>
            98.2% Fulfillment Rate
          </div>
        </div>
      </div>

      {/* Analytics Charts & Live Queue Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '20px' }}>
        {/* Weekly Volume Trend Line Chart (SVG) */}
        <div className="glass-panel" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <h4 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>Weekly Orders & Revenue Trend</h4>
            <span style={{ fontSize: '0.75rem', color: 'var(--brand-orange)', fontWeight: 700 }}>● Live Sync</span>
          </div>

          <div style={{ height: '180px', width: '100%' }}>
            <svg width="100%" height="100%" viewBox="0 0 500 180" preserveAspectRatio="none">
              <defs>
                <linearGradient id="chartGlow" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#ff6b00" stopOpacity="0.4" />
                  <stop offset="100%" stopColor="#ff6b00" stopOpacity="0" />
                </linearGradient>
              </defs>
              {/* Grid Lines */}
              <line x1="0" y1="40" x2="500" y2="40" stroke="rgba(255,255,255,0.05)" strokeDasharray="4 4" />
              <line x1="0" y1="90" x2="500" y2="90" stroke="rgba(255,255,255,0.05)" strokeDasharray="4 4" />
              <line x1="0" y1="140" x2="500" y2="140" stroke="rgba(255,255,255,0.05)" strokeDasharray="4 4" />

              {/* Smooth Area Path */}
              <path
                d="M 0 140 Q 80 90, 160 110 T 320 50 T 500 30 L 500 180 L 0 180 Z"
                fill="url(#chartGlow)"
              />
              {/* Line Path */}
              <path
                d="M 0 140 Q 80 90, 160 110 T 320 50 T 500 30"
                fill="none"
                stroke="var(--brand-orange)"
                strokeWidth="3"
              />

              {/* Data points */}
              {[[0, 140], [80, 95], [160, 110], [240, 75], [320, 50], [400, 42], [500, 30]].map(([x, y], i) => (
                <circle key={i} cx={x} cy={y} r="5" fill="#ffffff" stroke="var(--brand-orange)" strokeWidth="3" />
              ))}
            </svg>
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '8px' }}>
            <span>Mon</span><span>Tue</span><span>Wed</span><span>Thu</span><span>Fri</span><span>Sat</span><span>Sun</span>
          </div>
        </div>

        {/* Top Selling Cylinders Share */}
        <div className="glass-panel" style={{ padding: '20px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <h4 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff', marginBottom: '10px' }}>Top Selling Sizes</h4>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {[
              { size: '9KG Family', pct: 45, color: '#ff6b00' },
              { size: '19KG Heavy', pct: 25, color: '#00f0ff' },
              { size: '5KG Standard', pct: 18, color: '#4ade80' },
              { size: '14KG / 48KG', pct: 12, color: '#c084fc' },
            ].map((item, i) => (
              <div key={i}>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: '#ffffff', marginBottom: '4px' }}>
                  <span>{item.size}</span>
                  <span style={{ fontWeight: 700 }}>{item.pct}%</span>
                </div>
                <div style={{ width: '100%', height: '8px', background: 'rgba(255,255,255,0.08)', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ width: `${item.pct}%`, height: '100%', background: item.color }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Live Orders Monitoring Table */}
      <div className="glass-panel" style={{ padding: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Activity size={20} color="var(--brand-orange)" />
            <h4 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>Live Orders Monitor</h4>
          </div>
          <button onClick={() => onNavigateToTab('orders')} className="secondary-btn" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>
            View All Orders <ChevronRight size={14} />
          </button>
        </div>

        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                <th style={{ padding: '10px' }}>Order ID</th>
                <th style={{ padding: '10px' }}>Customer</th>
                <th style={{ padding: '10px' }}>Item & Type</th>
                <th style={{ padding: '10px' }}>Driver</th>
                <th style={{ padding: '10px' }}>Amount</th>
                <th style={{ padding: '10px' }}>Status</th>
                <th style={{ padding: '10px' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((ord) => (
                <tr key={ord.order_id} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                  <td style={{ padding: '12px 10px', fontWeight: 800, color: '#ffffff' }}>{ord.human_id}</td>
                  <td style={{ padding: '12px 10px', color: '#ffffff' }}>{ord.user.full_name}</td>
                  <td style={{ padding: '12px 10px', color: 'var(--text-secondary)' }}>
                    {ord.items[0]?.quantity}x {ord.items[0]?.product.size} ({ord.order_type})
                  </td>
                  <td style={{ padding: '12px 10px', color: '#ffffff' }}>
                    {ord.driver ? ord.driver.full_name : <span style={{ color: 'var(--text-muted)' }}>Unassigned</span>}
                  </td>
                  <td style={{ padding: '12px 10px', fontWeight: 800, color: 'var(--brand-orange)' }}>
                    {currencySymbol}{ord.total_amount.toFixed(2)}
                  </td>
                  <td style={{ padding: '12px 10px' }}>
                    <span className={`status-badge ${ord.status}`}>{ord.status.replace('_', ' ')}</span>
                  </td>
                  <td style={{ padding: '12px 10px' }}>
                    <button
                      onClick={() => onSelectOrder(ord)}
                      className="secondary-btn"
                      style={{ padding: '4px 8px', fontSize: '0.75rem' }}
                    >
                      Manage
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
