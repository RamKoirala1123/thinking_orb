import 'dart:ui';

import 'profiles.dart';

/// The six shipped states — each a hand-tuned animation:
/// - `working`   — particles on tilted orbits
/// - `searching` — a scan meridian sweeps a dotted globe
/// - `solving`   — bands scramble in quarter turns, then click back
/// - `listening` — a waveform rolls through latitude rings
/// - `composing` — an undulating multi-band sash
/// - `shaping`   — a dotted outline morphs circle -> triangle -> square
enum OrbState { working, searching, solving, listening, composing, shaping }

/// Rendered size in logical (CSS-equivalent) pixels. Exactly two tuned
/// presets ship: 64 (chat-avatar scale) and 20 (inline-text scale). Each
/// size carries its own dot count, dot size and speed tuning — they are
/// separate designs, not a scale factor.
enum OrbSize { size64, size20 }

extension OrbSizeValue on OrbSize {
  double get px {
    switch (this) {
      case OrbSize.size64:
        return 64;
      case OrbSize.size20:
        return 20;
    }
  }
}

/// Theme mode.
///
/// - `auto` (default) resolves from [Theme.of(context).brightness] (or an
///   explicit override you pass down), live-updating on rebuild.
/// - `dark` / `light` pin the palette regardless of context.
///
/// Dark renders light ink on the transparent canvas (for dark
/// backgrounds); light renders dark ink (for light backgrounds).
enum OrbTheme { auto, dark, light }

/// One frame painter: draws a mode into a canvas at logical-px `size`.
typedef ModeDraw = void Function(
  Canvas canvas,
  double size,
  double t,
  bool dark,
  ModeOpts opts,
);
