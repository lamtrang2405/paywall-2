import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  int _selectedPlan = 1;

  late final AnimationController _pulse;
  late final AnimationController _entry;
  late final AnimationController _shimmer;
  late final AnimationController _wave;

  static const _crimson = Color(0xFFE63E6D);
  static const _violet = Color(0xFF7C3AED);
  static const _amber = Color(0xFFF59E0B);

  final _covers = [
    'assets/images/thumb2.png',
    'assets/images/thumb5.png',
    'assets/images/thumb4.png',
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _entry = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward();
    _shimmer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat();
    _wave = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _entry.dispose();
    _shimmer.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bot = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF07070C),
        body: Stack(
          children: [
            _ambientGlow(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _topBar(),
                    Expanded(child: _heroVisual()),
                    _headline(),
                    const SizedBox(height: 14),
                    _plans(),
                    const SizedBox(height: 14),
                    _ctaButton(),
                    const SizedBox(height: 6),
                    _footerInfo(),
                    SizedBox(height: bot > 0 ? 2 : 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ambient Background Glow ───────────────────────────────
  Widget _ambientGlow() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final v = _pulse.value;
        return Stack(
          children: [
            Positioned(
              top: -80 + v * 20,
              left: -100,
              child: _glowOrb(320, _crimson, 0.08 + v * 0.04),
            ),
            Positioned(
              top: 100,
              right: -110 + v * 15,
              child: _glowOrb(280, _violet, 0.06 + v * 0.03),
            ),
            Positioned(
              bottom: -60,
              left: 40,
              child: _glowOrb(200, _crimson, 0.04 + v * 0.02),
            ),
          ],
        );
      },
    );
  }

  Widget _glowOrb(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: alpha),
          Colors.transparent,
        ]),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_closeBtn(), _offerBadge()],
      ),
    );
  }

  Widget _closeBtn() => GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.close_rounded,
              color: Colors.white54, size: 17),
        ),
      );

  Widget _offerBadge() => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.elasticOut,
        builder: (_, v, c) => Transform.scale(scale: v, child: c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: [
              _amber.withValues(alpha: 0.15),
              _crimson.withValues(alpha: 0.1),
            ]),
            border: Border.all(color: _amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: _amber, size: 12),
              const SizedBox(width: 3),
              Text(
                '50% OFF',
                style: TextStyle(
                  color: _amber,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Hero Visual (ENLARGED) ────────────────────────────────
  Widget _heroVisual() {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final bigD = w * 0.38;
        final smallD = w * 0.25;
        final spread = w * 0.27;

        return AnimatedBuilder(
          animation: Listenable.merge([_pulse, _entry, _wave]),
          builder: (context, _) {
            final entryV = CurvedAnimation(
              parent: _entry,
              curve: Curves.easeOutCubic,
            ).value;
            final b = _pulse.value;

            return Opacity(
              opacity: entryV.clamp(0.0, 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: bigD + 32,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        _glowOrb(bigD * 3, _crimson, 0.07 + b * 0.05),
                        // Outer ring
                        Transform.scale(
                          scale: 1.0 + math.sin(b * math.pi * 2) * 0.025,
                          child: Container(
                            width: bigD + 40,
                            height: bigD + 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _crimson.withValues(
                                    alpha: 0.06 + b * 0.06),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        // Left cover
                        Transform.translate(
                          offset: Offset(
                            -spread - bigD * 0.08 + (1 - entryV) * -50,
                            8 + math.sin(b * math.pi * 2 + 1.2) * 4,
                          ),
                          child:
                              _coverCircle(_covers[0], smallD, dimmed: true),
                        ),
                        // Right cover
                        Transform.translate(
                          offset: Offset(
                            spread + bigD * 0.08 + (1 - entryV) * 50,
                            8 + math.sin(b * math.pi * 2 + 2.4) * 4,
                          ),
                          child:
                              _coverCircle(_covers[2], smallD, dimmed: true),
                        ),
                        // Inner pulsing ring
                        Transform.scale(
                          scale: 1.0 + math.sin(b * math.pi * 2) * 0.04,
                          child: Container(
                            width: bigD + 20,
                            height: bigD + 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _crimson.withValues(
                                    alpha: 0.12 + b * 0.2),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        // Center cover (hero)
                        Transform.translate(
                          offset:
                              Offset(0, math.sin(b * math.pi * 2) * 3),
                          child: _coverCircle(_covers[1], bigD,
                              isCenter: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: w * 0.75,
                    height: 28,
                    child: CustomPaint(
                      painter: _WaveformPainter(
                        progress: _wave.value,
                        color1: _crimson,
                        color2: _violet,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _coverCircle(String asset, double size,
      {bool dimmed = false, bool isCenter = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isCenter)
            BoxShadow(
              color: _crimson.withValues(alpha: 0.3),
              blurRadius: 36,
              spreadRadius: -4,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCenter
              ? _crimson.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: isCenter ? 2.5 : 1,
        ),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(asset, fit: BoxFit.cover),
            if (dimmed)
              Container(color: Colors.black.withValues(alpha: 0.4)),
            if (dimmed)
              Center(
                child: Icon(Icons.lock_rounded,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: size * 0.24),
              ),
            if (isCenter) _centerPlayBtn(size),
          ],
        ),
      ),
    );
  }

  Widget _centerPlayBtn(double parentSize) {
    final s = parentSize * 0.32;
    return Align(
      alignment: const Alignment(0, 0.72),
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [_crimson, _violet]),
          boxShadow: [
            BoxShadow(
                color: _crimson.withValues(alpha: 0.55), blurRadius: 12),
          ],
        ),
        child: Icon(Icons.play_arrow_rounded,
            color: Colors.white, size: s * 0.6),
      ),
    );
  }

  // ── Headline (redesigned: compact, integrated with features) ──
  Widget _headline() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOut,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 14 * (1 - v)), child: c),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFE8A0BE)],
            ).createShader(bounds),
            child: const Text(
              'Unlock Every Whisper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Inline feature chips + social proof combined
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(Icons.all_inclusive_rounded, 'Unlimited'),
              _chip(Icons.headphones_rounded, 'HD Audio'),
              _chip(Icons.download_rounded, 'Offline'),
              _chip(Icons.auto_awesome_rounded, 'Daily New'),
              _ratingChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _crimson, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _ratingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _amber.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: _amber, size: 12),
          const SizedBox(width: 3),
          Text('4.9',
              style: TextStyle(
                color: _amber,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(width: 4),
          Text('2M+',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10.5,
              )),
        ],
      ),
    );
  }

  // ── Plans (side-by-side cards) ─────────────────────────────
  Widget _plans() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1050),
      curve: Curves.easeOut,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 12 * (1 - v)), child: c),
      ),
      child: Row(
        children: [
          _planCard(
            index: 0,
            period: 'Weekly',
            price: '\$6.99',
            perUnit: '/week',
            detail: 'No commitment',
          ),
          const SizedBox(width: 10),
          _planCard(
            index: 1,
            period: 'Annual',
            price: '\$39.99',
            perUnit: '/year',
            detail: '\$0.76/week',
            badge: 'BEST VALUE',
            trialText: '7-day free trial',
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required int index,
    required String period,
    required String price,
    required String perUnit,
    required String detail,
    String? badge,
    String? trialText,
  }) {
    final sel = _selectedPlan == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlan = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          decoration: BoxDecoration(
            gradient: sel
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                        _crimson.withValues(alpha: 0.12),
                        _violet.withValues(alpha: 0.06),
                      ])
                : null,
            color: sel ? null : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel
                  ? _crimson.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.06),
              width: sel ? 1.5 : 1,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                        color: _crimson.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: -4)
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Radio indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: sel
                              ? const LinearGradient(
                                  colors: [_crimson, _violet])
                              : null,
                          border: sel
                              ? null
                              : Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                  width: 1.5),
                        ),
                        child: sel
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 10)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(period,
                          style: TextStyle(
                            color: sel
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(price,
                          style: TextStyle(
                            color: sel
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.65),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          )),
                      Text(perUnit,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 11,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(detail,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 10,
                      )),
                  if (trialText != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF22C55E), size: 10),
                          const SizedBox(width: 3),
                          Text(trialText,
                              style: const TextStyle(
                                color: Color(0xFF22C55E),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (badge != null)
                Positioned(
                  top: -22,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_crimson, _violet]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                              color: _crimson.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Text(badge,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CTA Button (redesigned: taller, bolder) ────────────────
  Widget _ctaButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmer, _pulse]),
      builder: (context, _) {
        final shimP = _shimmer.value;
        final glowV = _pulse.value;

        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [_crimson, Color(0xFFD43B6A), _violet],
            ),
            boxShadow: [
              BoxShadow(
                color: _crimson.withValues(alpha: 0.25 + glowV * 0.25),
                blurRadius: 24,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      begin: Alignment(-1.5 + 3.5 * shimP, 0),
                      end: Alignment(-0.5 + 3.5 * shimP, 0),
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ).createShader(b),
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.white),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Center(
                    child: Text(
                      _selectedPlan == 1
                          ? 'Start Free Trial'
                          : 'Subscribe Now',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Footer (compact single line) ──────────────────────────
  Widget _footerInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _selectedPlan == 1
                ? '7 days free, then \$39.99/year · Cancel anytime'
                : '\$6.99/week · Cancel anytime',
            key: ValueKey(_selectedPlan),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 9.5,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink('Terms'),
            _footerDot(),
            _footerLink('Privacy'),
            _footerDot(),
            _footerLink('Restore'),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String text) => GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Text(text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.16),
                fontSize: 10,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.08),
              )),
        ),
      );

  Widget _footerDot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
      );
}

// ── Waveform Custom Painter ─────────────────────────────────
class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;

  _WaveformPainter({
    required this.progress,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 36;
    final gap = size.width / barCount;
    final barW = gap * 0.5;
    final half = barCount / 2;
    final paint = Paint();

    for (var i = 0; i < barCount; i++) {
      final phase = i * 0.35;
      final norm = (math.sin(progress * math.pi * 2 + phase) + 1) / 2;
      final h = 3 + norm * (size.height - 3);
      final alpha = 0.2 + norm * 0.4;

      final centerDist = (i - half).abs() / half;
      paint.color =
          Color.lerp(color1, color2, centerDist)!.withValues(alpha: alpha);

      final x = i * gap + (gap - barW) / 2;
      final y = (size.height - h) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress;
}
