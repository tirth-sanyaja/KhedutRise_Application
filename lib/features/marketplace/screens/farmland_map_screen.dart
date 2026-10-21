import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';

class FarmlandMapScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const FarmlandMapScreen({super.key, this.onSwitchTab});

  @override
  State<FarmlandMapScreen> createState() => _FarmlandMapScreenState();
}

class _FarmlandMapScreenState extends State<FarmlandMapScreen> {
  int _selectedPin = 1; // 0, 1, or 2

  final List<Map<String, dynamic>> _farmlands = [
    {
      'title': 'Kisan Krishi Farm',
      'location': 'Gondal, Rajkot | 4.2 Acres',
      'specs': 'Soil: Red Loam | Water: Canal',
      'price': '₹28,50,000',
      'shortPrice': '₹28.5L',
      'pos': const Offset(80, 150),
    },
    {
      'title': 'Green Farm Land - Sardhar',
      'location': 'Sardhar, Rajkot | 5 Acres',
      'specs': 'Soil: Black | Water: Borewell',
      'price': '₹32,00,000',
      'shortPrice': '₹32L',
      'pos': const Offset(205, 380),
    },
    {
      'title': 'Somnath Agro Land',
      'location': 'Kotda, Rajkot | 6 Acres',
      'specs': 'Soil: Black Cotton | Water: Well',
      'price': '₹39,00,000',
      'shortPrice': '₹39L',
      'pos': const Offset(310, 640),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedLand = _farmlands[_selectedPin];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F3E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              widget.onSwitchTab?.call(3);
            }
          },
        ),
        title: Text(
          'Farmland Maps',
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Farmland Map Background Grid
          Positioned.fill(child: CustomPaint(painter: _FarmlandGridPainter())),

          // Map Pins
          for (int i = 0; i < _farmlands.length; i++) ...[_buildPin(i)],

          // Floating Detail Card at Bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/land-detail');
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.borderLight, width: 1.2),
                ),
                child: Row(
                  children: [
                    // Land Parcel Graphic Box
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F3E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(44, 44),
                          painter: _LandParcelIconPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedLand['title'] as String,
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            selectedLand['location'] as String,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedLand['specs'] as String,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedLand['price'] as String,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/land-detail');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF277E33),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'View details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (widget.onSwitchTab != null) {
            widget.onSwitchTab!(index);
          } else {
            Navigator.of(context).pushReplacementNamed('/main');
          }
        },
      ),
    );
  }

  Widget _buildPin(int index) {
    final land = _farmlands[index];
    final Offset pos = land['pos'] as Offset;
    final isSelected = _selectedPin == index;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPin = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.location_on,
                size: isSelected ? 42 : 34,
                color: isSelected
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF2E7D32),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  "${land['title'].toString().split(' - ').first} (${land['shortPrice']})",
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FarmlandGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE5EFE3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final parcelPaint1 = Paint()..color = const Color(0xFFE2EFE0);
    final parcelPaint2 = Paint()..color = const Color(0xFFDCEAD9);
    final parcelPaint3 = Paint()..color = const Color(0xFFD5E6D2);

    final parcels = [
      Rect.fromLTWH(0, 0, size.width * 0.32, size.height * 0.22),
      Rect.fromLTWH(
        size.width * 0.35,
        0,
        size.width * 0.33,
        size.height * 0.22,
      ),
      Rect.fromLTWH(
        size.width * 0.70,
        0,
        size.width * 0.30,
        size.height * 0.22,
      ),
      Rect.fromLTWH(
        0,
        size.height * 0.24,
        size.width * 0.32,
        size.height * 0.28,
      ),
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.24,
        size.width * 0.33,
        size.height * 0.40,
      ),
      Rect.fromLTWH(
        size.width * 0.70,
        size.height * 0.24,
        size.width * 0.30,
        size.height * 0.36,
      ),
      Rect.fromLTWH(
        0,
        size.height * 0.54,
        size.width * 0.32,
        size.height * 0.32,
      ),
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.66,
        size.width * 0.33,
        size.height * 0.26,
      ),
      Rect.fromLTWH(
        size.width * 0.70,
        size.height * 0.62,
        size.width * 0.30,
        size.height * 0.30,
      ),
    ];

    for (int i = 0; i < parcels.length; i++) {
      final paint = (i % 3 == 0)
          ? parcelPaint1
          : (i % 3 == 1 ? parcelPaint2 : parcelPaint3);
      canvas.drawRect(parcels[i], paint);
    }

    // Grid white road lines
    canvas.drawLine(
      Offset(size.width * 0.335, 0),
      Offset(size.width * 0.335, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.685, 0),
      Offset(size.width * 0.685, size.height),
      roadPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.23),
      Offset(size.width, size.height * 0.23),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.53),
      Offset(size.width * 0.35, size.height * 0.53),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.685, size.height * 0.61),
      Offset(size.width, size.height * 0.61),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.335, size.height * 0.65),
      Offset(size.width, size.height * 0.65),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LandParcelIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFC8E6C9)
      ..style = PaintingStyle.fill;

    // Isometric parcel diamond
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.48);
    path.lineTo(size.width * 0.85, size.height * 0.66);
    path.lineTo(size.width * 0.5, size.height * 0.84);
    path.lineTo(size.width * 0.15, size.height * 0.66);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Flag pole
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.64),
      Offset(size.width * 0.5, size.height * 0.20),
      strokePaint,
    );

    // Flag pennant
    final flag = Path();
    flag.moveTo(size.width * 0.5, size.height * 0.20);
    flag.lineTo(size.width * 0.76, size.height * 0.30);
    flag.lineTo(size.width * 0.5, size.height * 0.40);
    flag.close();
    canvas.drawPath(flag, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
