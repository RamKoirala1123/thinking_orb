// Shared primitives for the dotted 3D thought-orbs. Ported from the
// TypeScript/canvas implementation: honestly 3D — rotated, depth-shaded,
// z-sorted. Depth is carried by dot size and ink weight alone. Plain
// canvas fills only, so every mode renders identically across platforms.

import 'dart:math' as math;
import 'dart:ui';

/// One rendered dot: honestly-3D position, radius, and ink value.
class Dot {
  const Dot({
    required this.x,
    required this.y,
    required this.z,
    required this.r,
    required this.white,
    this.a,
  });

  final double x;
  final double y;
  final double z;
  final double r;

  /// Ink value: 0 = darkest ink on paper. Mirrored on dark themes.
  final double white;

  /// Alpha in [0, 1]. Defaults to 1 when omitted.
  final double? a;
}

/// A 3D/point tuple: (x, y, z). Used both as a pre-projection direction
/// and as a post-projection (screenX, screenY, depthZ) result.
typedef Vec3 = (double, double, double);

/// Projects an (x, y, z) point to (screenX, screenY, depthZ).
typedef Projector = Vec3 Function(double x, double y, double z);

/// Deterministic hash in [0, 1).
double hashD(double a, double b) {
  final h = math.sin(a * 12.9898 + b * 78.233) * 43758.5453;
  return h - h.floorToDouble();
}

/// Stable directions on a unit sphere (Fibonacci lattice).
Vec3 fibDir(int i, int n) {
  final golden = math.pi * (3 - math.sqrt(5));
  final y = 1 - (2 * (i + 0.5)) / n;
  final rad = math.sqrt(1 - y * y);
  final a = i * golden;
  return (rad * math.cos(a), y, rad * math.sin(a));
}

/// Shortest signed angular distance, wrapped to (-pi, pi].
double angleDelta(double a, double b) {
  return math.atan2(math.sin(a - b), math.cos(a - b));
}

/// Shared spin + tilt + orthographic projection.
Projector makeProj(double yaw, double tilt, double cx, double cy, double scale) {
  final st = math.sin(tilt);
  final ct = math.cos(tilt);
  final sy = math.sin(yaw);
  final cyw = math.cos(yaw);
  return (x, y, z) {
    final x1 = x * cyw + z * sy;
    final z1 = -x * sy + z * cyw;
    final y1 = y * ct - z1 * st;
    final z2 = y * st + z1 * ct;
    return (cx + x1 * scale, cy - y1 * scale, z2);
  };
}

/// Painter: z-sort far->near, matte grayscale dots. On dark substrates the
/// ink value is mirrored (1 - white) so near dots read bright — the same
/// depth language on an inverted substrate.
void paint(Canvas canvas, List<Dot> dots, bool dark, [double rMin = 0.3]) {
  final sorted = List<Dot>.of(dots)..sort((a, b) => a.z.compareTo(b.z));
  final paintObj = Paint()..style = PaintingStyle.fill;
  for (final d in sorted) {
    final alpha = d.a ?? 1.0;
    if (alpha < 0.02) continue;
    final w = d.white.clamp(0.0, 1.0);
    final g = ((dark ? 1 - w : w) * 255).round();
    paintObj.color = Color.fromARGB((alpha.clamp(0.0, 1.0) * 255).round(), g, g, g);
    canvas.drawCircle(Offset(d.x, d.y), math.max(rMin, d.r), paintObj);
  }
}

/// Dot radii were tuned for a 300pt frame; sub-linear scaling keeps small
/// spinners legible. Lower pow = radii shrink less with size.
double radiusScale(double size, double pow) {
  return math.pow(size / 300, pow).toDouble();
}
