class AppConstants {
  static const String appName = 'GasExpress Botswana';
  static const String defaultCurrency = 'P';
  static const double defaultDeliveryFee = 25.00;

  static const List<String> districts = [
    'Gaborone Central',
    'Broadhurst Industrial',
    'Phakalane Estate',
    'Gaborone West',
    'Francistown Central',
    'Maun',
  ];

  static const List<String> cylinderSizes = [
    '3KG',
    '5KG',
    '9KG',
    '14KG',
    '19KG',
    '48KG',
  ];

  static const List<String> paymentMethods = [
    'Orange Money',
    'Mascom MyZaka',
    'Credit / Debit Card',
    'Cash on Delivery',
  ];
}

enum UserRole {
  customer,
  driver,
  providerAdmin,
  superAdmin,
}

enum OrderType {
  refill,
  exchange,
}

enum OrderStatus {
  pendingPayment,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}
