import React, { useState } from 'react';
import { Order, Driver, OrderStatus } from '../../types';
import { Search, Filter, RefreshCw, X, ShieldAlert, CheckCircle2 } from 'lucide-react';

interface OrdersManagementProps {
  orders: Order[];
  drivers: Driver[];
  currencySymbol: string;
  onReassignDriver: (orderId: string, driverId: string) => void;
  onUpdateStatus: (orderId: string, status: OrderStatus) => void;
  onCancelOrder: (orderId: string, reason: string) => void;
}

export const OrdersManagement: React.FC<OrdersManagementProps> = ({
  orders,
  drivers,
  currencySymbol,
  onReassignDriver,
  onUpdateStatus,
  onCancelOrder,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);

  const filteredOrders = orders.filter((o) => {
    const matchesSearch =
      o.human_id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      o.user.full_name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || o.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>Orders Management</h2>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Monitor, reassign, or issue refunds for all LPG orders</p>
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: '10px' }}>
          <div style={{ position: 'relative' }}>
            <Search size={16} color="var(--text-muted)" style={{ position: 'absolute', left: '10px', top: '10px' }} />
            <input
              type="text"
              placeholder="Search Order ID or Customer..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                padding: '8px 12px 8px 34px',
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid var(--border-color)',
                borderRadius: '8px',
                color: '#ffffff',
                fontSize: '0.85rem',
              }}
            />
          </div>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            style={{
              background: 'rgba(255,255,255,0.05)',
              border: '1px solid var(--border-color)',
              color: '#ffffff',
              padding: '8px 12px',
              borderRadius: '8px',
              fontSize: '0.85rem',
            }}
          >
            <option value="all">All Statuses</option>
            <option value="confirmed">Confirmed</option>
            <option value="preparing">Preparing</option>
            <option value="out_for_delivery">Out for Delivery</option>
            <option value="delivered">Delivered</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
      </div>

      {/* Orders Table */}
      <div className="glass-panel" style={{ padding: '20px' }}>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                <th style={{ padding: '10px' }}>Order ID</th>
                <th style={{ padding: '10px' }}>Customer & Address</th>
                <th style={{ padding: '10px' }}>Cylinder Item</th>
                <th style={{ padding: '10px' }}>Assigned Driver</th>
                <th style={{ padding: '10px' }}>Payment</th>
                <th style={{ padding: '10px' }}>Status</th>
                <th style={{ padding: '10px' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredOrders.map((ord) => (
                <tr key={ord.order_id} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                  <td style={{ padding: '12px 10px', fontWeight: 800, color: '#ffffff' }}>{ord.human_id}</td>
                  <td style={{ padding: '12px 10px' }}>
                    <p style={{ fontWeight: 700, color: '#ffffff' }}>{ord.user.full_name}</p>
                    <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{ord.address.street}</p>
                  </td>
                  <td style={{ padding: '12px 10px', color: 'var(--text-secondary)' }}>
                    {ord.items[0]?.quantity}x {ord.items[0]?.product.name} ({ord.order_type})
                  </td>
                  <td style={{ padding: '12px 10px' }}>
                    <select
                      value={ord.driver_id || ''}
                      onChange={(e) => onReassignDriver(ord.order_id, e.target.value)}
                      style={{
                        background: 'rgba(255,255,255,0.05)',
                        border: '1px solid var(--border-color)',
                        color: '#ffffff',
                        padding: '4px 8px',
                        borderRadius: '6px',
                        fontSize: '0.75rem',
                      }}
                    >
                      <option value="">-- Unassigned --</option>
                      {drivers.map((d) => (
                        <option key={d.driver_id} value={d.driver_id}>
                          {d.full_name} ({d.status})
                        </option>
                      ))}
                    </select>
                  </td>
                  <td style={{ padding: '12px 10px' }}>
                    <p style={{ fontWeight: 800, color: 'var(--brand-orange)' }}>
                      {currencySymbol}{ord.total_amount.toFixed(2)}
                    </p>
                    <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)' }}>{ord.payment_provider}</p>
                  </td>
                  <td style={{ padding: '12px 10px' }}>
                    <span className={`status-badge ${ord.status}`}>{ord.status.replace('_', ' ')}</span>
                  </td>
                  <td style={{ padding: '12px 10px' }}>
                    <button
                      onClick={() => setSelectedOrder(ord)}
                      className="glow-btn"
                      style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                    >
                      Details & Log
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Order Detail Modal */}
      {selectedOrder && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'rgba(0,0,0,0.8)',
            backdropFilter: 'blur(10px)',
            zIndex: 2000,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div className="glass-panel" style={{ width: '100%', maxWidth: '550px', padding: '24px', position: 'relative' }}>
            <button
              onClick={() => setSelectedOrder(null)}
              style={{ position: 'absolute', top: '16px', right: '16px', background: 'transparent', color: '#ffffff' }}
            >
              <X size={20} />
            </button>

            <h3 style={{ fontSize: '1.2rem', fontWeight: 900, color: '#ffffff' }}>
              Order Details ({selectedOrder.human_id})
            </h3>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
              Customer: {selectedOrder.user.full_name} • Phone: {selectedOrder.user.phone}
            </p>

            <div style={{ margin: '16px 0', borderTop: '1px solid var(--border-color)', paddingTop: '12px' }}>
              <h4 style={{ fontSize: '0.85rem', fontWeight: 700, color: '#ffffff' }}>Status Log & Operations Override</h4>
              <div style={{ display: 'flex', gap: '8px', margin: '10px 0' }}>
                {['confirmed', 'preparing', 'out_for_delivery', 'delivered'].map((st) => (
                  <button
                    key={st}
                    onClick={() => {
                      onUpdateStatus(selectedOrder.order_id, st as OrderStatus);
                      setSelectedOrder(null);
                    }}
                    style={{
                      flex: 1,
                      padding: '6px',
                      borderRadius: '6px',
                      fontSize: '0.7rem',
                      fontWeight: 700,
                      background: selectedOrder.status === st ? 'var(--brand-orange)' : 'rgba(255,255,255,0.08)',
                      color: '#ffffff',
                    }}
                  >
                    Set {st.replace('_', ' ')}
                  </button>
                ))}
              </div>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '20px' }}>
              <button
                onClick={() => {
                  onCancelOrder(selectedOrder.order_id, 'Cancelled by Admin Ops');
                  setSelectedOrder(null);
                }}
                style={{
                  background: 'rgba(239, 68, 68, 0.2)',
                  color: '#f87171',
                  border: '1px solid rgba(239, 68, 68, 0.4)',
                  padding: '8px 14px',
                  borderRadius: '6px',
                  fontSize: '0.8rem',
                  fontWeight: 700,
                }}
              >
                Cancel Order & Refund
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
