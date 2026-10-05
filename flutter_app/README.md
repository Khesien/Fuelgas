# GasExpress Botswana - Flutter Mobile Application

A cross-platform Flutter mobile application converting the prototype into a production-grade app for **Customers** and **Service Providers (Drivers & Depot Admins)**, ready to connect directly to **Supabase**.

---

## 🌟 Key Features

### 👤 1. Customer Mobile Experience
- **District & Location Filtering**: District selector across Gaborone Central, Broadhurst, Phakalane, Gaborone West, Francistown, Maun.
- **Gas Providers Marketplace**: Browse certified providers (Afrox Gas, Kgalagadi LPG, Puma Energy, BOC Express) with ratings, safety scores, and delivery fees.
- **Cylinder Catalog**: Choose from 3KG, 5KG, 9KG (Most Popular), 14KG, 19KG, and 48KG cylinders.
- **Exchange vs. Refill Toggle**: Live price recalculations based on service type.
- **Checkout & Mobile Money**: Support for **Orange Money**, **Mascom MyZaka**, Card, and Cash on Delivery, plus promo codes (e.g. `GAS20`).
- **Interactive Live Map Tracking**: Custom animated canvas map displaying Depot hub, customer home pin, and moving driver vehicle marker with live GPS simulation.
- **Security OTP Handover**: 4-digit verification code to give to the driver upon cylinder inspection.
- **Saved Addresses & Profile**: Manage multiple delivery addresses and reorder in 1-tap.

### 🚚 2. Service Provider & Driver Experience
- **Online / Offline Availability Toggle**: Instant status toggle to start or stop receiving jobs.
- **New Job Radar**: Incoming job alerts with pickup depot, customer destination, payload info, and payout estimate.
- **Active Trip Fulfilment**: Route navigation map, 1-tap call customer, safety leak checklist, and OTP confirmation.
- **Driver Wallet & Earnings**: Daily earnings breakdown, weekly totals, acceptance rate, and express mobile money payout requests.

### 🏭 3. Provider Admin & Depot Management
- **Depot Inventory**: Real-time stock counts for all cylinder sizes (3KG to 48KG) with stepper controls.
- **Fleet Roster**: Live driver availability and active route status.
- **Safety & Compliance**: Accreditation badge with license numbers and safety audit scores.

---

## ⚡ Supabase Setup (Ready to Connect)

The app is **100% prepared for Supabase** with offline fallback so it works immediately out-of-the-box.

1. Create a free project at [supabase.com](https://supabase.com).
2. Open your project's **SQL Editor** and run the script in:
   ```
   flutter_app/supabase/schema.sql
   ```
   This generates all tables (`profiles`, `gas_providers`, `products`, `provider_prices`, `depots`, `addresses`, `drivers`, `orders`, `order_items`, `order_status_logs`, `promotions`), enables Realtime replication, sets up Row Level Security (RLS), and seeds initial data.

3. Add your Supabase credentials in `lib/core/supabase/supabase_config.dart`:
   ```dart
   class SupabaseConfig {
     static const String _defaultUrl = 'https://YOUR_PROJECT_ID.supabase.co';
     static const String _defaultAnonKey = 'YOUR_ANON_PUBLIC_KEY';
   }
   ```
   Or run with compile-time defines:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key
   ```

---

## 📱 How to Run

Navigate into the `flutter_app` directory:

```bash
cd flutter_app
flutter pub get
```

Run on your connected Android device, iOS simulator, or Chrome:

```bash
# Android
flutter run -d android

# Chrome / Web
flutter run -d chrome

# iOS
flutter run -d ios
```

---

## 🗂 Project Architecture

```
flutter_app/
├── lib/
│   ├── main.dart                          # App entry point & role router
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart            # Modern vibrant dark color tokens
│   │   │   └── app_constants.dart         # Enums, districts, cylinder sizes
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Google Fonts & dark theme configuration
│   │   └── supabase/
│   │       ├── supabase_config.dart       # Supabase URL & Key configuration
│   │       └── supabase_service.dart      # Realtime streams and mutations
│   ├── models/
│   │   ├── address_model.dart             # Delivery addresses
│   │   ├── depot_model.dart               # Depots & stock inventory
│   │   ├── driver_model.dart              # Driver location & vehicle info
│   │   ├── order_model.dart               # Orders, items, status logs
│   │   ├── product_model.dart             # Cylinder sizes & metadata
│   │   ├── promotion_model.dart           # Promo codes & discount values
│   │   ├── provider_model.dart            # Multi-tenant gas providers & pricing
│   │   └── user_model.dart                # Customer profiles
│   ├── services/
│   │   └── mock_data_service.dart         # Seed data & offline fallback
│   ├── providers/
│   │   ├── app_state_provider.dart        # Global state, role switching, order engine
│   │   └── cart_provider.dart             # Checkout cart, cylinder selection, totals
│   └── screens/
│       ├── common/
│       │   ├── glass_container.dart       # Glassmorphism container widget
│       │   ├── live_tracking_map_widget.dart # Custom GPS map painter
│       │   ├── role_switch_sheet.dart     # Customer <-> Driver <-> Admin switcher
│       │   └── status_badge.dart          # Status pill with color indicators
│       ├── customer/
│       │   ├── customer_main_nav.dart     # Bottom navigation tabs
│       │   ├── customer_home_screen.dart  # Providers list, promo banner, catalog
│       │   ├── cylinder_selection_screen.dart # 3KG-48KG & refill/exchange toggle
│       │   ├── checkout_screen.dart       # Mobile Money & delivery confirmation
│       │   ├── order_tracking_screen.dart # Live map, OTP, stepper timeline
│       │   ├── customer_profile_screen.dart # Account & order history with Reorder
│       │   └── addresses_management_screen.dart # Saved addresses CRUD
│       └── provider/
│           ├── provider_main_nav.dart     # Provider bottom navigation
│           ├── driver_jobs_screen.dart    # Job radar & incoming trip acceptance
│           ├── driver_delivery_screen.dart# Navigation, safety check, OTP verification
│           ├── driver_earnings_screen.dart# Daily/weekly earnings & payout request
│           ├── provider_admin_inventory_screen.dart # Stock management & fleet roster
│           └── provider_profile_screen.dart# Partner credentials & vehicle details
├── supabase/
│   ├── schema.sql                         # Complete PostgreSQL schema & Realtime setup
│   └── README.md                          # Supabase integration tutorial
└── pubspec.yaml                           # Flutter dependencies
```
