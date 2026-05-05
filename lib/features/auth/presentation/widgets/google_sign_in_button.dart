import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A styled "Continue with Google" button that follows Google's branding
/// guidelines: white background in light mode, dark surface in dark mode,
/// with the Google-coloured logo icon and prominent label.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final fgColor = isDark ? Colors.white : const Color(0xFF1F1F1F);
    final borderColor =
        isDark ? const Color(0xFF5F5F5F) : const Color(0xFFDADCE0);

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleLogo(size: 20.w),
                  SizedBox(width: 12.w),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: fgColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Renders the four-colour Google "G" logo using a custom painter so there
/// is no dependency on an SVG asset.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Draw the four coloured arcs that make up the "G" ring.
    const sweeps = [
      // (startAngle in degrees, sweepAngle in degrees, color)
      (-30.0, 120.0, Color(0xFF4285F4)), // blue  – top-right
      (90.0, 90.0, Color(0xFF34A853)),   // green – bottom-right
      (180.0, 90.0, Color(0xFFFBBC05)),  // yellow – bottom-left
      (270.0, 60.0, Color(0xFFEA4335)), // red   – top-left
    ];

    const deg = 3.14159265358979 / 180.0;
    final strokeWidth = size.width * 0.22;
    final arcR = r - strokeWidth / 2;
    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: arcR,
    );

    for (final s in sweeps) {
      final paint = Paint()
        ..color = s.$3
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, s.$1 * deg, s.$2 * deg, false, paint);
    }

    // Draw the horizontal bar of the "G".
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barLeft = cx;
    final barRight = cx + arcR + strokeWidth / 2;
    final barTop = cy - strokeWidth / 2;
    final barBottom = cy + strokeWidth / 2;
    canvas.drawRect(
      Rect.fromLTRB(barLeft, barTop, barRight, barBottom),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
