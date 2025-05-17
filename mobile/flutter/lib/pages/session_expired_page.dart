import 'package:flutter/material.dart';
import 'dart:math' as math;

class SessionExpiredScreen extends StatefulWidget {
  final String title;
  final String message;
  const SessionExpiredScreen(
      {Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  State<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends State<SessionExpiredScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    // Add repeating animation for the floating effect
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _controller.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The animated wave background
          const SizedBox.expand(
            child: WaveBackground(
              colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
            ),
          ),
          // Background particles
          LayoutBuilder(
            builder: (context, constraints) {
              return BackgroundParticles(
                size: Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
          ),
          // Your existing UI
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth > 800;
              return _buildResponsiveLayout(isDesktop, constraints);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveLayout(bool isDesktop, BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);

    return SafeArea(
      child: isDesktop ? _buildDesktopLayout(size) : _buildMobileLayout(size),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    final logoSize = math.min(size.width * 0.25, 280.0);

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: _buildLogo(Size(logoSize, logoSize)),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSessionExpiredText(isDesktop: true),
                const SizedBox(height: 30),
                _buildMessageText(isDesktop: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size) {
    final logoSize = math.min(size.width * 0.5, 200.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Center(
          child: _buildLogo(Size(logoSize, logoSize)),
        ),
        const Spacer(flex: 1),
        _buildSessionExpiredText(),
        const SizedBox(height: 30),
        _buildMessageText(),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildLogo(Size logoArea) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, -4 * math.sin(_floatAnimation.value * math.pi)),
              child: Container(
                width: logoArea.width,
                height: logoArea.width,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  // Using a placeholder icon since the provided image URL doesn't work
                  child: Image.network(
                    'https://i.ibb.co/hx562zq3/Logo-Admin-Panel-Equa-Bin-Quarista.png',
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                          'assets/images/Logo - Admin Panel - III@4x.png'
                          );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      return Image.asset(
                          'assets/images/Logo - Admin Panel - III@4x.png'
                          );
                    },
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      return Image.asset(
                          'assets/images/Logo - Admin Panel - III@4x.png'
                          );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionExpiredText({bool isDesktop = false}) {
    final TextStyle textStyle = TextStyle(
      fontSize: isDesktop ? 42 : 28,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF263238),
      letterSpacing: 0.5,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
            child: Text(
              widget.title,
              style: textStyle,
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageText({bool isDesktop = false}) {
    final TextStyle textStyle = TextStyle(
      fontSize: isDesktop ? 18 : 16,
      color: const Color(0xFF546E7A),
      height: 1.5,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _fadeAnimation.value)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 40),
              child: Text(
                widget.message,
                textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                style: textStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ENHANCED WAVE BACKGROUND CLASS
class WaveBackground extends StatefulWidget {
  final List<Color> colors;

  const WaveBackground({
    Key? key,
    this.colors = const [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
  }) : super(key: key);

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            animation: _controller,
            colors: widget.colors,
          ),
          child: child,
        );
      },
      child: Container(),
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  WavePainter({
    required this.animation,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background
    final Rect rect = Offset.zero & size;
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
    final Paint backgroundPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    // Wave parameters
    final double width = size.width;
    final double height = size.height;

    // Draw first wave (subtle background)
    final path1 = Path();
    final Paint paint1 = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    path1.moveTo(0, height * 0.8);

    for (double i = 0; i <= width; i++) {
      final double x = i;
      final double y = height * 0.8 +
          math.sin((i / width * 4) + (animation.value * 2 * math.pi)) * 20 +
          math.sin((i / width * 2) + (animation.value * math.pi)) * 15;
      path1.lineTo(x, y);
    }

    path1.lineTo(width, height);
    path1.lineTo(0, height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Draw second wave (more visible)
    final path2 = Path();
    final Paint paint2 = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    path2.moveTo(0, height * 0.85);

    for (double i = 0; i <= width; i++) {
      final double x = i;
      final double y = height * 0.85 +
          math.sin((i / width * 3) + (animation.value * 2 * math.pi)) * 15 +
          math.cos((i / width * 5) + (animation.value * math.pi * 1.5)) * 10;
      path2.lineTo(x, y);
    }

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // NEW: Draw third wave (top wave with light blue tint)
    final path3 = Path();
    final Paint paint3 = Paint()
      ..color = const Color(0xFFE1F5FE).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    path3.moveTo(0, height * 0.7);

    for (double i = 0; i <= width; i++) {
      final double x = i;
      final double y = height * 0.7 +
          math.sin((i / width * 2) + (animation.value * math.pi * 0.8)) * 25 +
          math.cos((i / width * 4) + (animation.value * math.pi * 1.2)) * 12;
      path3.lineTo(x, y);
    }

    path3.lineTo(width, height);
    path3.lineTo(0, height);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}

// UPDATED BACKGROUND PARTICLES CLASS WITH LIGHT BLUE COLORS
class BackgroundParticles extends StatefulWidget {
  final Size size;

  const BackgroundParticles({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<BackgroundParticles> createState() => _BackgroundParticlesState();
}

class _BackgroundParticlesState extends State<BackgroundParticles>
    with TickerProviderStateMixin {
  final List<ParticleModel> particles = [];
  late AnimationController _controller;

  // Light blue colors matching the image
  final List<Color> particleColors = [
    const Color(0xFFE3F2FD).withOpacity(0.15),
    const Color(0xFFBBDEFB).withOpacity(0.15),
    const Color(0xFFCFD8DC).withOpacity(0.15),
    const Color(0xFFECEFF1).withOpacity(0.15),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Create more floating particles with light blue colors
    for (int i = 0; i < 20; i++) {
      particles.add(ParticleModel(
        x: math.Random().nextDouble() * widget.size.width,
        y: math.Random().nextDouble() * widget.size.height,
        size: 3 + math.Random().nextDouble() * 5,
        color: particleColors[math.Random().nextInt(particleColors.length)],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              particles: particles,
              animation: _controller,
            ),
          );
        },
      ),
    );
  }
}

class ParticleModel {
  double x;
  double y;
  double size;
  Color color;

  ParticleModel({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final Animation<double> animation;

  ParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final offset = Offset(
        particle.x +
            (5 * math.sin((animation.value * math.pi * 2) + particle.y * 0.1)),
        particle.y +
            (8 * math.sin((animation.value * math.pi * 2) + particle.x * 0.1)),
      );

      canvas.drawCircle(offset, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
