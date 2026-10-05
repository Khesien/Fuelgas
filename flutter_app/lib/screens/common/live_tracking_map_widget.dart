import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/address_model.dart';
import '../../models/depot_model.dart';
import '../../models/driver_model.dart';

class LiveTrackingMapWidget extends StatefulWidget {
  final DriverModel? driver;
  final AddressModel? address;
  final DepotModel? depot;
  final String status;
  final int etaMinutes;
  final double height;

  const LiveTrackingMapWidget({
    super.key,
    this.driver,
    this.address,
    this.depot,
    required this.status,
    this.etaMinutes = 25,
    this.height = 240,
  });

  @override
  State<LiveTrackingMapWidget> createState() => _LiveTrackingMapWidgetState();
}

class _LiveTrackingMapWidgetState extends State<LiveTrackingMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Custom Painted Grid & Route Map
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(double.infinity, widget.height),
                  painter: _MapCanvasPainter(
                    pulseValue: _pulseController.value,
                    status: widget.status,
                  ),
                );
              },
            ),

            // Top Status & ETA Pill
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.navigation,
                        color: AppColors.brandOrange, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      widget.status == 'delivered'
                          ? 'DELIVERED SAFELY'
                          : 'ETA: ~${widget.etaMinutes} MINS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Depot Location Pin (Top-Left)
            Positioned(
              top: widget.height * 0.22,
              left: 36,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.storefront,
                        color: Colors.white, size: 14),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black89,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.depot?.name.split(' ').first ?? 'Depot',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Customer Destination Pin (Bottom-Right)
            Positioned(
              bottom: widget.height * 0.16,
              right: 36,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.home, color: Colors.white, size: 14),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black89,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.address?.label ?? 'Delivery',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Moving Driver Vehicle Pin
            if (widget.status == 'out_for_delivery' ||
                widget.status == 'preparing')
              Positioned(
                top: widget.height * 0.45,
                left: 140,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandOrange.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.local_shipping,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrangeDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.driver?.fullName.split(' ').first ?? 'Driver',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Live GPS indicator tag at bottom
            Positioned(
              bottom: 10,
              left: 14,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Real-time GPS Tracking Active',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  final double pulseValue;
  final String status;

  _MapCanvasPainter({required this.pulseValue, required this.status});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle street grid lines
    final gridPaint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 35) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw curved road line from Depot to Customer
    final roadPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final p0 = Offset(52, size.height * 0.28);
    final p1 = Offset(size.width * 0.45, size.height * 0.45);
    final p2 = Offset(size.width - 56, size.height * 0.72);

    path.moveTo(p0.dx, p0.dy);
    path.quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);
    canvas.drawPath(path, roadPaint);

    // 3. Highlighted active route line
    final activePaint = Paint()
      ..color = AppColors.brandOrange.withOpacity(0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, activePaint);

    // 4. Driver pulsing ring
    if (status == 'out_for_delivery') {
      final pulsePaint = Paint()
        ..color = AppColors.brandOrange.withOpacity((1.0 - pulseValue) * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(156, size.height * 0.52),
        16 + (pulseValue * 14),
        pulsePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.status != status;
  }
}
