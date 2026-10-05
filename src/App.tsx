import React from 'react';
import { Header } from './components/common/Header';
import { CustomerApp } from './components/customer/CustomerApp';
import { DriverApp } from './components/driver/DriverApp';
import { AdminDashboard } from './components/admin/AdminDashboard';
import { SuperAdminDashboard } from './components/superadmin/SuperAdminDashboard';
import { useAppStore } from './store/useStore';
import './styles/theme.css';

export function App() {
  const store = useAppStore();

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', background: '#0b0f19' }}>
      {/* Shared Global Navigation Header & Role Switcher */}
      <Header
        activeRole={store.activeRole}
        setActiveRole={store.setActiveRole}
        mobileViewMode={store.mobileViewMode}
        setMobileViewMode={store.setMobileViewMode}
        onSimulateOrder={store.simulateNewCustomerOrder}
        onAdvanceDriver={store.simulateDriverProgress}
        currencySymbol={store.currencySymbol}
        setCurrencySymbol={store.setCurrencySymbol}
      />

      {/* Render Active View Role */}
      {store.activeRole === 'customer' && <CustomerApp />}
      {store.activeRole === 'driver' && <DriverApp />}
      {store.activeRole === 'provider_admin' && <AdminDashboard />}
      {store.activeRole === 'super_admin' && <SuperAdminDashboard />}
    </div>
  );
}

export default App;
