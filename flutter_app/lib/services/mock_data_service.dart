import '../models/address_model.dart';
import '../models/depot_model.dart';
import '../models/driver_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/promotion_model.dart';
import '../models/provider_model.dart';
import '../models/user_model.dart';

class MockDataService {
  static UserModel get mockUser => UserModel(
        userId: 'usr-demo-101',
        fullName: 'Kagiso Molosiwa',
        email: 'kagiso.demo@gasexpress.internal',
        phone: '+267 70 123 456',
        profilePhoto: null,
        referralCode: 'GAS2026',
        referralEarnings: 60.00,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      );

  static List<AddressModel> get mockAddresses => [
        AddressModel(
          addressId: 'addr-1',
          userId: 'usr-demo-101',
          label: 'Home (Extension 9)',
          plotUnit: 'Plot 4812, Unit B',
          street: 'Independence Avenue',
          city: 'Gaborone',
          district: 'Gaborone Central',
          latitude: -24.6580,
          longitude: 25.9120,
          isDefault: true,
        ),
        AddressModel(
          addressId: 'addr-2',
          userId: 'usr-demo-101',
          label: 'Office (Broadhurst)',
          plotUnit: 'Suite 401, Plot 1021',
          street: 'Kubu Road',
          city: 'Gaborone',
          district: 'Broadhurst Industrial',
          latitude: -24.6225,
          longitude: 25.9280,
          isDefault: false,
        ),
        AddressModel(
          addressId: 'addr-3',
          userId: 'usr-demo-101',
          label: 'Residence (Phakalane)',
          plotUnit: 'House 884',
          street: 'Acacia Drive',
          city: 'Gaborone',
          district: 'Phakalane Estate',
          latitude: -24.5750,
          longitude: 25.9490,
          isDefault: false,
        ),
      ];

  static List<CylinderProductModel> get mockProducts => [
        CylinderProductModel(
          productId: 'prod-3kg',
          size: '3KG',
          sizeKg: 3.0,
          name: '3KG Compact Camping Cylinder',
          description:
              'Ultralight portable cylinder suitable for camping and outdoor burners.',
          imageUrl: '',
          popular: false,
        ),
        CylinderProductModel(
          productId: 'prod-5kg',
          size: '5KG',
          sizeKg: 5.0,
          name: '5KG Small Kitchen Cylinder',
          description:
              'Space-saving cylinder for compact apartments and single burner setups.',
          imageUrl: '',
          popular: false,
        ),
        CylinderProductModel(
          productId: 'prod-9kg',
          size: '9KG',
          sizeKg: 9.0,
          name: '9KG Household Standard',
          description:
              'The most popular family cooking cylinder. Reliable, safe, certified.',
          imageUrl: '',
          popular: true,
        ),
        CylinderProductModel(
          productId: 'prod-14kg',
          size: '14KG',
          sizeKg: 14.0,
          name: '14KG Medium Domestic Cylinder',
          description:
              'Extra capacity for larger households with regular cooking and baking.',
          imageUrl: '',
          popular: false,
        ),
        CylinderProductModel(
          productId: 'prod-19kg',
          size: '19KG',
          sizeKg: 19.0,
          name: '19KG Commercial / Restaurant',
          description:
              'Ideal for busy residential kitchens, guest houses and local restaurants.',
          imageUrl: '',
          popular: false,
        ),
        CylinderProductModel(
          productId: 'prod-48kg',
          size: '48KG',
          sizeKg: 48.0,
          name: '48KG Industrial Master Cylinder',
          description:
              'Heavy duty dual-valve cylinder for high-volume commercial catering and heating.',
          imageUrl: '',
          popular: false,
        ),
      ];

  static List<GasProviderModel> get mockProviders => [
        GasProviderModel(
          providerId: 'prov-1',
          companyName: 'Apex Gas Botswana',
          slug: 'apex-gas',
          logoUrl: '',
          description:
              'Premier certified LPG manufacturer & distributor. Fast express delivery with 100% leak safety testing.',
          rating: 4.9,
          reviewCount: 1240,
          districtsServed: [
            'Gaborone Central',
            'Broadhurst Industrial',
            'Phakalane Estate',
            'Gaborone West'
          ],
          complianceStatus: 'approved',
          licenseNumber: 'BW-LPG-88491-APX',
          safetyScore: 99,
          contactPhone: '+267 70 001 001',
          contactEmail: 'contact@apexgas.demo',
          baseDeliveryFee: 25.00,
          estDeliveryMins: 30,
          prices: {
            'prod-3kg': PriceTier(refill: 65.0, exchange: 110.0),
            'prod-5kg': PriceTier(refill: 115.0, exchange: 185.0),
            'prod-9kg': PriceTier(refill: 195.0, exchange: 320.0),
            'prod-14kg': PriceTier(refill: 290.0, exchange: 460.0),
            'prod-19kg': PriceTier(refill: 395.0, exchange: 620.0),
            'prod-48kg': PriceTier(refill: 950.0, exchange: 1450.0),
          },
        ),
        GasProviderModel(
          providerId: 'prov-2',
          companyName: 'Kalahari Clean LPG',
          slug: 'kalahari-clean-lpg',
          logoUrl: '',
          description:
              'Local pioneer in household and commercial LPG gas cylinder distribution.',
          rating: 4.8,
          reviewCount: 890,
          districtsServed: [
            'Gaborone Central',
            'Gaborone West',
            'Francistown Central'
          ],
          complianceStatus: 'approved',
          licenseNumber: 'BW-LPG-55102-KCL',
          safetyScore: 97,
          contactPhone: '+267 70 002 002',
          contactEmail: 'contact@kalaharigas.demo',
          baseDeliveryFee: 20.00,
          estDeliveryMins: 35,
          prices: {
            'prod-3kg': PriceTier(refill: 60.0, exchange: 105.0),
            'prod-5kg': PriceTier(refill: 110.0, exchange: 180.0),
            'prod-9kg': PriceTier(refill: 190.0, exchange: 310.0),
            'prod-14kg': PriceTier(refill: 285.0, exchange: 450.0),
            'prod-19kg': PriceTier(refill: 385.0, exchange: 600.0),
            'prod-48kg': PriceTier(refill: 920.0, exchange: 1400.0),
          },
        ),
        GasProviderModel(
          providerId: 'prov-3',
          companyName: 'Sunrise Energy LPG',
          slug: 'sunrise-energy',
          logoUrl: '',
          description:
              'Global standard gas cylinder refills with instant mobile money checkout.',
          rating: 4.7,
          reviewCount: 650,
          districtsServed: ['Gaborone Central', 'Phakalane Estate', 'Maun'],
          complianceStatus: 'approved',
          licenseNumber: 'BW-LPG-99201-SNR',
          safetyScore: 98,
          contactPhone: '+267 70 003 003',
          contactEmail: 'contact@sunriseenergy.demo',
          baseDeliveryFee: 25.00,
          estDeliveryMins: 25,
          prices: {
            'prod-3kg': PriceTier(refill: 62.0, exchange: 108.0),
            'prod-5kg': PriceTier(refill: 112.0, exchange: 182.0),
            'prod-9kg': PriceTier(refill: 192.0, exchange: 315.0),
            'prod-14kg': PriceTier(refill: 288.0, exchange: 455.0),
            'prod-19kg': PriceTier(refill: 390.0, exchange: 610.0),
            'prod-48kg': PriceTier(refill: 940.0, exchange: 1420.0),
          },
        ),
        GasProviderModel(
          providerId: 'prov-4',
          companyName: 'BlueFlame Express',
          slug: 'blueflame-express',
          logoUrl: '',
          description:
              'Industrial and home cooking gas specialist offering bulk & cylinder delivery.',
          rating: 4.6,
          reviewCount: 420,
          districtsServed: ['Broadhurst Industrial', 'Francistown Central'],
          complianceStatus: 'approved',
          licenseNumber: 'BW-LPG-33901-BFE',
          safetyScore: 95,
          contactPhone: '+267 70 004 004',
          contactEmail: 'contact@blueflame.demo',
          baseDeliveryFee: 30.00,
          estDeliveryMins: 40,
          prices: {
            'prod-3kg': PriceTier(refill: 65.0, exchange: 110.0),
            'prod-5kg': PriceTier(refill: 115.0, exchange: 185.0),
            'prod-9kg': PriceTier(refill: 195.0, exchange: 320.0),
            'prod-14kg': PriceTier(refill: 290.0, exchange: 460.0),
            'prod-19kg': PriceTier(refill: 395.0, exchange: 620.0),
            'prod-48kg': PriceTier(refill: 950.0, exchange: 1450.0),
          },
        ),
      ];

  static List<DepotModel> get mockDepots => [
        DepotModel(
          depotId: 'depot-1',
          providerId: 'prov-1',
          name: 'Apex Broadhurst Main Depot',
          location: 'Broadhurst Industrial Area',
          address: 'Plot 5621, Lejara Road',
          district: 'Broadhurst Industrial',
          latitude: -24.6225,
          longitude: 25.9280,
          contactPhone: '+267 70 001 002',
          stock: {
            'prod-3kg': 45,
            'prod-5kg': 30,
            'prod-9kg': 120,
            'prod-14kg': 60,
            'prod-19kg': 35,
            'prod-48kg': 18,
          },
        ),
        DepotModel(
          depotId: 'depot-2',
          providerId: 'prov-2',
          name: 'Kalahari G-West Hub',
          location: 'G-West Phase 4',
          address: 'Plot 12049, Kudumatse Drive',
          district: 'Gaborone West',
          latitude: -24.6640,
          longitude: 25.8850,
          contactPhone: '+267 70 002 003',
          stock: {
            'prod-3kg': 30,
            'prod-5kg': 25,
            'prod-9kg': 85,
            'prod-14kg': 40,
            'prod-19kg': 20,
            'prod-48kg': 10,
          },
        ),
      ];

  static List<DriverModel> get mockDrivers => [
        DriverModel(
          driverId: 'drv-1',
          providerId: 'prov-1',
          fullName: 'Kabo Sebego',
          phone: '+267 70 119 402',
          email: 'driver.kabo@gasexpress.internal',
          photoUrl: '',
          vehicleType: 'Delivery Van',
          vehicleNumber: 'B 849 AKL',
          licenseNo: 'DL-BW-89102',
          ratingAvg: 4.95,
          completedOrders: 342,
          status: 'online',
          currentLat: -24.6490,
          currentLng: 25.9180,
          verificationStatus: 'approved',
        ),
        DriverModel(
          driverId: 'drv-2',
          providerId: 'prov-2',
          fullName: 'Thabo Molefe',
          phone: '+267 70 883 201',
          email: 'driver.thabo@gasexpress.internal',
          photoUrl: '',
          vehicleType: 'Light Truck',
          vehicleNumber: 'B 302 BNM',
          licenseNo: 'DL-BW-77312',
          ratingAvg: 4.88,
          completedOrders: 280,
          status: 'online',
          currentLat: -24.6390,
          currentLng: 25.9050,
          verificationStatus: 'approved',
        ),
      ];

  static List<PromotionModel> get mockPromotions => [
        PromotionModel(
          promoId: 'promo-1',
          code: 'GAS20',
          description: 'Save P20 on your next 9KG or 14KG cylinder delivery',
          discountType: 'fixed',
          discountValue: 20.00,
          minOrderAmount: 150.00,
          validUntil: DateTime.now().add(const Duration(days: 90)),
          isActive: true,
        ),
        PromotionModel(
          promoId: 'promo-2',
          code: 'WINTERWARM',
          description: '15% OFF home heating cylinder refills',
          discountType: 'percentage',
          discountValue: 15.00,
          minOrderAmount: 200.00,
          maxDiscountAmount: 50.00,
          validUntil: DateTime.now().add(const Duration(days: 60)),
          isActive: true,
        ),
      ];

  static List<OrderModel> get mockOrders {
    final user = mockUser;
    final address = mockAddresses[0];
    final provider = mockProviders[0];
    final depot = mockDepots[0];
    final driver = mockDrivers[0];
    final product = mockProducts[2]; // 9KG

    return [
      OrderModel(
        orderId: 'ord-101',
        humanId: 'GAS-49210',
        userId: user.userId,
        user: user,
        providerId: provider.providerId,
        provider: provider,
        addressId: address.addressId,
        address: address,
        depotId: depot.depotId,
        depot: depot,
        driverId: driver.driverId,
        driver: driver,
        orderType: 'exchange',
        status: 'out_for_delivery',
        paymentMethod: 'mobile_money',
        paymentProvider: 'Orange Money',
        paymentStatus: 'completed',
        subtotal: 320.00,
        deliveryFee: 25.00,
        discountAmount: 20.00,
        promoCode: 'GAS20',
        totalAmount: 325.00,
        etaMinutes: 18,
        otpCode: '8942',
        createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 4)),
        items: [
          OrderItemModel(
            orderItemId: 'item-101',
            orderId: 'ord-101',
            productId: product.productId,
            product: product,
            quantity: 1,
            orderType: 'exchange',
            unitPrice: 320.00,
            totalPrice: 320.00,
          ),
        ],
        statusHistory: [
          OrderStatusLogModel(
            logId: 'log-1',
            orderId: 'ord-101',
            status: 'confirmed',
            note: 'Order confirmed and payment received via Orange Money',
            timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
          ),
          OrderStatusLogModel(
            logId: 'log-2',
            orderId: 'ord-101',
            status: 'preparing',
            note: 'Depot staff inspected and loaded cylinder',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
          OrderStatusLogModel(
            logId: 'log-3',
            orderId: 'ord-101',
            status: 'out_for_delivery',
            note: 'Driver Kabo Sebego accepted and en route with B 849 AKL',
            timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
          ),
        ],
      ),
      OrderModel(
        orderId: 'ord-100',
        humanId: 'GAS-38104',
        userId: user.userId,
        user: user,
        providerId: provider.providerId,
        provider: provider,
        addressId: address.addressId,
        address: address,
        depotId: depot.depotId,
        depot: depot,
        driverId: driver.driverId,
        driver: driver,
        orderType: 'refill',
        status: 'delivered',
        paymentMethod: 'card',
        paymentProvider: 'Visa / Mastercard',
        paymentStatus: 'completed',
        subtotal: 195.00,
        deliveryFee: 25.00,
        discountAmount: 0.00,
        totalAmount: 220.00,
        etaMinutes: 0,
        otpCode: '5512',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
        items: [
          OrderItemModel(
            orderItemId: 'item-100',
            orderId: 'ord-100',
            productId: product.productId,
            product: product,
            quantity: 1,
            orderType: 'refill',
            unitPrice: 195.00,
            totalPrice: 195.00,
          ),
        ],
      ),
    ];
  }
}
