import '../view/boss_battle_character_art.dart';

enum BossBattleCharacterMotion {
  idle,
  ready,
  attack,
  hit,
  lowHp,
  victory,
  defeat,
}

class BossBattleRiveCharacterSpec {
  const BossBattleRiveCharacterSpec({
    required this.assetPath,
    required this.stateMachineName,
    required this.readyTrigger,
    required this.attackTrigger,
    required this.hitTrigger,
    required this.lowHpTrigger,
    required this.victoryTrigger,
    required this.defeatTrigger,
  });

  final String assetPath;
  final String stateMachineName;
  final String readyTrigger;
  final String attackTrigger;
  final String hitTrigger;
  final String lowHpTrigger;
  final String victoryTrigger;
  final String defeatTrigger;

  String? triggerFor(BossBattleCharacterMotion motion) {
    return switch (motion) {
      BossBattleCharacterMotion.idle => null,
      BossBattleCharacterMotion.ready => readyTrigger,
      BossBattleCharacterMotion.attack => attackTrigger,
      BossBattleCharacterMotion.hit => hitTrigger,
      BossBattleCharacterMotion.lowHp => lowHpTrigger,
      BossBattleCharacterMotion.victory => victoryTrigger,
      BossBattleCharacterMotion.defeat => defeatTrigger,
    };
  }
}

abstract final class BossBattleRiveContract {
  static const panda = BossBattleRiveCharacterSpec(
    assetPath: 'assets/animations/boss_battle/panda.riv',
    stateMachineName: 'PandaMachine',
    readyTrigger: 'ready',
    attackTrigger: 'attack',
    hitTrigger: 'hit',
    lowHpTrigger: 'low_hp',
    victoryTrigger: 'victory',
    defeatTrigger: 'defeat',
  );

  static const dragon = BossBattleRiveCharacterSpec(
    assetPath: 'assets/animations/boss_battle/dragon.riv',
    stateMachineName: 'DragonMachine',
    readyTrigger: 'ready',
    attackTrigger: 'attack',
    hitTrigger: 'hit',
    lowHpTrigger: 'rage',
    victoryTrigger: 'victory',
    defeatTrigger: 'defeat',
  );

  static BossBattleRiveCharacterSpec forKind(BossBattleCharacterKind kind) {
    return switch (kind) {
      BossBattleCharacterKind.panda => panda,
      BossBattleCharacterKind.dragon => dragon,
    };
  }
}
