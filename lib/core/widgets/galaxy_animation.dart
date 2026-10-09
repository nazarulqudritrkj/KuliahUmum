import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GalaxyBackground  –  full-screen animated cosmos
//   • Twinkling stars (random blink)
//   • Slow-drifting nebula blobs
//   • Shooting stars on random intervals
//   • Subtle orbital ring glow
// ─────────────────────────────────────────────────────────────────────────────

class GalaxyBackground extends StatefulWidget {
  final Widget child;
  final List<Color> nebulaColors;

  const GalaxyBackground({
    super.key,
    required this.child,
    this.nebulaColors = const [
      Color(0xFF7C3AED),
      Color(0xFF4F46E5),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
    ],
  });

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _nebulaController;
  late AnimationController _shootingController;
  late AnimationController _rotationController;

  final math.Random _rng = math.Random(42);
  late List<_Star> _stars;
  late List<_ShootingStar> _shootingStars;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _shootingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _stars = List.generate(120, (_) => _Star(_rng));
    _shootingStars = List.generate(3, (i) => _ShootingStar(_rng, offset: i * 0.33));
  }

  @override
  void dispose() {
    _starController.dispose();
    _nebulaController.dispose();
    _shootingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0618),
                Color(0xFF0D0B2A),
                Color(0xFF0A0618),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([
            _starController,
            _nebulaController,
            _shootingController,
            _rotationController,
          ]),
          builder: (context, child) {
            return CustomPaint(
              painter: _GalaxyPainter(
                stars: _stars,
                shootingStars: _shootingStars,
                nebulaColors: widget.nebulaColors,
                starProgress: _starController.value,
                nebulaProgress: _nebulaController.value,
                shootingProgress: _shootingController.value,
                rotationProgress: _rotationController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _Star {
  final double x;
  final double y;
  final double radius;
  final double twinkleSpeed;
  final double brightness;
  final Color color;

  _Star(math.Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        radius = rng.nextDouble() * 1.6 + 0.4,
        twinkleSpeed = rng.nextDouble(),
        brightness = rng.nextDouble() * 0.6 + 0.4,
        color = _starColors[rng.nextInt(_starColors.length)];

  static const List<Color> _starColors = [
    Colors.white,
    Color(0xFFE0D7FF),
    Color(0xFFFFF4CC),
    Color(0xFFCCE8FF),
    Color(0xFFFFDDCC),
  ];
}

class _ShootingStar {
  final double startX;
  final double startY;
  final double angle;
  final double length;
  final double speed;
  final double delay;

  _ShootingStar(math.Random rng, {required double offset})
      : startX = rng.nextDouble() * 0.6 + 0.1,
        startY = rng.nextDouble() * 0.4,
        angle = -math.pi / 5 + rng.nextDouble() * 0.3,
        length = rng.nextDouble() * 120 + 80,
        speed = rng.nextDouble() * 0.4 + 0.6,
        delay = offset;
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

class _GalaxyPainter extends CustomPainter {
  final List<_Star> stars;
  final List<_ShootingStar> shootingStars;
  final List<Color> nebulaColors;
  final double starProgress;
  final double nebulaProgress;
  final double shootingProgress;
  final double rotationProgress;

  _GalaxyPainter({
    required this.stars,
    required this.shootingStars,
    required this.nebulaColors,
    required this.starProgress,
    required this.nebulaProgress,
    required this.shootingProgress,
    required this.rotationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawNebulas(canvas, size);
    _drawOrbitalRings(canvas, size);
    _drawStars(canvas, size);
    _drawShootingStars(canvas, size);
  }

  void _drawNebulas(Canvas canvas, Size size) {
    final centers = [
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.1, size.height * 0.78),
      Offset(size.width * 0.92, size.height * 0.15),
    ];
    final radii = [220.0, 280.0, 180.0, 160.0, 200.0];
    final drifts = [0.0, 0.2, 0.45, 0.65, 0.85];

    for (int i = 0; i < centers.length; i++) {
      final drift = math.sin((nebulaProgress + drifts[i]) * math.pi * 2) * 18;
      final center = centers[i].translate(drift, drift * 0.5);
      final color = nebulaColors[i % nebulaColors.length];
      final radius = radii[i] * (1 + math.sin(nebulaProgress * math.pi) * 0.08);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawOrbitalRings(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    final rings = <(double, double, Color)>[
      (size.width * 0.45, 0.06, const Color(0xFF7C3AED)),
      (size.width * 0.62, 0.04, const Color(0xFF4F46E5)),
      (size.width * 0.80, 0.03, const Color(0xFFF59E0B)),
    ];

    canvas.save();
    canvas.translate(cx, cy);

    for (final ring in rings) {
      canvas.rotate(rotationProgress * math.pi * 2 * 0.07);
      final paint = Paint()
        ..color = ring.$3.withValues(alpha: ring.$2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: ring.$1 * 2,
          height: ring.$1 * 0.35,
        ),
        paint,
      );
    }

    canvas.restore();
  }

  void _drawStars(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (math.sin((starProgress + star.twinkleSpeed) * math.pi * 2) + 1) / 2;
      final opacity = (star.brightness * (0.4 + twinkle * 0.6)).clamp(0.0, 1.0);
      final currentRadius = star.radius * (0.85 + twinkle * 0.3);

      final paint = Paint()
        ..color = star.color.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentRadius * 0.8);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        currentRadius,
        paint,
      );
    }
  }

  void _drawShootingStars(Canvas canvas, Size size) {
    for (final s in shootingStars) {
      double progress = (shootingProgress + s.delay) % 1.0;
      if (progress > 0.6) continue;

      final t = progress / 0.6;
      final eased = Curves.easeOut.transform(t);

      final dx = math.cos(s.angle) * s.length * eased * s.speed;
      final dy = math.sin(s.angle) * s.length * eased * s.speed;

      final tipX = s.startX * size.width + dx;
      final tipY = s.startY * size.height + dy;
      final tailX = tipX - math.cos(s.angle) * s.length * 0.35;
      final tailY = tipY - math.sin(s.angle) * s.length * 0.35;

      final fadeOut = (1.0 - t).clamp(0.0, 1.0);

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: fadeOut * 0.9),
          ],
        ).createShader(Rect.fromPoints(Offset(tailX, tailY), Offset(tipX, tipY)))
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(tailX, tailY), Offset(tipX, tipY), paint);

      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: fadeOut * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(tipX, tipY), 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_GalaxyPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// SideGalaxyPanel  –  left or right decorative galaxy panel for split layouts
// ─────────────────────────────────────────────────────────────────────────────

class SideGalaxyPanel extends StatefulWidget {
  final Widget child;
  final bool isRight;

  const SideGalaxyPanel({
    super.key,
    required this.child,
    this.isRight = false,
  });

  @override
  State<SideGalaxyPanel> createState() => _SideGalaxyPanelState();
}

class _SideGalaxyPanelState extends State<SideGalaxyPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _drift;
  late AnimationController _twinkle;
  late AnimationController _shooting;

  final _rng = math.Random(99);
  late List<_Star> _stars;
  late List<_ShootingStar> _shootingStars;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _drift = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat(reverse: true);
    _twinkle = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _shooting = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
    _stars = List.generate(80, (_) => _Star(_rng));
    _shootingStars = List.generate(2, (i) => _ShootingStar(_rng, offset: i * 0.5));
  }

  @override
  void dispose() {
    _pulse.dispose();
    _drift.dispose();
    _twinkle.dispose();
    _shooting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space gradient base
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: widget.isRight ? Alignment.topRight : Alignment.topLeft,
                end: widget.isRight ? Alignment.bottomLeft : Alignment.bottomRight,
                colors: const [
                  Color(0xFF08031A),
                  Color(0xFF0F0730),
                  Color(0xFF16084A),
                  Color(0xFF0A051E),
                ],
                stops: [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // Animated galaxy elements
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulse, _drift, _twinkle, _shooting]),
            builder: (context, child) => CustomPaint(
              painter: _GalaxyPainter(
                stars: _stars,
                shootingStars: _shootingStars,
                nebulaColors: const [
                  Color(0xFF7C3AED),
                  Color(0xFF4338CA),
                  Color(0xFFF59E0B),
                  Color(0xFF0EA5E9),
                ],
                starProgress: _twinkle.value,
                nebulaProgress: _drift.value,
                shootingProgress: _shooting.value,
                rotationProgress: _pulse.value,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Floating glowing orbs
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return Stack(
              children: [
                _buildOrb(
                  left: widget.isRight ? null : -60,
                  right: widget.isRight ? -60 : null,
                  top: -40,
                  size: 220,
                  color: const Color(0xFF7C3AED),
                  opacity: 0.18 + _pulse.value * 0.08,
                ),
                _buildOrb(
                  left: widget.isRight ? null : 20,
                  right: widget.isRight ? 20 : null,
                  bottom: 60,
                  size: 180,
                  color: const Color(0xFFF59E0B),
                  opacity: 0.10 + _pulse.value * 0.06,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment(widget.isRight ? 0.3 : -0.3, -0.1),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF06B6D4).withValues(alpha: 0.10 + _pulse.value * 0.04),
                            const Color(0xFF06B6D4).withValues(alpha: 0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.08 + _pulse.value * 0.04),
                            blurRadius: 80,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Foreground content
        widget.child,
      ],
    );
  }

  Widget _buildOrb({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity * 1.2),
              color.withValues(alpha: opacity * 0.4),
              color.withValues(alpha: 0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity),
              blurRadius: size * 0.8,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
