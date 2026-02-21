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
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    _topBar(),
                    const SizedBox(height: 4),
                    Expanded(child: _heroVisual()),
                    _headline(),
                    const SizedBox(height: 6),
                    _socialProof(),
                    const SizedBox(height: 14),
                    _featureStrip(),
                    const SizedBox(height: 16),
                    _planSelector(),
                    const SizedBox(height: 14),
                    _ctaButton(),
                    const SizedBox(height: 8),
                    _footerInfo(),
                    SizedBox(height: bot > 0 ? 2 : 8),
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
              top: -60 + v * 15,
              left: -80,
              child: _glowOrb(260, _crimson, 0.07 + v * 0.03),
            ),
            Positioned(
              top: 140,
              right: -90 + v * 10,
              child: _glowOrb(220, _violet, 0.05 + v * 0.025),
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
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_closeBtn(), _offerBadge()],
      ),
    );
  }

  Widget _closeBtn() => GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.close_rounded,
              color: Colors.white54, size: 18),
        ),
      );

  Widget _offerBadge() => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.elasticOut,
        builder: (_, v, c) => Transform.scale(scale: v, child: c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Icon(Icons.bolt_rounded, color: _amber, size: 13),
              const SizedBox(width: 3),
              Text(
                '50% OFF',
                style: TextStyle(
                  color: _amber,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Hero Visual ───────────────────────────────────────────
  Widget _heroVisual() {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final bigD = w * 0.30;
        final smallD = w * 0.20;
        final spread = w * 0.22;

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
                    height: bigD + 24,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        _glowOrb(bigD * 2.5, _crimson, 0.08 + b * 0.05),
                        // Left cover
                        Transform.translate(
                          offset: Offset(
                            -spread - bigD * 0.12 + (1 - entryV) * -40,
                            6 + math.sin(b * math.pi * 2 + 1.2) * 3,
                          ),
                          child:
                              _coverCircle(_covers[0], smallD, dimmed: true),
                        ),
                        // Right cover
                        Transform.translate(
                          offset: Offset(
                            spread + bigD * 0.12 + (1 - entryV) * 40,
                            6 + math.sin(b * math.pi * 2 + 2.4) * 3,
                          ),
                          child:
                              _coverCircle(_covers[2], smallD, dimmed: true),
                        ),
                        // Pulsing ring
                        Transform.scale(
                          scale: 1.0 + math.sin(b * math.pi * 2) * 0.04,
                          child: Container(
                            width: bigD + 18,
                            height: bigD + 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _crimson.withValues(
                                    alpha: 0.1 + b * 0.18),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        // Center cover (hero)
                        Transform.translate(
                          offset:
                              Offset(0, math.sin(b * math.pi * 2) * 2),
                          child: _coverCircle(_covers[1], bigD,
                              isCenter: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: w * 0.65,
                    height: 22,
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
              color: _crimson.withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCenter
              ? _crimson.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
          width: isCenter ? 2 : 1,
        ),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(asset, fit: BoxFit.cover),
            if (dimmed)
              Container(color: Colors.black.withValues(alpha: 0.45)),
            if (dimmed)
              Center(
                child: Icon(Icons.lock_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: size * 0.22),
              ),
            if (isCenter) _centerPlayBtn(size),
          ],
        ),
      ),
    );
  }

  Widget _centerPlayBtn(double parentSize) {
    final s = parentSize * 0.30;
    return Align(
      alignment: const Alignment(0, 0.75),
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [_crimson, _violet]),
          boxShadow: [
            BoxShadow(
                color: _crimson.withValues(alpha: 0.5), blurRadius: 10),
          ],
        ),
        child: Icon(Icons.play_arrow_rounded,
            color: Colors.white, size: s * 0.6),
      ),
    );
  }

  // ── Headline ──────────────────────────────────────────────
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
              colors: [Colors.white, Color(0xFFF4A0B8)],
            ).createShader(bounds),
            child: const Text(
              'Unlock Every Whisper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thousands of intimate audio stories await',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Social Proof ──────────────────────────────────────────
  Widget _socialProof() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOut,
      builder: (_, v, c) => Opacity(opacity: v, child: c),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
              5,
              (_) =>
                  const Icon(Icons.star_rounded, color: _amber, size: 13)),
          const SizedBox(width: 4),
          const Text('4.9',
              style: TextStyle(
                  color: _amber,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700)),
          _dotSep(),
          Text('2M+ listeners',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11)),
          _dotSep(),
          const Icon(Icons.local_fire_department_rounded,
              color: Color(0xFFFF6B6B), size: 12),
          const SizedBox(width: 2),
          const Text('Trending',
              style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _dotSep() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      );

  // ── Feature Strip ─────────────────────────────────────────
  Widget _featureStrip() {
    final items = [
      (Icons.all_inclusive_rounded, 'Unlimited'),
      (Icons.headphones_rounded, 'HD Audio'),
      (Icons.download_rounded, 'Offline'),
      (Icons.auto_awesome_rounded, 'New Daily'),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 10 * (1 - v)), child: c),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items
              .map((item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, color: _crimson, size: 15),
                      const SizedBox(width: 5),
                      Text(item.$2,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Plan Selector ─────────────────────────────────────────
  Widget _planSelector() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1050),
      curve: Curves.easeOut,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 12 * (1 - v)), child: c),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Row(
              children: [
                _planTab(0, 'Weekly'),
                _planTab(1, 'Annual'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: _selectedPlan == 1 ? _annualInfo() : _weeklyInfo(),
          ),
        ],
      ),
    );
  }

  Widget _planTab(int index, String label) {
    final sel = _selectedPlan == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlan = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: sel
                ? LinearGradient(colors: [
                    _crimson.withValues(alpha: 0.18),
                    _violet.withValues(alpha: 0.08),
                  ])
                : null,
            borderRadius: BorderRadius.circular(11),
            border: sel
                ? Border.all(color: _crimson.withValues(alpha: 0.3))
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                      color: sel
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    )),
                if (index == 1) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(colors: [_crimson, _violet]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text('SAVE 88%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        )),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _annualInfo() {
    return Column(
      key: const ValueKey('annual'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('\$39.99',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                )),
            Text('/year',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                )),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF22C55E), size: 13),
            const SizedBox(width: 4),
            const Text('7-day free trial',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                )),
            _dotSep(),
            Text('\$0.76/week',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11.5,
                )),
          ],
        ),
      ],
    );
  }

  Widget _weeklyInfo() {
    return Column(
      key: const ValueKey('weekly'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('\$6.99',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                )),
            Text('/week',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text('Billed weekly · No commitment',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11.5,
            )),
      ],
    );
  }

  // ── CTA Button ────────────────────────────────────────────
  Widget _ctaButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmer, _pulse]),
      builder: (context, _) {
        final shimP = _shimmer.value;
        final glowV = _pulse.value;

        return Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [_crimson, Color(0xFFD43B6A), _violet],
            ),
            boxShadow: [
              BoxShadow(
                color: _crimson.withValues(alpha: 0.2 + glowV * 0.2),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      begin: Alignment(-1.5 + 3.5 * shimP, 0),
                      end: Alignment(-0.5 + 3.5 * shimP, 0),
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.18),
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
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {},
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedPlan == 1)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.lock_open_rounded,
                                color: Colors.white, size: 18),
                          ),
                        Text(
                          _selectedPlan == 1
                              ? 'Start Free Trial'
                              : 'Subscribe Now',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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

  // ── Footer ────────────────────────────────────────────────
  Widget _footerInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _selectedPlan == 1
                ? '7 days free, then \$39.99/year · Cancel anytime'
                : 'Auto-renews at \$6.99/week · Cancel anytime',
            key: ValueKey(_selectedPlan),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 4),
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
                color: Colors.white.withValues(alpha: 0.18),
                fontSize: 10.5,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.1),
              )),
        ),
      );

  Widget _footerDot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          width: 2.5,
          height: 2.5,
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
    const barCount = 28;
    final gap = size.width / barCount;
    final barW = gap * 0.5;
    final half = barCount / 2;
    final paint = Paint();

    for (var i = 0; i < barCount; i++) {
      final phase = i * 0.38;
      final norm = (math.sin(progress * math.pi * 2 + phase) + 1) / 2;
      final h = 3 + norm * (size.height - 3);
      final alpha = 0.18 + norm * 0.35;

      final centerDist = (i - half).abs() / half;
      paint.color =
          Color.lerp(color1, color2, centerDist)!.withValues(alpha: alpha);

      final x = i * gap + (gap - barW) / 2;
      final y = (size.height - h) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress;
}
