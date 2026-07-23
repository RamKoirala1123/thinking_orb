import 'package:flutter/material.dart';
import 'package:ai_thinking_orb/ai_thinking_orb.dart';

void main() => runApp(const OrbsDemoApp());

class OrbsDemoApp extends StatefulWidget {
  const OrbsDemoApp({super.key});

  @override
  State<OrbsDemoApp> createState() => _OrbsDemoAppState();
}

class _OrbsDemoAppState extends State<OrbsDemoApp> {
  bool _dark = true;
  double _speed = 1.0;
  bool _paused = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ai_thinking_orbs demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(toolbarHeight: 0),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final horizontalPadding = width >= 1100
                  ? (width - 1000) / 2 // keeps content centered at 1000 wide
                  : width >= 700
                      ? 48.0
                      : 20.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding.clamp(20.0, 200.0),
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          textAlign: TextAlign.center,
                          'Thinking Orbs Demo',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        _ControlsBar(
                          speed: _speed,
                          paused: _paused,
                          dark: _dark,
                          onSpeedChanged: (v) => setState(() => _speed = v),
                          onPauseToggled: () =>
                              setState(() => _paused = !_paused),
                          onToggleTheme: () =>
                              setState(() => _dark = !_dark),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: const ScrollBehavior()
                                .copyWith(scrollbars: false),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 320,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1,
                              ),
                              itemCount: OrbState.values.length,
                              itemBuilder: (context, index) {
                                final state = OrbState.values[index];
                                return _OrbTile(
                                  state: state,
                                  speed: _speed,
                                  paused: _paused,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.speed,
    required this.paused,
    required this.dark,
    required this.onSpeedChanged,
    required this.onPauseToggled,
    required this.onToggleTheme,
  });

  final double speed;
  final bool paused;
  final bool dark;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onPauseToggled;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 320,
              child: Row(
                children: [
                  const Text('Speed'),
                  Expanded(
                    child: Slider(
                      min: 0.25,
                      max: 3,
                      value: speed,
                      label: '${speed.toStringAsFixed(2)}x',
                      onChanged: onSpeedChanged,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onPauseToggled,
                  icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                  label: Text(paused ? 'Resume' : 'Pause'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onToggleTheme,
                  icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbTile extends StatelessWidget {
  const _OrbTile({
    required this.state,
    required this.speed,
    required this.paused,
  });

  final OrbState state;
  final double speed;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThinkingOrb(
            state: state,
            size: OrbSize.size64,
            speed: speed,
            paused: paused,
          ),
          const SizedBox(height: 10),
          Text(
            state.name,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}