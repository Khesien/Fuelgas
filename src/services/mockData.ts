import { CylinderProduct, Depot, Driver, User, Address, Promotion, Order, GasProvider, District } from '../types';

export const MOCK_DISTRICTS: District[] = [
  'Gaborone Central',
  'Broadhurst Industrial',
  'Phakalane Estate',
  'Gaborone West',
  'Francistown Central',
  'Maun',
];

export const MOCK_GAS_PROVIDERS: GasProvider[] = [
  {
    provider_id: 'prov-1',
    company_name: 'Afrox Gas Botswana',
    slug: 'afrox-gas',
    logo_url: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=150&q=80',
    description: 'Premier certified LPG manufacturer & distributor. Fast express delivery with 100% leak safety testing.',
    rating: 4.9,
    review_count: 1240,
    districts_served: ['Gaborone Central', 'Broadhurst Industrial', 'Phakalane Estate', 'Gaborone West'],
    compliance_status: 'approved',
    license_number: 'BW-LPG-88491-AFX',
    safety_score: 99,
    contact_phone: '+267 391 2900',
    contact_email: 'orders@afrox.co.bw',
    base_delivery_fee: 25.00,
    est_delivery_mins: 30,
    prices: {
      'prod-3kg': { refill: 65.00, exchange: 110.00 },
      'prod-5kg': { refill: 115.00, exchange: 185.00 },
      'prod-9kg': { refill: 195.00, exchange: 320.00 },
      'prod-14kg': { refill: 290.00, exchange: 460.00 },
      'prod-19kg': { refill: 395.00, exchange: 620.00 },
      'prod-48kg': { refill: 950.00, exchange: 1450.00 },
    }
  },
  {
    provider_id: 'prov-2',
    company_name: 'Kgalagadi LPG Supply',
    slug: 'kgalagadi-gas',
    logo_url: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?auto=format&fit=crop&w=150&q=80',
    description: 'Local pioneer in household and commercial LPG gas cylinder distribution.',
    rating: 4.8,
    review_count: 890,
    districts_served: ['Gaborone Central', 'Gaborone West', 'Francistown Central'],
    compliance_status: 'approved',
    license_number: 'BW-LPG-55102-KGL',
    safety_score: 97,
    contact_phone: '+267 395 8810',
    contact_email: 'support@kgalagadigas.bw',
    base_delivery_fee: 20.00,
    est_delivery_mins: 35,
    prices: {
      'prod-3kg': { refill: 60.00, exchange: 105.00 },
      'prod-5kg': { refill: 110.00, exchange: 180.00 },
      'prod-9kg': { refill: 190.00, exchange: 310.00 },
      'prod-14kg': { refill: 285.00, exchange: 450.00 },
      'prod-19kg': { refill: 385.00, exchange: 600.00 },
      'prod-48kg': { refill: 920.00, exchange: 1400.00 },
    }
  },
  {
    provider_id: 'prov-3',
    company_name: 'Puma Energy LPG',
    slug: 'puma-lpg',
    logo_url: 'https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&w=150&q=80',
    description: 'Global energy standard gas cylinder refills with instant mobile money checkout.',
    rating: 4.7,
    review_count: 650,
    districts_served: ['Gaborone Central', 'Phakalane Estate', 'Maun'],
    compliance_status: 'approved',
    license_number: 'BW-LPG-99201-PUM',
    safety_score: 98,
    contact_phone: '+267 390 1122',
    contact_email: 'lpg@pumaenergy.bw',
    base_delivery_fee: 25.00,
    est_delivery_mins: 25,
    prices: {
      'prod-3kg': { refill: 62.00, exchange: 108.00 },
      'prod-5kg': { refill: 112.00, exchange: 182.00 },
      'prod-9kg': { refill: 192.00, exchange: 315.00 },
      'prod-14kg': { refill: 288.00, exchange: 455.00 },
      'prod-19kg': { refill: 390.00, exchange: 610.00 },
      'prod-48kg': { refill: 940.00, exchange: 1420.00 },
    }
  },
  {
    provider_id: 'prov-4',
    company_name: 'BOC Express Gas',
    slug: 'boc-express',
    logo_url: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=150&q=80',
    description: 'Industrial and home cooking gas specialist offering bulk & cylinder delivery.',
    rating: 4.6,
    review_count: 420,
    districts_served: ['Broadhurst Industrial', 'Francistown Central'],
    compliance_status: 'approved',
    license_number: 'BW-LPG-33901-BOC',
    safety_score: 95,
    contact_phone: '+267 392 4410',
    contact_email: 'info@bocgas.co.bw',
    base_delivery_fee: 30.00,
    est_delivery_mins: 40,
    prices: {
      'prod-3kg': { refill: 64.00, exchange: 109.00 },
      'prod-5kg': { refill: 114.00, exchange: 184.00 },
      'prod-9kg': { refill: 194.00, exchange: 318.00 },
      'prod-14kg': { refill: 289.00, exchange: 458.00 },
      'prod-19kg': { refill: 392.00, exchange: 615.00 },
      'prod-48kg': { refill: 945.00, exchange: 1430.00 },
    }
  },
  {
    provider_id: 'prov-5',
    company_name: 'FastGas Express Ltd',
    slug: 'fastgas-express',
    logo_url: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?auto=format&fit=crop&w=150&q=80',
    description: 'Newly registered local provider undergoing initial compliance inspection.',
    rating: 4.2,
    review_count: 45,
    districts_served: ['Gaborone West'],
    compliance_status: 'under_review',
    license_number: 'BW-LPG-11002-FST',
    safety_score: 84,
    contact_phone: '+267 71 000 888',
    contact_email: 'ops@fastgas.bw',
    base_delivery_fee: 15.00,
    est_delivery_mins: 45,
    prices: {
      'prod-3kg': { refill: 58.00, exchange: 100.00 },
      'prod-5kg': { refill: 105.00, exchange: 175.00 },
      'prod-9kg': { refill: 185.00, exchange: 300.00 },
      'prod-14kg': { refill: 280.00, exchange: 440.00 },
      'prod-19kg': { refill: 380.00, exchange: 590.00 },
      'prod-48kg': { refill: 900.00, exchange: 1380.00 },
    }
  }
];

export const MOCK_USER: User = {
  user_id: 'usr-101',
  full_name: 'Lesedi Kgosi',
  email: 'lesedi.kgosi@example.com',
  phone: '+267 72 894 112',
  profile_photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&q=80',
  referral_code: 'GAS-LESEDI-26',
  referral_earnings: 150.00,
  created_at: '2025-11-14T10:30:00Z',
};

export const MOCK_ADDRESSES: Address[] = [
  {
    address_id: 'addr-1',
    user_id: 'usr-101',
    label: 'Home',
    plot_unit: 'Plot 4829',
    street: 'Khama Crescent, Block 6',
    city: 'Gaborone',
    district: 'Gaborone Central',
    latitude: -24.6541,
    longitude: 25.9087,
    is_default: true,
  },
  {
    address_id: 'addr-2',
    user_id: 'usr-101',
    label: 'Work Office',
    plot_unit: 'Unit 12, iTowers South',
    street: 'CBD Central Avenue',
    city: 'Gaborone',
    district: 'Gaborone Central',
    latitude: -24.6592,
    longitude: 25.9124,
    is_default: false,
  },
  {
    address_id: 'addr-3',
    user_id: 'usr-101',
    label: 'Family House',
    plot_unit: 'Plot 1083',
    street: 'Extension 11',
    city: 'Gaborone',
    district: 'Broadhurst Industrial',
    latitude: -24.6421,
    longitude: 25.9231,
    is_default: false,
  }
];

export const MOCK_PRODUCTS: CylinderProduct[] = [
  {
    product_id: 'prod-3kg',
    size: '3KG',
    size_kg: 3,
    name: '3KG Portable LPG Cylinder',
    description: 'Compact & lightweight for camping, single-burner stoves, and outdoor quick cooking.',
    image_url: 'https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&w=400&q=80',
    is_active: true,
    popular: false,
  },
  {
    product_id: 'prod-5kg',
    size: '5KG',
    size_kg: 5,
    name: '5KG Household Standard Cylinder',
    description: 'Ideal for small apartments, couples, and student accommodations.',
    image_url: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?auto=format&fit=crop&w=400&q=80',
    is_active: true,
    popular: true,
  },
  {
    product_id: 'prod-9kg',
    size: '9KG',
    size_kg: 9,
    name: '9KG Family Favorite LPG Cylinder',
    description: 'Most popular choice for medium family kitchens, outdoor braai, and heaters.',
    image_url: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=400&q=80',
    is_active: true,
    popular: true,
  },
  {
    product_id: 'prod-14kg',
    size: '14KG',
    size_kg: 14,
    name: '14KG Medium Commercial Cylinder',
    description: 'Designed for daily home cooking and small food stalls or bakeries.',
    image_url: 'https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&w=400&q=80',
    is_active: true,
    popular: false,
  },
  {
    product_id: 'prod-19kg',
    size: '19KG',
    size_kg: 19,
    name: '19KG Heavy Duty Kitchen Cylinder',
    description: 'High capacity for large families, restaurants, and catering services.',
    image_url: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?auto=format&fit=crop&w=400&q=80',
    is_active: true,
    popular: true,
  },
  {
    product_id: 'prod-48kg',
    size: '48KG',
    size_kg: 48,
    name: '48KG Industrial Commercial Cylinder',
    description: 'Maximum capacity for hotels, schools, bakeries, and industrial central gas lines.',
    image_url: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=400&q=80',
    is_active: true,
    popular: false,
  }
];

export const MOCK_DEPOTS: Depot[] = [
  {
    depot_id: 'depot-1',
    provider_id: 'prov-1',
    name: 'Afrox Gaborone Hub',
    location: 'Gaborone West Industrial',
    address: 'Plot 14389, Nakedi Road, Gaborone West',
    district: 'Gaborone Central',
    latitude: -24.6612,
    longitude: 25.8998,
    contact_phone: '+267 395 1020',
    stock: {
      'prod-3kg': 45,
      'prod-5kg': 82,
      'prod-9kg': 140,
      'prod-14kg': 60,
      'prod-19kg': 95,
      'prod-48kg': 28,
    }
  },
  {
    depot_id: 'depot-2',
    provider_id: 'prov-2',
    name: 'Kgalagadi Broadhurst Depot',
    location: 'Broadhurst Industrial Area',
    address: 'Plot 10244, Kubu Road, Broadhurst',
    district: 'Broadhurst Industrial',
    latitude: -24.6310,
    longitude: 25.9320,
    contact_phone: '+267 391 4455',
    stock: {
      'prod-3kg': 30,
      'prod-5kg': 60,
      'prod-9kg': 110,
      'prod-14kg': 40,
      'prod-19kg': 50,
      'prod-48kg': 15,
    }
  }
];

export const MOCK_DRIVERS: Driver[] = [
  {
    driver_id: 'drv-1',
    provider_id: 'prov-1',
    full_name: 'Kabo Tau',
    phone: '+267 71 554 982',
    email: 'kabo.tau@afrox.co.bw',
    photo_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=250&q=80',
    vehicle_type: 'Delivery Van',
    vehicle_number: 'B 482 APG',
    license_no: 'BW-DL-89412',
    rating_avg: 4.9,
    completed_orders: 412,
    status: 'online',
    current_lat: -24.6560,
    current_lng: 25.9050,
    verification_status: 'approved',
  },
  {
    driver_id: 'drv-2',
    provider_id: 'prov-2',
    full_name: 'Thero Mpho',
    phone: '+267 74 219 004',
    email: 'thero.mpho@kgalagadigas.bw',
    photo_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=250&q=80',
    vehicle_type: 'Light Truck',
    vehicle_number: 'B 913 BCD',
    license_no: 'BW-DL-54129',
    rating_avg: 4.8,
    completed_orders: 285,
    status: 'online',
    current_lat: -24.6380,
    current_lng: 25.9280,
    verification_status: 'approved',
  }
];

export const MOCK_PROMOTIONS: Promotion[] = [
  {
    promo_id: 'p-101',
    code: 'GAS20',
    description: 'Get P20 OFF on your first 9KG or 19KG cylinder exchange or refill.',
    discount_type: 'fixed',
    discount_value: 20.00,
    min_order_amount: 150.00,
    valid_until: '2026-12-31',
    redemption_count: 142,
    max_redemptions: 500,
    is_active: true,
  },
  {
    promo_id: 'p-102',
    code: 'WINTERWARM',
    description: '15% discount on all cylinder orders above P300.',
    discount_type: 'percentage',
    discount_value: 15,
    min_order_amount: 300.00,
    max_discount_amount: 75.00,
    valid_until: '2026-09-30',
    redemption_count: 89,
    max_redemptions: 300,
    is_active: true,
  }
];

export const MOCK_INITIAL_ORDERS: Order[] = [
  {
    order_id: 'ord-8801',
    human_id: 'GAS-12548',
    user_id: 'usr-101',
    user: MOCK_USER,
    provider_id: 'prov-1',
    provider: MOCK_GAS_PROVIDERS[0],
    address_id: 'addr-1',
    address: MOCK_ADDRESSES[0],
    driver_id: 'drv-1',
    driver: MOCK_DRIVERS[0],
    depot_id: 'depot-1',
    depot: MOCK_DEPOTS[0],
    items: [
      {
        order_item_id: 'item-1',
        order_id: 'ord-8801',
        product_id: 'prod-9kg',
        product: MOCK_PRODUCTS[2],
        quantity: 1,
        order_type: 'exchange',
        unit_price: 320.00,
        total_price: 320.00,
      }
    ],
    order_type: 'exchange',
    status: 'out_for_delivery',
    payment_method: 'mobile_money',
    payment_provider: 'Orange Money',
    payment_status: 'completed',
    subtotal: 320.00,
    delivery_fee: 25.00,
    discount_amount: 20.00,
    promo_code: 'GAS20',
    total_amount: 325.00,
    eta_minutes: 18,
    created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
    updated_at: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
    status_history: [
      {
        log_id: 'log-1',
        order_id: 'ord-8801',
        status: 'pending_payment',
        timestamp: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
        note: 'Payment authorization requested via Orange Money'
      },
      {
        log_id: 'log-2',
        order_id: 'ord-8801',
        status: 'confirmed',
        timestamp: new Date(Date.now() - 24 * 60 * 1000).toISOString(),
        note: 'Payment successful.'
      },
      {
        log_id: 'log-3',
        order_id: 'ord-8801',
        status: 'preparing',
        timestamp: new Date(Date.now() - 18 * 60 * 1000).toISOString(),
        note: 'Afrox Gaborone Hub staged 1x 9KG Exchange cylinder'
      },
      {
        log_id: 'log-4',
        order_id: 'ord-8801',
        status: 'out_for_delivery',
        timestamp: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
        note: 'Driver Kabo Tau accepted job and departed depot'
      }
    ]
  }
];

export const MOCK_NOTIFICATIONS = [
  {
    notification_id: 'notif-1',
    user_id: 'usr-101',
    title: 'Driver is Out for Delivery! 🚚',
    message: 'Kabo Tau from Afrox Gas is on the way with your 9KG LPG Exchange cylinder.',
    type: 'order' as const,
    is_read: false,
    timestamp: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
  }
];
