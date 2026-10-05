export type UserRole = 'customer' | 'driver' | 'provider_admin' | 'super_admin';

export type District = 
  | 'Gaborone Central' 
  | 'Broadhurst Industrial' 
  | 'Phakalane Estate' 
  | 'Gaborone West'
  | 'Francistown Central' 
  | 'Maun';

export type CylinderSize = '3KG' | '5KG' | '9KG' | '14KG' | '19KG' | '48KG';
export type OrderType = 'refill' | 'exchange';
export type OrderStatus = 'pending_payment' | 'confirmed' | 'preparing' | 'out_for_delivery' | 'delivered' | 'cancelled';
export type PaymentMethod = 'mobile_money' | 'card' | 'bank_transfer' | 'cash';
export type PaymentStatus = 'pending' | 'completed' | 'failed' | 'refunded';
export type DriverStatus = 'online' | 'offline' | 'suspended' | 'on_delivery';

export type ComplianceStatus = 'approved' | 'under_review' | 'suspended';

export interface GasProvider {
  provider_id: string;
  company_name: string;
  slug: string;
  logo_url: string;
  banner_url?: string;
  description: string;
  rating: number;
  review_count: number;
  districts_served: District[];
  compliance_status: ComplianceStatus;
  license_number: string;
  safety_score: number; // e.g. 98%
  contact_phone: string;
  contact_email: string;
  base_delivery_fee: number;
  est_delivery_mins: number;
  prices: Record<string, { refill: number; exchange: number }>; // product_id -> price
}

export interface User {
  user_id: string;
  full_name: string;
  email: string;
  phone: string;
  profile_photo?: string;
  referral_code: string;
  referral_earnings: number;
  created_at: string;
}

export interface Address {
  address_id: string;
  user_id: string;
  label: string;
  plot_unit: string;
  street: string;
  city: string;
  district: District;
  latitude: number;
  longitude: number;
  is_default: boolean;
}

export interface Driver {
  driver_id: string;
  provider_id: string;
  full_name: string;
  phone: string;
  email: string;
  photo_url: string;
  vehicle_type: 'Motorcycle' | 'Delivery Van' | 'Light Truck';
  vehicle_number: string;
  license_no: string;
  rating_avg: number;
  completed_orders: number;
  status: DriverStatus;
  current_lat: number;
  current_lng: number;
  verification_status: 'approved' | 'pending' | 'rejected';
}

export interface CylinderProduct {
  product_id: string;
  size: CylinderSize;
  size_kg: number;
  name: string;
  description: string;
  image_url: string;
  is_active: boolean;
  popular?: boolean;
}

export interface Depot {
  depot_id: string;
  provider_id: string;
  name: string;
  location: string;
  address: string;
  district: District;
  latitude: number;
  longitude: number;
  contact_phone: string;
  stock: Record<string, number>;
}

export interface OrderItem {
  order_item_id: string;
  order_id: string;
  product_id: string;
  product: CylinderProduct;
  quantity: number;
  order_type: OrderType;
  unit_price: number;
  total_price: number;
}

export interface OrderStatusLog {
  log_id: string;
  order_id: string;
  status: OrderStatus;
  timestamp: string;
  note?: string;
}

export interface Order {
  order_id: string;
  human_id: string;
  user_id: string;
  user: User;
  provider_id: string;
  provider?: GasProvider;
  address_id: string;
  address: Address;
  driver_id?: string;
  driver?: Driver;
  depot_id: string;
  depot?: Depot;
  items: OrderItem[];
  order_type: OrderType;
  status: OrderStatus;
  payment_method: PaymentMethod;
  payment_provider?: string;
  payment_status: PaymentStatus;
  subtotal: number;
  delivery_fee: number;
  discount_amount: number;
  promo_code?: string;
  total_amount: number;
  eta_minutes: number;
  created_at: string;
  updated_at: string;
  status_history: OrderStatusLog[];
  cancellation_reason?: string;
}

export interface Payment {
  payment_id: string;
  order_id: string;
  method: PaymentMethod;
  provider?: string;
  amount: number;
  status: PaymentStatus;
  transaction_ref: string;
  timestamp: string;
}

export interface Promotion {
  promo_id: string;
  code: string;
  description: string;
  discount_type: 'percentage' | 'fixed';
  discount_value: number;
  min_order_amount: number;
  max_discount_amount?: number;
  valid_until: string;
  redemption_count: number;
  max_redemptions: number;
  is_active: boolean;
}

export interface Notification {
  notification_id: string;
  user_id: string;
  title: string;
  message: string;
  type: 'order' | 'promo' | 'system';
  is_read: boolean;
  timestamp: string;
}
