import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/provider_model.dart';
import '../../providers/app_state_provider.dart';
import 'cylinder_selection_screen.dart';

class NearbySuppliersScreen extends StatefulWidget {
  final bool showBackButton;

  const NearbySuppliersScreen({super.key, this.showBackButton = true});

  @override
  State<NearbySuppliersScreen> createState() => _NearbySuppliersScreenState();
}

class _NearbySuppliersScreenState extends State<NearbySuppliersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Filter providers based on search query
    final providers = state.providers.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Text(
          'Nearby Suppliers',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search for gas suppliers...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  suffixIcon: Icon(Icons.tune, color: AppColors.textPrimary, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Map Preview ───────────────────────────────────────────────────
          Container(
            height: 190,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Stylized Map Canvas
                  CustomPaint(
                    size: const Size(double.infinity, 190),
                    painter: _MockMapPainter(),
                  ),

                  // Floating Locate Me Button
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Suppliers List ────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: providers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final provider = providers[index];
                return _buildSupplierCard(context, provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, GasProviderModel provider) {
    // Generate simulated distance based on index
    final distances = ['1.2 km', '2.4 km', '3.1 km', '4.5 km'];
    final distance = distances[provider.hashCode.abs() % distances.length];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gas Cylinder Thumbnail
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/images/cylinder.jpg',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          // Supplier Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        provider.companyName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.statusOpenBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Open',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.statusOpen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.starRating, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      '${provider.rating} (${provider.reviewCount})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '  •  $distance',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  provider.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Outlined View Button
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: () {
                final state = Provider.of<AppStateProvider>(context, listen: false);
                state.setSelectedProvider(provider.providerId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CylinderSelectionScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws a clean road map background with user and supplier markers
class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background terrain
    final bgPaint = Paint()..color = const Color(0xFFF2F4F7);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Blocks / Parcels
    final blockPaint = Paint()..color = const Color(0xFFE9EDF3);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(20, 20, 80, 50), const Radius.circular(4)),
        blockPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(120, 20, 100, 60), const Radius.circular(4)),
        blockPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(20, 90, 90, 70), const Radius.circular(4)),
        blockPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(240, 10, 110, 80), const Radius.circular(4)),
        blockPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(130, 100, 140, 70), const Radius.circular(4)),
        blockPaint);

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final roadPath = Path();
    roadPath.moveTo(0, 80);
    roadPath.lineTo(size.width, 80);
    roadPath.moveTo(110, 0);
    roadPath.lineTo(110, size.height);
    roadPath.moveTo(230, 0);
    roadPath.lineTo(230, size.height);
    roadPath.moveTo(0, 150);
    roadPath.lineTo(size.width, 150);
    canvas.drawPath(roadPath, roadPaint);

    // User Location (Pulse & Dot)
    final userPulsePaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final userRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final userDotPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;

    final userCenter = Offset(size.width * 0.52, size.height * 0.45);
    canvas.drawCircle(userCenter, 18, userPulsePaint);
    canvas.drawCircle(userCenter, 8, userRingPaint);
    canvas.drawCircle(userCenter, 5, userDotPaint);

    // Supplier Red Pins
    _drawPin(canvas, Offset(size.width * 0.22, size.height * 0.40));
    _drawPin(canvas, Offset(size.width * 0.32, size.height * 0.65));
    _drawPin(canvas, Offset(size.width * 0.78, size.height * 0.35));
    _drawPin(canvas, Offset(size.width * 0.65, size.height * 0.28));
  }

  void _drawPin(Canvas canvas, Offset offset) {
    final pinPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    final whiteDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offset, 6.5, pinPaint);
    canvas.drawCircle(offset, 2.5, whiteDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
