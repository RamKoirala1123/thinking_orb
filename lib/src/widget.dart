// The ThinkingOrb widget. A single Ticker (via SingleTickerProviderStateMixin)
// drives the animation; it's stopped automatically when `paused` is set or
// when the platform reports reduced-motion, in which case a single static
// representative frame is drawn instead (still following the live theme).

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'presets.dart';
import 'profiles.dart';
import 'registry.dart';
import 'types.dart';

const Map<OrbState, String> _labels = {
  OrbState.working: 'Working…',
  OrbState.searching: 'Searching…',
  OrbState.solving: 'Solving…',
  OrbState.listening: 'Listening…',
  OrbState.composing: 'Composing…',
  OrbState.shaping: 'Shaping…',
};

/// A small animated "thinking" indicator: six hand-tuned states, two size
/// presets (64 / 20 logical px), light/dark aware. Pure [CustomPainter] —
/// no external dependencies.
class ThinkingOrb extends StatefulWidget {
  const ThinkingOrb({
    super.key,
    this.state = OrbState.working,
    this.size = OrbSize.size64,
    this.theme = OrbTheme.auto,
    this.speed = 1,
    this.paused = false,
    this.semanticLabel,
  });

  /// Which animation to show.
  final OrbState state;

  /// Tuned size preset — 64 or 20 logical px.
  final OrbSize size;

  /// Theme mode; `auto` follows [Theme.of(context).brightness].
  final OrbTheme theme;

  /// Animation speed multiplier on top of the preset's baked speed.
  final double speed;

  /// Freeze the animation on the current frame.
  final bool paused;

  /// Accessibility label; defaults to a per-state description.
  final String? semanticLabel;

  @override
  State<ThinkingOrb> createState() => _ThinkingOrbState();
}

class _ThinkingOrbState extends State<ThinkingOrb> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    setState(() {
      _elapsedSeconds = elapsed.inMicroseconds / 1e6;
    });
  }

  bool _reducedMotion() => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  void _syncTicker() {
    final shouldRun = !widget.paused && !_reducedMotion();
    if (shouldRun && !_ticker.isActive) {
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant ThinkingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool _resolveDark(BuildContext context) {
    switch (widget.theme) {
      case OrbTheme.dark:
        return true;
      case OrbTheme.light:
        return false;
      case OrbTheme.auto:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = _resolveDark(context);
    final reduced = _reducedMotion();
    final px = widget.size.px;

    final resolved = resolvePreset(widget.state, widget.size);
    final effSpeed = resolved.speed * widget.speed;
    // reduced motion -> one static, deterministic frame
    final t = reduced ? 0.6 : _elapsedSeconds * effSpeed;

    return Semantics(
      label: widget.semanticLabel ?? _labels[widget.state],
      image: true,
      child: SizedBox(
        width: px,
        height: px,
        child: CustomPaint(
          painter: _OrbPainter(
            draw: modeDraws[resolved.mode]!,
            size: px,
            t: t,
            dark: dark,
            opts: resolved.opts,
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.draw,
    required this.size,
    required this.t,
    required this.dark,
    required this.opts,
  });

  final ModeDraw draw;
  final double size;
  final double t;
  final bool dark;
  final ModeOpts opts;

  @override
  void paint(Canvas canvas, Size s) => draw(canvas, size, t, dark, opts);

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.dark != dark ||
        oldDelegate.draw != draw ||
        oldDelegate.opts != opts;
  }
}
