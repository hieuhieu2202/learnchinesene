import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../animation/boss_battle_rive_contract.dart';
import 'boss_battle_character_art.dart';

class BossBattleAnimatedCharacter extends StatelessWidget {
  const BossBattleAnimatedCharacter({
    super.key,
    required this.kind,
    required this.motion,
    required this.size,
    required this.defeated,
  });

  final BossBattleCharacterKind kind;
  final BossBattleCharacterMotion motion;
  final double size;
  final bool defeated;

  static Future<bool>? _riveInitialization;

  static Future<bool> _ensureRiveInitialized() {
    return _riveInitialization ??= _initializeRive();
  }

  static Future<bool> _initializeRive() async {
    try {
      return await RiveNative.init();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = BossBattleRiveContract.forKind(kind);

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: FutureBuilder<bool>(
          future: _ensureRiveInitialized(),
          builder: (context, snapshot) {
            if (snapshot.data != true) {
              return _FallbackAnimatedCharacter(
                kind: kind,
                motion: motion,
                size: size,
                defeated: defeated,
              );
            }

            return _RiveCharacterView(
              key: ValueKey(spec.assetPath),
              spec: spec,
              motion: motion,
              fallback: _FallbackAnimatedCharacter(
                kind: kind,
                motion: motion,
                size: size,
                defeated: defeated,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RiveCharacterView extends StatefulWidget {
  const _RiveCharacterView({
    super.key,
    required this.spec,
    required this.motion,
    required this.fallback,
  });

  final BossBattleRiveCharacterSpec spec;
  final BossBattleCharacterMotion motion;
  final Widget fallback;

  @override
  State<_RiveCharacterView> createState() => _RiveCharacterViewState();
}

class _RiveCharacterViewState extends State<_RiveCharacterView> {
  late final FileLoader _fileLoader;
  RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(
      widget.spec.assetPath,
      riveFactory: Factory.rive,
    );
  }

  @override
  void didUpdateWidget(covariant _RiveCharacterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.motion != oldWidget.motion) {
      _play(widget.motion);
    }
  }

  void _onLoaded(RiveLoaded state) {
    _controller = state.controller;
    _play(widget.motion);
  }

  void _play(BossBattleCharacterMotion motion) {
    final controller = _controller;
    final triggerName = widget.spec.triggerFor(motion);
    if (controller == null || triggerName == null) return;

    // Presentation-only mapping. BossBattleController never depends on Rive.
    // ignore: deprecated_member_use
    controller.stateMachine.trigger(triggerName)?.fire();
  }

  @override
  void dispose() {
    _controller = null;
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: _fileLoader,
      stateMachineSelector:
          StateMachineSelector.byName(widget.spec.stateMachineName),
      onLoaded: _onLoaded,
      builder: (context, state) => switch (state) {
        RiveLoading() => widget.fallback,
        RiveFailed() => widget.fallback,
        RiveLoaded() => RiveWidget(
            controller: state.controller,
            fit: Fit.contain,
          ),
      },
    );
  }
}

class _FallbackAnimatedCharacter extends StatefulWidget {
  const _FallbackAnimatedCharacter({
    required this.kind,
    required this.motion,
    required this.size,
    required this.defeated,
  });

  final BossBattleCharacterKind kind;
  final BossBattleCharacterMotion motion;
  final double size;
  final bool defeated;

  @override
  State<_FallbackAnimatedCharacter> createState() =>
      _FallbackAnimatedCharacterState();
}

class _FallbackAnimatedCharacterState extends State<_FallbackAnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds:
            widget.kind == BossBattleCharacterKind.dragon ? 1250 : 980,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, child) {
        final wave = math.sin(_loopController.value * math.pi);
        final motion = widget.motion;

        final bob = switch (motion) {
          BossBattleCharacterMotion.defeat => 0.0,
          BossBattleCharacterMotion.hit => wave * 1.0,
          BossBattleCharacterMotion.attack => -wave * 1.5,
          BossBattleCharacterMotion.victory => -wave * 4.0,
          BossBattleCharacterMotion.lowHp => wave * 1.2,
          _ => -wave * 2.5,
        };

        final scaleY = switch (motion) {
          BossBattleCharacterMotion.defeat => .94,
          BossBattleCharacterMotion.hit => .98,
          BossBattleCharacterMotion.attack => 1.02,
          BossBattleCharacterMotion.victory => 1.0 + wave * .05,
          BossBattleCharacterMotion.lowHp => 1.0 + wave * .012,
          _ => 1.0 + wave * .025,
        };

        final rotation = switch (motion) {
          BossBattleCharacterMotion.hit =>
            math.sin(_loopController.value * math.pi * 4) * .035,
          BossBattleCharacterMotion.victory =>
            math.sin(_loopController.value * math.pi * 2) * .025,
          BossBattleCharacterMotion.lowHp =>
            math.sin(_loopController.value * math.pi * 2) * .012,
          _ => 0.0,
        };

        return Transform.translate(
          offset: Offset(0, bob),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scaleX: 1,
              scaleY: scaleY,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
      child: BossBattleCharacterArt(
        kind: widget.kind,
        size: widget.size,
        defeated: widget.defeated,
      ),
    );
  }
}
