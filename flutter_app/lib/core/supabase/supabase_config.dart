class SupabaseConfig {
  static const String _defaultUrl = 'https://khrghlytmvwynuqsucdp.supabase.co';
  static const String _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtocmdobHl0bXZ3eW51cXN1Y2RwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTExNzIxNDEsImV4cCI6MjEwNjc0ODE0MX0.nsQqXt3GYsCx3Y665IFauNxIVIqHkse3FWNewn4fsDo';

  static String get supabaseUrl {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    final raw = fromEnv.isNotEmpty ? fromEnv : _defaultUrl;
    // Normalize URL in case /rest/v1/ was included
    return raw
        .replaceAll(RegExp(r'/rest/v1/?$'), '')
        .replaceAll(RegExp(r'/$'), '');
  }

  static String get supabaseAnonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _defaultAnonKey;
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR_PROJECT_ID');
}
