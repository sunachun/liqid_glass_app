import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Glass Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LiquidGlassDemo(),
    );
  }
}

class LiquidGlassDemo extends StatefulWidget {
  const LiquidGlassDemo({super.key});

  @override
  State<LiquidGlassDemo> createState() => _LiquidGlassDemoState();
}

class _LiquidGlassDemoState extends State<LiquidGlassDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _thickness = 20;
  double _blur = 8;
  double _lightAngle = 0.5 * pi;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
        fit: StackFit.expand,
        children: [
          // カラフルなアニメーション背景
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BackgroundPainter(_controller.value),
              );
            },
          ),

          // Liquid Glass レイヤー
          LiquidGlassLayer(
            settings: LiquidGlassSettings(
              thickness: _thickness,
              blur: _blur,
              lightAngle: _lightAngle,
              chromaticAberration: 0.015,
              lightIntensity: 0.6,
              ambientStrength: 0.05,
              refractiveIndex: 1.3,
              saturation: 1.6,
              glassColor: const Color(0x22FFFFFF),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 大きな円形ガラス
                  LiquidGlass(
                    shape: LiquidOval(),
                    child: SizedBox.square(dimension: 150),
                  ),
                  SizedBox(height: 32),

                  // 横並びのスクエアガラス
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 24),
                        child: SizedBox.square(dimension: 90),
                      ),
                      SizedBox(width: 20),
                      LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 24),
                        child: SizedBox.square(dimension: 90),
                      ),
                      SizedBox(width: 20),
                      LiquidGlass(
                        shape: LiquidRoundedSuperellipse(borderRadius: 24),
                        child: SizedBox.square(dimension: 90),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // 横長の角丸ガラス
                  LiquidGlass(
                    shape: LiquidRoundedRectangle(borderRadius: 32),
                    child: SizedBox(width: 280, height: 60),
                  ),
                ],
              ),
            ),
          ),

          // スライダーパネル（下部）
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: _SettingsPanel(
              thickness: _thickness,
              blur: _blur,
              lightAngle: _lightAngle,
              onThicknessChanged: (v) => setState(() => _thickness = v),
              onBlurChanged: (v) => setState(() => _blur = v),
              onLightAngleChanged: (v) => setState(() => _lightAngle = v),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.thickness,
    required this.blur,
    required this.lightAngle,
    required this.onThicknessChanged,
    required this.onBlurChanged,
    required this.onLightAngleChanged,
  });

  final double thickness;
  final double blur;
  final double lightAngle;
  final ValueChanged<double> onThicknessChanged;
  final ValueChanged<double> onBlurChanged;
  final ValueChanged<double> onLightAngleChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SliderRow(
            label: 'Thickness',
            value: thickness,
            min: 5,
            max: 60,
            onChanged: onThicknessChanged,
          ),
          _SliderRow(
            label: 'Blur',
            value: blur,
            min: 0,
            max: 30,
            onChanged: onBlurChanged,
          ),
          _SliderRow(
            label: 'Light Angle',
            value: lightAngle,
            min: 0,
            max: 2 * pi,
            onChanged: onLightAngleChanged,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: Colors.white,
            inactiveColor: Colors.white30,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint();

    // グラデーション背景
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0F0C29),
        Color(0xFF302B63),
        Color(0xFF24243E),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    // アニメーションする円形グラデーション
    final blobs = [
      (
        offset: Offset(
          size.width * (0.3 + 0.3 * sin(t * 2 * pi)),
          size.height * (0.3 + 0.2 * cos(t * 2 * pi)),
        ),
        color: const Color(0x88FF6B6B),
        radius: size.width * 0.35,
      ),
      (
        offset: Offset(
          size.width * (0.6 + 0.25 * cos(t * 2 * pi + 1)),
          size.height * (0.6 + 0.25 * sin(t * 2 * pi + 1)),
        ),
        color: const Color(0x884ECDC4),
        radius: size.width * 0.3,
      ),
      (
        offset: Offset(
          size.width * (0.5 + 0.2 * sin(t * 2 * pi + 2)),
          size.height * (0.2 + 0.3 * cos(t * 2 * pi + 2)),
        ),
        color: const Color(0x88A8E6CF),
        radius: size.width * 0.28,
      ),
    ];

    for (final blob in blobs) {
      paint.shader = RadialGradient(
        colors: [blob.color, const Color(0x00000000)],
      ).createShader(Rect.fromCircle(center: blob.offset, radius: blob.radius));
      canvas.drawCircle(blob.offset, blob.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.t != t;
}
