import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedNavItem {
  final IconData icon;
  final String label;

  const AnimatedNavItem({
    required this.icon,
    required this.label,
  });
}

class AnimatedPillNavBar extends StatelessWidget {
  final int currentIndex;
  final List<AnimatedNavItem> items;
  final ValueChanged<int> onTap;

  const AnimatedPillNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navHeight = 56.0;
    const activeCircleSize = 50.0;
    const popOffset = 18.0; // How far the active button pops above the top bar edge

    final bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom
        : 12.0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding,
        top: 8,
      ),
      color: Colors.transparent,
      child: SizedBox(
        height: navHeight + popOffset,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final itemWidth = totalWidth / items.length;
            final targetX = (currentIndex * itemWidth) + (itemWidth / 2);

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: targetX, end: targetX),
              duration: const Duration(milliseconds: 320),
              curve: Curves.fastOutSlowIn,
              builder: (context, animatedX, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Notched Pill Custom Background Bar
                    Positioned(
                      top: popOffset,
                      left: 0,
                      right: 0,
                      height: navHeight,
                      child: CustomPaint(
                        painter: NotchedPillPainter(
                          activeX: animatedX,
                          backgroundColor: const Color(0xFF0F172A), // Dark slate surface
                          borderColor: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),

                    // 2. Popping Floating Circular Active Button
                    Positioned(
                      top: popOffset - 14.0, // Floating above the notched dip
                      left: animatedX - (activeCircleSize / 2),
                      child: GestureDetector(
                        onTap: () => onTap(currentIndex),
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: activeCircleSize,
                            height: activeCircleSize,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.accent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.5),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              items[currentIndex].icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Interactive Inactive Items Row
                    Positioned(
                      top: popOffset,
                      left: 0,
                      right: 0,
                      height: navHeight,
                      child: Row(
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          final isSelected = index == currentIndex;

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(index),
                              child: Center(
                                child: Opacity(
                                  opacity: isSelected ? 0.0 : 1.0, // Active icon is shown inside popping circle
                                  child: Icon(
                                    item.icon,
                                    color: AppTheme.textMuted.withValues(alpha: 0.85),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NotchedPillPainter extends CustomPainter {
  final double activeX;
  final Color backgroundColor;
  final Color borderColor;

  NotchedPillPainter({
    required this.activeX,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final radius = size.height / 2;
    const notchWidth = 60.0;
    const notchDepth = 14.0;

    final notchLeft = (activeX - notchWidth / 2).clamp(radius, size.width - radius - notchWidth);
    final notchRight = notchLeft + notchWidth;
    final notchCenter = (notchLeft + notchRight) / 2;

    final path = Path();

    // Start at top-left corner
    path.moveTo(radius, 0);

    // Line to notch start
    path.lineTo(notchLeft, 0);

    // Smooth concave notch curve down and back up
    path.cubicTo(
      notchLeft + 10, 0,
      notchCenter - 14, notchDepth,
      notchCenter, notchDepth,
    );
    path.cubicTo(
      notchCenter + 14, notchDepth,
      notchRight - 10, 0,
      notchRight, 0,
    );

    // Line to top-right corner
    path.lineTo(size.width - radius, 0);

    // Top-right corner arc
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Right side down
    path.lineTo(size.width, size.height - radius);

    // Bottom-right corner arc
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Bottom edge
    path.lineTo(radius, size.height);

    // Bottom-left corner arc
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Left side up
    path.lineTo(0, radius);

    // Top-left corner arc
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.close();

    // Draw background drop shadow
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.5),
      10.0,
      true,
    );

    // Fill path
    canvas.drawPath(path, fillPaint);

    // Draw border line
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant NotchedPillPainter oldDelegate) {
    return oldDelegate.activeX != activeX ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
  }
}
