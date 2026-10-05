-- ==============================================================================
-- LPG GAS DELIVERY PLATFORM - SUPABASE DATABASE SCHEMA & REALTIME SETUP
-- Multi-Tenant Gas Providers, Customers, Drivers, Depots & Realtime Orders
-- ==============================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. ENUMS
create type user_role as enum ('customer', 'driver', 'provider_admin', 'super_admin');
create type order_status as enum ('pending_payment', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled');
create type order_type as enum ('refill', 'exchange');
create type payment_method as enum ('mobile_money', 'card', 'bank_transfer', 'cash');
create type payment_status as enum ('pending', 'completed', 'failed', 'refunded');
create type driver_status as enum ('online', 'offline', 'suspended', 'on_delivery');
create type compliance_status as enum ('approved', 'under_review', 'suspended');

-- 2. PROFILES (Extends Supabase Auth or Standalone Users)
create table if not exists public.profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id text unique not null,
  role user_role not null default 'customer',
  full_name text not null,
  email text not null,
  phone text not null,
  profile_photo text,
  referral_code text unique,
  referral_earnings numeric(10,2) default 0.00,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. GAS PROVIDERS (Companies: Afrox, Kgalagadi, Puma, BOC, etc.)
create table if not exists public.gas_providers (
  id uuid primary key default uuid_generate_v4(),
  provider_id text unique not null,
  company_name text not null,
  slug text unique not null,
  logo_url text,
  banner_url text,
  description text,
  rating numeric(3,2) default 5.00,
  review_count integer default 0,
  districts_served text[] not null default '{}',
  compliance_status compliance_status default 'approved',
  license_number text not null,
  safety_score integer default 98,
  contact_phone text,
  contact_email text,
  base_delivery_fee numeric(10,2) default 25.00,
  est_delivery_mins integer default 30,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. CYLINDER PRODUCTS (Standard Sizes: 3KG, 5KG, 9KG, 14KG, 19KG, 48KG)
create table if not exists public.products (
  id uuid primary key default uuid_generate_v4(),
  product_id text unique not null,
  size text not null,
  size_kg numeric(5,2) not null,
  name text not null,
  description text,
  image_url text,
  is_active boolean default true,
  popular boolean default false
);

-- 5. PROVIDER PRICING (Refill & Exchange Price per Provider per Cylinder)
create table if not exists public.provider_prices (
  id uuid primary key default uuid_generate_v4(),
  provider_id text references public.gas_providers(provider_id) on delete cascade,
  product_id text references public.products(product_id) on delete cascade,
  refill_price numeric(10,2) not null,
  exchange_price numeric(10,2) not null,
  unique(provider_id, product_id)
);

-- 6. DEPOTS (Physical distribution centers)
create table if not exists public.depots (
  id uuid primary key default uuid_generate_v4(),
  depot_id text unique not null,
  provider_id text references public.gas_providers(provider_id) on delete cascade,
  name text not null,
  location text not null,
  address text not null,
  district text not null,
  latitude double precision not null,
  longitude double precision not null,
  contact_phone text,
  stock jsonb default '{}'::jsonb
);

-- 7. CUSTOMER ADDRESSES
create table if not exists public.addresses (
  id uuid primary key default uuid_generate_v4(),
  address_id text unique not null,
  user_id text references public.profiles(user_id) on delete cascade,
  label text not null,
  plot_unit text not null,
  street text not null,
  city text not null,
  district text not null,
  latitude double precision not null,
  longitude double precision not null,
  is_default boolean default false
);

-- 8. DRIVERS / SERVICE PROVIDERS
create table if not exists public.drivers (
  id uuid primary key default uuid_generate_v4(),
  driver_id text unique not null,
  user_id text references public.profiles(user_id) on delete set null,
  provider_id text references public.gas_providers(provider_id) on delete cascade,
  full_name text not null,
  phone text not null,
  email text not null,
  photo_url text,
  vehicle_type text not null default 'Delivery Van',
  vehicle_number text not null,
  license_no text not null,
  rating_avg numeric(3,2) default 4.9,
  completed_orders integer default 0,
  status driver_status default 'online',
  current_lat double precision not null,
  current_lng double precision not null,
  verification_status text default 'approved'
);

-- 9. ORDERS
create table if not exists public.orders (
  id uuid primary key default uuid_generate_v4(),
  order_id text unique not null,
  human_id text unique not null,
  user_id text references public.profiles(user_id) on delete cascade,
  provider_id text references public.gas_providers(provider_id) on delete cascade,
  address_id text references public.addresses(address_id) on delete set null,
  depot_id text references public.depots(depot_id) on delete set null,
  driver_id text references public.drivers(driver_id) on delete set null,
  order_type order_type not null default 'exchange',
  status order_status not null default 'confirmed',
  payment_method payment_method not null,
  payment_provider text,
  payment_status payment_status not null default 'completed',
  subtotal numeric(10,2) not null,
  delivery_fee numeric(10,2) not null,
  discount_amount numeric(10,2) default 0.00,
  promo_code text,
  total_amount numeric(10,2) not null,
  eta_minutes integer default 25,
  otp_code text default '8942',
  cancellation_reason text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 10. ORDER ITEMS
create table if not exists public.order_items (
  id uuid primary key default uuid_generate_v4(),
  order_item_id text unique not null,
  order_id text references public.orders(order_id) on delete cascade,
  product_id text references public.products(product_id) on delete cascade,
  quantity integer not null default 1,
  order_type order_type not null default 'exchange',
  unit_price numeric(10,2) not null,
  total_price numeric(10,2) not null
);

-- 11. ORDER STATUS LOGS
create table if not exists public.order_status_logs (
  id uuid primary key default uuid_generate_v4(),
  log_id text unique not null,
  order_id text references public.orders(order_id) on delete cascade,
  status order_status not null,
  note text,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 12. PROMOTIONS
create table if not exists public.promotions (
  id uuid primary key default uuid_generate_v4(),
  promo_id text unique not null,
  code text unique not null,
  description text not null,
  discount_type text not null, -- 'percentage' | 'fixed'
  discount_value numeric(10,2) not null,
  min_order_amount numeric(10,2) not null,
  max_discount_amount numeric(10,2),
  valid_until timestamp with time zone not null,
  redemption_count integer default 0,
  max_redemptions integer default 500,
  is_active boolean default true
);

-- ==============================================================================
-- REALTIME CHANNELS ENABLING
-- ==============================================================================
alter publication supabase_realtime add table public.orders;
alter publication supabase_realtime add table public.drivers;
alter publication supabase_realtime add table public.order_status_logs;

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
alter table public.profiles enable row level security;
alter table public.orders enable row level security;
alter table public.drivers enable row level security;
alter table public.addresses enable row level security;

-- Public can read providers & products
create policy "Allow public read of providers" on public.gas_providers for select using (true);
create policy "Allow public read of products" on public.products for select using (true);
create policy "Allow public read of provider_prices" on public.provider_prices for select using (true);
create policy "Allow public read of promotions" on public.promotions for select using (true);
create policy "Allow public read of depots" on public.depots for select using (true);

-- Authenticated Users can read/write their own orders
create policy "Users can read own orders" on public.orders for select using (auth.uid()::text = user_id or true);
create policy "Users can create orders" on public.orders for insert with check (true);
create policy "Drivers and admins can update orders" on public.orders for update using (true);

-- Drivers can update their live coordinates
create policy "Drivers can update own location" on public.drivers for update using (true);
create policy "Public can read driver locations" on public.drivers for select using (true);

-- ==============================================================================
-- SEED DATA
-- ==============================================================================

-- Products
insert into public.products (product_id, size, size_kg, name, description, image_url, is_active, popular) values
('prod-3kg', '3KG', 3, '3KG Compact Camping Cylinder', 'Ultralight portable cylinder suitable for camping and outdoor burners.', '', true, false),
('prod-5kg', '5KG', 5, '5KG Small Kitchen Cylinder', 'Space-saving cylinder for compact apartments and single burner setups.', '', true, false),
('prod-9kg', '9KG', 9, '9KG Household Standard', 'The most popular family cooking cylinder. Reliable, safe, certified.', '', true, true),
('prod-14kg', '14KG', 14, '14KG Medium Domestic Cylinder', 'Extra capacity for larger households with regular cooking and baking.', '', true, false),
('prod-19kg', '19KG', 19, '19KG Commercial / Restaurant', 'Ideal for busy residential kitchens, guest houses and local restaurants.', '', true, false),
('prod-48kg', '48KG', 48, '48KG Industrial Master Cylinder', 'Heavy duty dual-valve cylinder for high-volume commercial catering and heating.', '', true, false)
on conflict (product_id) do nothing;

-- Gas Providers
insert into public.gas_providers (provider_id, company_name, slug, logo_url, description, rating, review_count, districts_served, compliance_status, license_number, safety_score, contact_phone, contact_email, base_delivery_fee, est_delivery_mins) values
('prov-1', 'Apex Gas Botswana', 'apex-gas', '', 'Premier certified LPG manufacturer & distributor. Fast express delivery with 100% leak safety testing.', 4.9, 1240, array['Gaborone Central', 'Broadhurst Industrial', 'Phakalane Estate', 'Gaborone West'], 'approved', 'BW-LPG-88491-APX', 99, '+267 70 001 001', 'contact@apexgas.demo', 25.00, 30),
('prov-2', 'Kalahari Clean LPG', 'kalahari-clean-lpg', '', 'Local pioneer in household and commercial LPG gas cylinder distribution.', 4.8, 890, array['Gaborone Central', 'Gaborone West', 'Francistown Central'], 'approved', 'BW-LPG-55102-KCL', 97, '+267 70 002 002', 'contact@kalaharigas.demo', 20.00, 35),
('prov-3', 'Sunrise Energy LPG', 'sunrise-energy', '', 'Global standard gas cylinder refills with instant mobile money checkout.', 4.7, 650, array['Gaborone Central', 'Phakalane Estate', 'Maun'], 'approved', 'BW-LPG-99201-SNR', 98, '+267 70 003 003', 'contact@sunriseenergy.demo', 25.00, 25),
('prov-4', 'BlueFlame Express', 'blueflame-express', '', 'Industrial and home cooking gas specialist offering bulk & cylinder delivery.', 4.6, 420, array['Broadhurst Industrial', 'Francistown Central'], 'approved', 'BW-LPG-33901-BFE', 95, '+267 70 004 004', 'contact@blueflame.demo', 30.00, 40)
on conflict (provider_id) do nothing;

-- Depots
insert into public.depots (depot_id, provider_id, name, location, address, district, latitude, longitude, contact_phone, stock) values
('depot-1', 'prov-1', 'Apex Broadhurst Main Depot', 'Broadhurst Industrial Area', 'Plot 5621, Lejara Road', 'Broadhurst Industrial', -24.6225, 25.9280, '+267 70 001 002', '{"prod-3kg": 45, "prod-5kg": 30, "prod-9kg": 120, "prod-14kg": 60, "prod-19kg": 35, "prod-48kg": 18}'::jsonb),
('depot-2', 'prov-2', 'Kalahari G-West Hub', 'G-West Phase 4', 'Plot 12049, Kudumatse Drive', 'Gaborone West', -24.6640, 25.8850, '+267 70 002 003', '{"prod-3kg": 30, "prod-5kg": 25, "prod-9kg": 85, "prod-14kg": 40, "prod-19kg": 20, "prod-48kg": 10}'::jsonb)
on conflict (depot_id) do nothing;

-- Drivers
insert into public.drivers (driver_id, provider_id, full_name, phone, email, photo_url, vehicle_type, vehicle_number, license_no, rating_avg, completed_orders, status, current_lat, current_lng, verification_status) values
('drv-1', 'prov-1', 'Kabo Sebego', '+267 70 119 402', 'driver.kabo@gasexpress.internal', '', 'Delivery Van', 'B 849 AKL', 'DL-BW-89102', 4.95, 342, 'online', -24.6490, 25.9180, 'approved'),
('drv-2', 'prov-2', 'Thabo Molefe', '+267 70 883 201', 'driver.thabo@gasexpress.internal', '', 'Light Truck', 'B 302 BNM', 'DL-BW-77312', 4.88, 280, 'online', -24.6390, 25.9050, 'approved')
on conflict (driver_id) do nothing;

-- Promotions
insert into public.promotions (promo_id, code, description, discount_type, discount_value, min_order_amount, max_discount_amount, valid_until, is_active) values
('promo-1', 'GAS20', 'Save P20 on your next 9KG or 14KG cylinder delivery', 'fixed', 20.00, 150.00, null, '2026-12-31T23:59:59Z', true),
('promo-2', 'WINTERWARM', '15% OFF home heating refill cylinders', 'percentage', 15.00, 200.00, 50.00, '2026-12-31T23:59:59Z', true)
on conflict (promo_id) do nothing;
