// Mode key -> frame painter.

import 'modes/lattice.dart';
import 'modes/morph.dart';
import 'modes/orbits.dart';
import 'modes/ribbon.dart';
import 'presets.dart';
import 'types.dart';

final Map<ModeKey, ModeDraw> modeDraws = {
  ModeKey.orbits: drawOrbits,
  ModeKey.globe: drawGlobe,
  ModeKey.rubik: drawRubik,
  ModeKey.wave: drawWave,
  ModeKey.ribbon: drawRibbon,
  ModeKey.morph: drawMorph,
};
