import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/cyberpunk_theme.dart';

class CyberpunkCharacter extends StatefulWidget {
  final double size;
  final bool isAnimated;
  final String? animationType;
  final VoidCallback? onTap;

  const CyberpunkCharacter({
    super.key,
    this.size = 120,
    this.isAnimated = true,
    this.animationType,
    this.onTap,
  });

  @override
  State<CyberpunkCharacter> createState() => _CyberpunkCharacterState();
}

class _CyberpunkCharacterState extends State<CyberpunkCharacter>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _eyeController;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _eyeAnimation;

  @override
  void initState() {
    super.initState();

    // Glow animation for the character
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Eye glow animation
    _eyeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _eyeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    _eyeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimated) {
      return _buildCharacter();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowController,
        _floatController,
        _eyeController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: FadeTransition(
            opacity: _glowAnimation,
            child: _buildCharacter(),
          ),
        );
      },
    );
  }

  Widget _buildCharacter() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: CyberpunkTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: CyberpunkTheme.primaryNeon.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: CyberpunkTheme.secondaryNeon.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: widget.size * 0.9,
              height: widget.size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CyberpunkTheme.primaryNeon.withOpacity(0.8),
                  width: 2,
                ),
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    CyberpunkTheme.primaryNeon.withOpacity(0.2),
                  ],
                ),
              ),
            ),

            // Inner core
            Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CyberpunkTheme.darkBackground,
                border: Border.all(
                  color: CyberpunkTheme.primaryNeon,
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circuit pattern background
                  CustomPaint(
                    size: Size(widget.size * 0.7, widget.size * 0.7),
                    painter: CircuitPainter(),
                  ),

                  // Eyes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEye(),
                      SizedBox(width: widget.size * 0.08),
                      _buildEye(),
                    ],
                  ),

                  // Mouth/vent
                  Positioned(
                    bottom: widget.size * 0.15,
                    child: Container(
                      width: 30,
                      height: 2,
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.primaryNeon,
                        borderRadius: BorderRadius.circular(1),
                        boxShadow: [
                          BoxShadow(
                            color: CyberpunkTheme.primaryNeon,
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rotating ring
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _glowController.value * 2 * 3.14159,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CyberpunkTheme.secondaryNeon.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEye() {
    return AnimatedBuilder(
      animation: _eyeAnimation,
      builder: (context, child) {
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CyberpunkTheme.darkBackground,
            border: Border.all(color: CyberpunkTheme.primaryNeon, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: CyberpunkTheme.primaryNeon.withOpacity(
                  _eyeAnimation.value,
                ),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberpunkTheme.primaryNeon.withOpacity(
                _eyeAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberpunkTheme.primaryNeon.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw circuit-like patterns
    final path = Path();

    // Top horizontal line
    path.moveTo(size.width * 0.2, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.2);

    // Right vertical line
    path.moveTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.5);

    // Bottom horizontal line
    path.moveTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width * 0.3, size.height * 0.5);

    // Left vertical line
    path.moveTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.3, size.height * 0.8);

    // Connection dots
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      2,
      Paint()..color = CyberpunkTheme.primaryNeon.withOpacity(0.6),
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      2,
      Paint()..color = CyberpunkTheme.primaryNeon.withOpacity(0.6),
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.5),
      2,
      Paint()..color = CyberpunkTheme.primaryNeon.withOpacity(0.6),
    );

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      2,
      Paint()..color = CyberpunkTheme.primaryNeon.withOpacity(0.6),
    );

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.8),
      2,
      Paint()..color = CyberpunkTheme.primaryNeon.withOpacity(0.6),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Loading character for loading screens
class LoadingCyberpunkCharacter extends StatelessWidget {
  final double size;
  final String message;

  const LoadingCyberpunkCharacter({
    super.key,
    this.size = 100,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CyberpunkCharacter(size: size, isAnimated: true),
        const SizedBox(height: 20),
        FadeIn(
          child: Text(
            message,
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 16,
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FadeIn(
          delay: const Duration(milliseconds: 500),
          child: SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: CyberpunkTheme.darkSurface,
              valueColor: AlwaysStoppedAnimation<Color>(
                CyberpunkTheme.primaryNeon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Error state character
class ErrorCyberpunkCharacter extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCyberpunkCharacter({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CyberpunkCharacter(size: 80, isAnimated: false),
        const SizedBox(height: 20),
        Text(
          'ERROR',
          style: TextStyle(
            color: CyberpunkTheme.errorNeon,
            fontSize: 24,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: CyberpunkTheme.errorNeon, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: TextStyle(
            color: CyberpunkTheme.textSecondary,
            fontSize: 14,
            fontFamily: 'Rajdhani',
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberpunkTheme.errorNeon,
              foregroundColor: CyberpunkTheme.darkBackground,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ],
    );
  }
}
