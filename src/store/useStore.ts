import { useState, useEffect, useCallback } from 'react';
import { 
  UserRole, Order, OrderStatus, Driver, CylinderProduct, Depot, Address, 
  Promotion, Notification, OrderType, PaymentMethod, User, GasProvider, District, ComplianceStatus 
} from '../types';
import { 
  MOCK_USER, MOCK_ADDRESSES, MOCK_PRODUCTS, MOCK_DEPOTS, 
  MOCK_DRIVERS, MOCK_PROMOTIONS, MOCK_INITIAL_ORDERS, MOCK_NOTIFICATIONS,
  MOCK_GAS_PROVIDERS, MOCK_DISTRICTS 
} from '../services/mockData';

export interface AppStore {
  // App Config
  activeRole: UserRole;
  setActiveRole: (role: UserRole) => void;
  mobileViewMode: 'frame' | 'fullscreen';
  setMobileViewMode: (mode: 'frame' | 'fullscreen') => void;
  currencySymbol: string;
  setCurrencySymbol: (symbol: string) => void;
  deliveryFeeStandard: number;

  // District & Location Filtering
  districts: District[];
  activeDistrict: District;
  setActiveDistrict: (district: District) => void;

  // Multi-Tenant Gas Providers
  providers: GasProvider[];
  selectedProviderId: string;
  setSelectedProviderId: (id: string) => void;
  registerGasProvider: (provider: Omit<GasProvider, 'provider_id' | 'rating' | 'review_count' | 'compliance_status' | 'safety_score'>) => void;
  updateProviderCompliance: (providerId: string, status: ComplianceStatus) => void;
  updateProviderPrices: (providerId: string, productId: string, refillPrice: number, exchangePrice: number) => void;

  // Active Customer State
  currentUser: User;
  addresses: Address[];
  selectedAddressId: string;
  setSelectedAddressId: (id: string) => void;
  addAddress: (address: Omit<Address, 'address_id' | 'user_id'>) => void;
  
  // Products & Depots
  products: CylinderProduct[];
  depots: Depot[];
  updateDepotStock: (depotId: string, productId: string, newQty: number) => void;

  // Drivers
  drivers: Driver[];
  activeDriverId: string;
  setActiveDriverId: (id: string) => void;
  toggleDriverOnline: (driverId: string) => void;
  verifyDriver: (driverId: string, approve: boolean) => void;

  // Orders Engine
  orders: Order[];
  activeOrderForTracking: Order | null;
  placeOrder: (params: {
    provider_id: string;
    items: { product: CylinderProduct; quantity: number; order_type: OrderType }[];
    order_type: OrderType;
    payment_method: PaymentMethod;
    payment_provider?: string;
    promo_code?: string;
    discount_amount: number;
    address_id: string;
  }) => Order;
  acceptJob: (orderId: string, driverId: string) => void;
  updateOrderStatus: (orderId: string, newStatus: OrderStatus, note?: string) => void;
  cancelOrder: (orderId: string, reason: string) => void;
  reassignDriver: (orderId: string, newDriverId: string) => void;
  
  // Promotions
  promotions: Promotion[];
  addPromotion: (promo: Omit<Promotion, 'promo_id' | 'redemption_count'>) => void;

  // Notifications
  notifications: Notification[];
  markNotificationRead: (id: string) => void;

  // Interactive Demo Generators
  simulateNewCustomerOrder: () => void;
  simulateDriverProgress: () => void;
}

export function useAppStore() {
  const [activeRole, setActiveRole] = useState<UserRole>('customer');
  const [mobileViewMode, setMobileViewMode] = useState<'frame' | 'fullscreen'>('frame');
  const [currencySymbol, setCurrencySymbol] = useState<string>('P');
  const [deliveryFeeStandard] = useState<number>(25.00);

  // District & Location
  const [districts] = useState<District[]>(MOCK_DISTRICTS);
  const [activeDistrict, setActiveDistrict] = useState<District>('Gaborone Central');

  // Gas Providers
  const [providers, setProviders] = useState<GasProvider[]>(MOCK_GAS_PROVIDERS);
  const [selectedProviderId, setSelectedProviderId] = useState<string>(MOCK_GAS_PROVIDERS[0].provider_id);

  // Customer & Addresses
  const [currentUser] = useState<User>(MOCK_USER);
  const [addresses, setAddresses] = useState<Address[]>(MOCK_ADDRESSES);
  const [selectedAddressId, setSelectedAddressId] = useState<string>(MOCK_ADDRESSES[0].address_id);

  const [products] = useState<CylinderProduct[]>(MOCK_PRODUCTS);
  const [depots, setDepots] = useState<Depot[]>(MOCK_DEPOTS);
  const [drivers, setDrivers] = useState<Driver[]>(MOCK_DRIVERS);

  const [orders, setOrders] = useState<Order[]>(MOCK_INITIAL_ORDERS);
  const [promotions, setPromotions] = useState<Promotion[]>(MOCK_PROMOTIONS);
  const [notifications, setNotifications] = useState<Notification[]>(MOCK_NOTIFICATIONS);

  // Super Admin: Register new gas provider company
  const registerGasProvider = useCallback((newProv: Omit<GasProvider, 'provider_id' | 'rating' | 'review_count' | 'compliance_status' | 'safety_score'>) => {
    const created: GasProvider = {
      ...newProv,
      provider_id: `prov-${Date.now()}`,
      rating: 5.0,
      review_count: 1,
      compliance_status: 'approved',
      safety_score: 96,
    };
    setProviders((prev) => [created, ...prev]);
  }, []);

  // Super Admin: Update compliance status (approve, under review, suspend/remove)
  const updateProviderCompliance = useCallback((providerId: string, status: ComplianceStatus) => {
    setProviders((prev) =>
      prev.map((p) => (p.provider_id === providerId ? { ...p, compliance_status: status } : p))
    );
  }, []);

  // Provider Admin: Update pricing
  const updateProviderPrices = useCallback((providerId: string, productId: string, refillPrice: number, exchangePrice: number) => {
    setProviders((prev) =>
      prev.map((p) => {
        if (p.provider_id === providerId) {
          return {
            ...p,
            prices: {
              ...p.prices,
              [productId]: { refill: refillPrice, exchange: exchangePrice },
            },
          };
        }
        return p;
      })
    );
  }, []);

  // Address creation
  const addAddress = useCallback((newAddr: Omit<Address, 'address_id' | 'user_id'>) => {
    const created: Address = {
      ...newAddr,
      address_id: `addr-${Date.now()}`,
      user_id: currentUser.user_id,
    };
    setAddresses((prev) => [created, ...prev]);
    setSelectedAddressId(created.address_id);
    setActiveDistrict(created.district || 'Gaborone Central');
  }, [currentUser.user_id]);

  // Inventory adjustment
  const updateDepotStock = useCallback((depotId: string, productId: string, newQty: number) => {
    setDepots((prev) =>
      prev.map((d) => {
        if (d.depot_id === depotId) {
          return {
            ...d,
            stock: { ...d.stock, [productId]: Math.max(0, newQty) },
          };
        }
        return d;
      })
    );
  }, []);

  // Driver toggle status
  const toggleDriverOnline = useCallback((driverId: string) => {
    setDrivers((prev) =>
      prev.map((drv) => {
        if (drv.driver_id === driverId) {
          const nextStatus = drv.status === 'online' ? 'offline' : 'online';
          return { ...drv, status: nextStatus };
        }
        return drv;
      })
    );
  }, []);

  // Driver verification (Admin action)
  const verifyDriver = useCallback((driverId: string, approve: boolean) => {
    setDrivers((prev) =>
      prev.map((drv) =>
        drv.driver_id === driverId
          ? { ...drv, verification_status: approve ? 'approved' : 'rejected', status: approve ? 'online' : 'suspended' }
          : drv
      )
    );
  }, []);

  // Place a new Order linked to selected Provider
  const placeOrder = useCallback((params: {
    provider_id: string;
    items: { product: CylinderProduct; quantity: number; order_type: OrderType }[];
    order_type: OrderType;
    payment_method: PaymentMethod;
    payment_provider?: string;
    promo_code?: string;
    discount_amount: number;
    address_id: string;
  }) => {
    const selectedAddr = addresses.find((a) => a.address_id === params.address_id) || addresses[0];
    const provider = providers.find((p) => p.provider_id === params.provider_id) || providers[0];
    const nearestDepot = depots.find((d) => d.provider_id === provider.provider_id) || depots[0];

    const subtotal = params.items.reduce((acc, item) => {
      const pPrices = provider.prices[item.product.product_id] || { refill: 195, exchange: 320 };
      const price = item.order_type === 'exchange' ? pPrices.exchange : pPrices.refill;
      return acc + price * item.quantity;
    }, 0);

    const deliveryFee = provider.base_delivery_fee || deliveryFeeStandard;
    const total_amount = Math.max(0, subtotal + deliveryFee - params.discount_amount);
    const orderNum = Math.floor(10000 + Math.random() * 90000);
    const orderId = `ord-${Date.now()}`;

    const newOrder: Order = {
      order_id: orderId,
      human_id: `GAS-${orderNum}`,
      user_id: currentUser.user_id,
      user: currentUser,
      provider_id: provider.provider_id,
      provider,
      address_id: selectedAddr.address_id,
      address: selectedAddr,
      depot_id: nearestDepot.depot_id,
      depot: nearestDepot,
      items: params.items.map((item, idx) => {
        const pPrices = provider.prices[item.product.product_id] || { refill: 195, exchange: 320 };
        const unitPrice = item.order_type === 'exchange' ? pPrices.exchange : pPrices.refill;
        return {
          order_item_id: `item-${Date.now()}-${idx}`,
          order_id: orderId,
          product_id: item.product.product_id,
          product: item.product,
          quantity: item.quantity,
          order_type: item.order_type,
          unit_price: unitPrice,
          total_price: unitPrice * item.quantity,
        };
      }),
      order_type: params.order_type,
      status: 'confirmed',
      payment_method: params.payment_method,
      payment_provider: params.payment_provider || params.payment_method.toUpperCase(),
      payment_status: 'completed',
      subtotal,
      delivery_fee: deliveryFee,
      discount_amount: params.discount_amount,
      promo_code: params.promo_code,
      total_amount,
      eta_minutes: provider.est_delivery_mins || 25,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      status_history: [
        {
          log_id: `log-init-${Date.now()}`,
          order_id: orderId,
          status: 'confirmed',
          timestamp: new Date().toISOString(),
          note: `Order placed with ${provider.company_name} & payment authorized via ${params.payment_provider || params.payment_method}`
        }
      ]
    };

    setOrders((prev) => [newOrder, ...prev]);

    // Push notification to user
    setNotifications((prev) => [
      {
        notification_id: `notif-${Date.now()}`,
        user_id: currentUser.user_id,
        title: `Order Confirmed! (${newOrder.human_id})`,
        message: `Your LPG delivery order from ${provider.company_name} is confirmed.`,
        type: 'order',
        is_read: false,
        timestamp: new Date().toISOString(),
      },
      ...prev,
    ]);

    return newOrder;
  }, [currentUser, addresses, providers, depots, deliveryFeeStandard]);

  // Driver accepts job
  const acceptJob = useCallback((orderId: string, driverId: string) => {
    const driver = drivers.find((d) => d.driver_id === driverId) || drivers[0];
    setOrders((prev) =>
      prev.map((ord) => {
        if (ord.order_id === orderId) {
          const updatedLogs = [
            ...ord.status_history,
            {
              log_id: `log-${Date.now()}`,
              order_id: orderId,
              status: 'out_for_delivery' as OrderStatus,
              timestamp: new Date().toISOString(),
              note: `Driver ${driver.full_name} accepted job and is on the way`
            }
          ];
          return {
            ...ord,
            driver_id: driver.driver_id,
            driver,
            status: 'out_for_delivery',
            updated_at: new Date().toISOString(),
            status_history: updatedLogs,
          };
        }
        return ord;
      })
    );
  }, [drivers]);

  // Order status transition manager
  const updateOrderStatus = useCallback((orderId: string, newStatus: OrderStatus, note?: string) => {
    setOrders((prev) =>
      prev.map((ord) => {
        if (ord.order_id === orderId) {
          const updatedLogs = [
            ...ord.status_history,
            {
              log_id: `log-${Date.now()}`,
              order_id: orderId,
              status: newStatus,
              timestamp: new Date().toISOString(),
              note: note || `Status updated to ${newStatus.replace('_', ' ')}`
            }
          ];
          return {
            ...ord,
            status: newStatus,
            updated_at: new Date().toISOString(),
            status_history: updatedLogs,
          };
        }
        return ord;
      })
    );
  }, []);

  // Cancel order
  const cancelOrder = useCallback((orderId: string, reason: string) => {
    setOrders((prev) =>
      prev.map((ord) => {
        if (ord.order_id === orderId) {
          const updatedLogs = [
            ...ord.status_history,
            {
              log_id: `log-${Date.now()}`,
              order_id: orderId,
              status: 'cancelled' as OrderStatus,
              timestamp: new Date().toISOString(),
              note: `Cancelled: ${reason}`
            }
          ];
          return {
            ...ord,
            status: 'cancelled',
            cancellation_reason: reason,
            updated_at: new Date().toISOString(),
            status_history: updatedLogs,
          };
        }
        return ord;
      })
    );
  }, []);

  // Reassign Driver (Admin)
  const reassignDriver = useCallback((orderId: string, newDriverId: string) => {
    const driver = drivers.find((d) => d.driver_id === newDriverId);
    if (!driver) return;
    setOrders((prev) =>
      prev.map((ord) => {
        if (ord.order_id === orderId) {
          return {
            ...ord,
            driver_id: driver.driver_id,
            driver,
            updated_at: new Date().toISOString(),
          };
        }
        return ord;
      })
    );
  }, [drivers]);

  // Add Promo code
  const addPromotion = useCallback((newPromo: Omit<Promotion, 'promo_id' | 'redemption_count'>) => {
    const created: Promotion = {
      ...newPromo,
      promo_id: `promo-${Date.now()}`,
      redemption_count: 0,
    };
    setPromotions((prev) => [created, ...prev]);
  }, []);

  // Mark Notification Read
  const markNotificationRead = useCallback((id: string) => {
    setNotifications((prev) => prev.map((n) => (n.notification_id === id ? { ...n, is_read: true } : n)));
  }, []);

  // Simulated Driver Movement Ticker
  useEffect(() => {
    const interval = setInterval(() => {
      const activeDeliveryOrders = orders.filter((o) => o.status === 'out_for_delivery' && o.driver_id);
      if (activeDeliveryOrders.length === 0) return;

      setDrivers((prevDrivers) =>
        prevDrivers.map((drv) => {
          const activeOrd = activeDeliveryOrders.find((o) => o.driver_id === drv.driver_id);
          if (!activeOrd) return drv;

          const targetLat = activeOrd.address.latitude;
          const targetLng = activeOrd.address.longitude;

          const latDiff = (targetLat - drv.current_lat) * 0.08;
          const lngDiff = (targetLng - drv.current_lng) * 0.08;

          return {
            ...drv,
            current_lat: drv.current_lat + latDiff,
            current_lng: drv.current_lng + lngDiff,
          };
        })
      );
    }, 2500);

    return () => clearInterval(interval);
  }, [orders]);

  // Interactive Demo Generator: Simulate New Order
  const simulateNewCustomerOrder = useCallback(() => {
    placeOrder({
      provider_id: selectedProviderId,
      items: [
        {
          product: products[2], // 9KG
          quantity: 1,
          order_type: 'exchange',
        }
      ],
      order_type: 'exchange',
      payment_method: 'mobile_money',
      payment_provider: 'Orange Money',
      promo_code: 'GAS20',
      discount_amount: 20.00,
      address_id: addresses[0].address_id,
    });
  }, [placeOrder, products, addresses, selectedProviderId]);

  // Interactive Demo Generator: Step driver progress
  const simulateDriverProgress = useCallback(() => {
    const activeOrd = orders.find((o) => o.status === 'out_for_delivery' || o.status === 'preparing' || o.status === 'confirmed');
    if (!activeOrd) return;

    if (activeOrd.status === 'confirmed') {
      updateOrderStatus(activeOrd.order_id, 'preparing', 'Depot worker staged cylinders');
    } else if (activeOrd.status === 'preparing') {
      acceptJob(activeOrd.order_id, drivers[0].driver_id);
    } else if (activeOrd.status === 'out_for_delivery') {
      updateOrderStatus(activeOrd.order_id, 'delivered', 'Customer signed OTP confirmation upon arrival');
    }
  }, [orders, updateOrderStatus, acceptJob, drivers]);

  const activeOrderForTracking = orders.find((o) => o.status !== 'delivered' && o.status !== 'cancelled') || orders[0];

  return {
    activeRole,
    setActiveRole,
    mobileViewMode,
    setMobileViewMode,
    currencySymbol,
    setCurrencySymbol,
    deliveryFeeStandard,
    districts,
    activeDistrict,
    setActiveDistrict,
    providers,
    selectedProviderId,
    setSelectedProviderId,
    registerGasProvider,
    updateProviderCompliance,
    updateProviderPrices,
    currentUser,
    addresses,
    selectedAddressId,
    setSelectedAddressId,
    addAddress,
    products,
    depots,
    updateDepotStock,
    drivers,
    activeDriverId: drivers[0]?.driver_id || 'drv-1',
    setActiveDriverId: () => {},
    toggleDriverOnline,
    verifyDriver,
    orders,
    activeOrderForTracking,
    placeOrder,
    acceptJob,
    updateOrderStatus,
    cancelOrder,
    reassignDriver,
    promotions,
    addPromotion,
    notifications,
    markNotificationRead,
    simulateNewCustomerOrder,
    simulateDriverProgress,
  };
}
