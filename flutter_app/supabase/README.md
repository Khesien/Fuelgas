# Supabase Integration Guide for Gas Delivery Platform

This Flutter application is configured and **100% ready to connect to Supabase**.
It includes local fallback/mock storage, meaning it works immediately out-of-the-box, and automatically connects to live Supabase once credentials are provided.

---

## 1. Quick Supabase Setup

1. Create a free project at [https://supabase.com](https://supabase.com).
2. Go to **SQL Editor** in your Supabase Dashboard.
3. Paste the contents of `supabase/schema.sql` and click **Run**.
   - This creates all necessary tables (`profiles`, `gas_providers`, `products`, `provider_prices`, `depots`, `addresses`, `drivers`, `orders`, `order_items`, `order_status_logs`, `promotions`).
   - It also enables **Realtime** subscriptions for live order tracking and driver GPS positioning.
   - It sets up secure **Row Level Security (RLS)** policies.
   - It inserts initial seed data for Botswana gas providers (Afrox, Kgalagadi, Puma Energy, BOC) and cylinder types (3KG to 48KG).

---

## 2. Connect Credentials in Flutter

Open `lib/core/supabase/supabase_config.dart` and insert your Project URL and Anon Public Key:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_PUBLIC_KEY';
}
```

Or pass them as compile-time environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## 3. Realtime Features Ready

- **Live Driver Coordinates**: Real-time GPS location updates sent to customer tracking screens via Supabase channel `drivers`.
- **Order Status Stream**: When a driver or provider admin changes order status (`confirmed` -> `preparing` -> `out_for_delivery` -> `delivered`), the customer tracking screen updates instantly without page reload.
- **New Job Dispatch for Drivers**: New orders created by customers trigger instant job radar cards on the Driver app.
