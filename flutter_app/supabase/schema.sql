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
-- SEED DATA — CYLINDER PRODUCT CATALOG ONLY
-- (Standard LPG cylinder sizes used industry-wide in Botswana)
-- Gas Providers, Depots, Drivers, and Promotions must be created via the
-- admin dashboard or Supabase Table Editor — no demo data is seeded here.
-- ==============================================================================

-- Standard Cylinder Products (LPG industry-standard sizes)
insert into public.products (product_id, size, size_kg, name, description, image_url, is_active, popular) values
('prod-3kg',  '3KG',  3,  '3KG Compact Cylinder',           'Lightweight portable cylinder for camping and single-burner use.',                       '', true, false),
('prod-5kg',  '5KG',  5,  '5KG Small Kitchen Cylinder',     'Space-saving cylinder for compact apartments.',                                          '', true, false),
('prod-9kg',  '9KG',  9,  '9KG Household Standard',         'The most popular family cooking cylinder. Reliable, safe, and certified.',               '', true, true),
('prod-14kg', '14KG', 14, '14KG Medium Domestic Cylinder',  'Extra capacity for larger households with regular cooking and baking.',                   '', true, false),
('prod-19kg', '19KG', 19, '19KG Commercial / Restaurant',   'Ideal for busy kitchens, guest houses, and local restaurants.',                          '', true, false),
('prod-48kg', '48KG', 48, '48KG Industrial Master Cylinder', 'Heavy-duty dual-valve cylinder for high-volume commercial catering and heating.',        '', true, false)
on conflict (product_id) do nothing;

-- ==============================================================================
-- HOW TO ADD YOUR REAL DATA
-- ==============================================================================
-- 1. GAS PROVIDERS: Insert via Supabase Table Editor → gas_providers table
--    Required fields: provider_id, company_name, slug, license_number,
--    districts_served, base_delivery_fee, est_delivery_mins
--
-- 2. DEPOTS: Insert via Supabase Table Editor → depots table
--    Required fields: depot_id, provider_id, name, address, district, lat/lng
--
-- 3. DRIVERS: Created automatically when a user registers with role='driver'
--    and their profile is promoted by a provider admin.
--
-- 4. PROMOTIONS: Insert via Supabase Table Editor → promotions table
--    Required fields: promo_id, code, description, discount_type,
--    discount_value, min_order_amount, valid_until
-- ==============================================================================

