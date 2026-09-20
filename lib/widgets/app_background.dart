import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.background,
                AppColors.backgroundDeep,
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: _GeometryPainter(),
            size: Size.infinite,
          ),
        ),
        child,
      ],
    );
  }
}

class _GeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final shapes = [
      Path()
        ..moveTo(size.width * .62, 0)
        ..lineTo(size.width, size.height * .08)
        ..lineTo(size.width * .78, size.height * .28)
        ..lineTo(size.width * .46, size.height * .17)
        ..close(),
      Path()
        ..moveTo(0, size.height * .20)
        ..lineTo(size.width * .30, size.height * .08)
        ..lineTo(size.width * .46, size.height * .26)
        ..lineTo(size.width * .18, size.height * .38)
        ..close(),
      Path()
        ..moveTo(size.width * .40, size.height * .43)
        ..lineTo(size.width * .76, size.height * .30)
        ..lineTo(size.width, size.height * .48)
        ..lineTo(size.width * .66, size.height * .64)
        ..close(),
      Path()
        ..moveTo(size.width * .08, size.height * .66)
        ..lineTo(size.width * .37, size.height * .55)
        ..lineTo(size.width * .55, size.height * .78)
        ..lineTo(size.width * .16, size.height * .88)
        ..close(),
    ];

    for (var i = 0; i < shapes.length; i++) {
      paint.color = Colors.white.withOpacity(i.isEven ? .025 : .018);
      canvas.drawPath(shapes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
