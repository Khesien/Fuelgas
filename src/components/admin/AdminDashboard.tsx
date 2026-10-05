import React, { useState } from 'react';
import { useAppStore } from '../../store/useStore';
import { OverviewView } from './OverviewView';
import { OrdersManagement } from './OrdersManagement';
import { DriverManagement } from './DriverManagement';
import { InventoryManagement } from './InventoryManagement';
import { PromotionsManagement } from './PromotionsManagement';
import { SettingsView } from './SettingsView';
import { 
  BarChart3, ShoppingBag, Truck, Warehouse, Tag, Settings, 
  Flame, Building2 
} from 'lucide-react';

type AdminTab = 'overview' | 'orders' | 'drivers' | 'inventory' | 'promotions' | 'settings';

export const AdminDashboard: React.FC = () => {
  const store = useAppStore();
  const [activeTab, setActiveTab] = useState<AdminTab>('overview');

  const currentProvider = store.providers.find((p) => p.provider_id === store.selectedProviderId) || store.providers[0];

  return (
    <div style={{ display: 'flex', minHeight: 'calc(100vh - 60px)', background: '#0b0f19' }}>
      {/* Left Sidebar Navigation */}
      <aside
        style={{
          width: '240px',
          background: '#090d18',
          borderRight: '1px solid var(--border-color)',
          padding: '20px 14px',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
        }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '0 8px' }}>
            <Building2 size={24} color="var(--brand-orange)" />
            <div>
              <span style={{ fontSize: '0.95rem', fontWeight: 900, color: '#ffffff', letterSpacing: '0.5px', lineHeight: 1.1, display: 'block' }}>
                {currentProvider.company_name.split(' ')[0]} HUB
              </span>
              <span style={{ fontSize: '0.65rem', color: 'var(--brand-orange)', fontWeight: 700 }}>PROVIDER ADMIN</span>
            </div>
          </div>

          <nav style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {[
              { key: 'overview', label: 'Company Overview', icon: <BarChart3 size={18} /> },
              { key: 'orders', label: 'Company Orders', icon: <ShoppingBag size={18} /> },
              { key: 'drivers', label: 'Company Drivers', icon: <Truck size={18} /> },
              { key: 'inventory', label: 'Stock & Prices', icon: <Warehouse size={18} /> },
              { key: 'promotions', label: 'Promotions', icon: <Tag size={18} /> },
              { key: 'settings', label: 'Company Settings', icon: <Settings size={18} /> },
            ].map((nav) => {
              const isActive = activeTab === nav.key;
              return (
                <button
                  key={nav.key}
                  onClick={() => setActiveTab(nav.key as AdminTab)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '10px 14px',
                    borderRadius: 'var(--radius-sm)',
                    fontSize: '0.85rem',
                    fontWeight: 700,
                    background: isActive ? 'var(--brand-orange)' : 'transparent',
                    color: isActive ? '#ffffff' : 'var(--text-secondary)',
                    transition: 'all var(--transition-fast)',
                    textAlign: 'left',
                  }}
                >
                  {nav.icon}
                  {nav.label}
                </button>
              );
            })}
          </nav>
        </div>

        <div className="glass-panel" style={{ padding: '12px', textAlign: 'center' }}>
          <span style={{ fontSize: '0.7rem', color: 'var(--brand-orange)', fontWeight: 800 }}>SAFETY LICENSE STATUS</span>
          <p style={{ fontSize: '0.75rem', fontWeight: 800, color: '#4ade80', marginTop: '2px' }}>✓ Compliance Approved</p>
        </div>
      </aside>

      {/* Main Admin Viewport Panel */}
      <main style={{ flex: 1, padding: '28px', overflowY: 'auto' }}>
        {activeTab === 'overview' && (
          <OverviewView
            orders={store.orders.filter((o) => !o.provider_id || o.provider_id === currentProvider.provider_id)}
            drivers={store.drivers.filter((d) => d.provider_id === currentProvider.provider_id || true)}
            products={store.products}
            depots={store.depots.filter((d) => d.provider_id === currentProvider.provider_id)}
            currencySymbol={store.currencySymbol}
            onSelectOrder={() => setActiveTab('orders')}
            onNavigateToTab={(t) => setActiveTab(t as AdminTab)}
          />
        )}

        {activeTab === 'orders' && (
          <OrdersManagement
            orders={store.orders}
            drivers={store.drivers}
            currencySymbol={store.currencySymbol}
            onReassignDriver={store.reassignDriver}
            onUpdateStatus={store.updateOrderStatus}
            onCancelOrder={store.cancelOrder}
          />
        )}

        {activeTab === 'drivers' && (
          <DriverManagement
            drivers={store.drivers}
            onVerifyDriver={store.verifyDriver}
            onToggleStatus={store.toggleDriverOnline}
          />
        )}

        {activeTab === 'inventory' && (
          <InventoryManagement
            provider={currentProvider}
            depots={store.depots}
            products={store.products}
            currencySymbol={store.currencySymbol}
            onUpdateStock={store.updateDepotStock}
            onUpdatePrices={store.updateProviderPrices}
          />
        )}

        {activeTab === 'promotions' && (
          <PromotionsManagement
            promotions={store.promotions}
            currencySymbol={store.currencySymbol}
            onAddPromotion={store.addPromotion}
          />
        )}

        {activeTab === 'settings' && (
          <SettingsView
            currencySymbol={store.currencySymbol}
            setCurrencySymbol={store.setCurrencySymbol}
            deliveryFee={currentProvider.base_delivery_fee}
          />
        )}
      </main>
    </div>
  );
};
