import React, { useState } from 'react';
import { useAppStore } from '../../store/useStore';
import { MobileFrame } from '../common/MobileFrame';
import { HomeScreen } from './HomeScreen';
import { CylinderSelection } from './CylinderSelection';
import { CheckoutModal } from './CheckoutModal';
import { OrderTrackingScreen } from './OrderTrackingScreen';
import { CustomerProfile } from './CustomerProfile';
import { CylinderProduct, OrderType, Order } from '../../types';
import { Home, Flame, MapPin, User } from 'lucide-react';

type CustomerScreenView = 'home' | 'select_cylinder' | 'checkout' | 'track_order' | 'profile';

export const CustomerApp: React.FC = () => {
  const store = useAppStore();
  const [currentScreen, setCurrentScreen] = useState<CustomerScreenView>('home');
  const [cartItems, setCartItems] = useState<{ product: CylinderProduct; quantity: number; order_type: OrderType }[]>([]);
  const [selectedProductForDetails, setSelectedProductForDetails] = useState<CylinderProduct | undefined>(undefined);

  const currentProvider = store.providers.find((p) => p.provider_id === store.selectedProviderId) || store.providers[0];

  const handleSelectProduct = (product: CylinderProduct) => {
    setSelectedProductForDetails(product);
    setCurrentScreen('select_cylinder');
  };

  const handleProceedToCheckout = (items: { product: CylinderProduct; quantity: number; order_type: OrderType }[]) => {
    setCartItems(items);
    setCurrentScreen('checkout');
  };

  const handleConfirmOrder = (params: {
    provider_id: string;
    payment_method: any;
    payment_provider?: string;
    promo_code?: string;
    discount_amount: number;
    address_id: string;
  }) => {
    store.placeOrder({
      provider_id: params.provider_id,
      items: cartItems,
      order_type: cartItems[0]?.order_type || 'exchange',
      payment_method: params.payment_method,
      payment_provider: params.payment_provider,
      promo_code: params.promo_code,
      discount_amount: params.discount_amount,
      address_id: params.address_id,
    });
    setCurrentScreen('track_order');
  };

  const handleReorder = (order: Order) => {
    if (order.items[0]) {
      handleProceedToCheckout([
        {
          product: order.items[0].product,
          quantity: order.items[0].quantity,
          order_type: order.order_type,
        }
      ]);
    }
  };

  const unreadNotifs = store.notifications.filter((n) => !n.is_read).length;

  return (
    <MobileFrame
      mode={store.mobileViewMode}
      bottomNav={
        <div className="mobile-bottom-nav">
          <button
            className={`nav-item-btn ${currentScreen === 'home' ? 'active' : ''}`}
            onClick={() => setCurrentScreen('home')}
          >
            <Home size={20} />
            Home
          </button>
          <button
            className={`nav-item-btn ${currentScreen === 'select_cylinder' ? 'active' : ''}`}
            onClick={() => {
              setSelectedProductForDetails(undefined);
              setCurrentScreen('select_cylinder');
            }}
          >
            <Flame size={20} />
            Order Gas
          </button>
          <button
            className={`nav-item-btn ${currentScreen === 'track_order' ? 'active' : ''}`}
            onClick={() => setCurrentScreen('track_order')}
          >
            <MapPin size={20} />
            Track Order
          </button>
          <button
            className={`nav-item-btn ${currentScreen === 'profile' ? 'active' : ''}`}
            onClick={() => setCurrentScreen('profile')}
          >
            <User size={20} />
            Profile
          </button>
        </div>
      }
    >
      {currentScreen === 'home' && (
        <HomeScreen
          user={store.currentUser}
          addresses={store.addresses}
          selectedAddressId={store.selectedAddressId}
          onChangeAddress={() => setCurrentScreen('profile')}
          districts={store.districts}
          activeDistrict={store.activeDistrict}
          onSelectDistrict={store.setActiveDistrict}
          providers={store.providers}
          selectedProviderId={store.selectedProviderId}
          onSelectProvider={store.setSelectedProviderId}
          products={store.products}
          activeOrder={store.activeOrderForTracking}
          currencySymbol={store.currencySymbol}
          onSelectProduct={handleSelectProduct}
          onViewAllProducts={() => setCurrentScreen('select_cylinder')}
          onTrackOrder={() => setCurrentScreen('track_order')}
          onViewOffers={() => setCurrentScreen('profile')}
          unreadNotifsCount={unreadNotifs}
        />
      )}

      {currentScreen === 'select_cylinder' && (
        <CylinderSelection
          products={store.products}
          selectedProductInitial={selectedProductForDetails}
          providers={store.providers}
          selectedProviderId={store.selectedProviderId}
          onSelectProvider={store.setSelectedProviderId}
          activeDistrict={store.activeDistrict}
          currencySymbol={store.currencySymbol}
          onBack={() => setCurrentScreen('home')}
          onProceedToCheckout={handleProceedToCheckout}
        />
      )}

      {currentScreen === 'checkout' && (
        <CheckoutModal
          cartItems={cartItems}
          provider={currentProvider}
          addresses={store.addresses}
          selectedAddressId={store.selectedAddressId}
          onSelectAddress={store.setSelectedAddressId}
          promotions={store.promotions}
          deliveryFee={currentProvider.base_delivery_fee}
          currencySymbol={store.currencySymbol}
          onBack={() => setCurrentScreen('select_cylinder')}
          onConfirmOrder={handleConfirmOrder}
        />
      )}

      {currentScreen === 'track_order' && store.activeOrderForTracking && (
        <OrderTrackingScreen
          order={store.activeOrderForTracking}
          currencySymbol={store.currencySymbol}
          onBack={() => setCurrentScreen('home')}
        />
      )}

      {currentScreen === 'profile' && (
        <CustomerProfile
          user={store.currentUser}
          addresses={store.addresses}
          onAddAddress={store.addAddress}
          orders={store.orders}
          currencySymbol={store.currencySymbol}
          onReorder={handleReorder}
          onTrackOrder={() => {
            setCurrentScreen('track_order');
          }}
        />
      )}
    </MobileFrame>
  );
};
