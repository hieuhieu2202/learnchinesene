import 'package:flash_learn_chinese/screen/boss_battle/animation/boss_battle_rive_contract.dart';
import 'package:flash_learn_chinese/screen/boss_battle/view/boss_battle_character_art.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BossBattleRiveContract', () {
    test('panda uses the expected state machine contract', () {
      final spec =
          BossBattleRiveContract.forKind(BossBattleCharacterKind.panda);

      expect(spec.assetPath, endsWith('/panda.riv'));
      expect(spec.stateMachineName, 'PandaMachine');
      expect(spec.triggerFor(BossBattleCharacterMotion.attack), 'attack');
      expect(spec.triggerFor(BossBattleCharacterMotion.hit), 'hit');
      expect(spec.triggerFor(BossBattleCharacterMotion.idle), isNull);
    });

    test('dragon maps low-health state to rage', () {
      final spec =
          BossBattleRiveContract.forKind(BossBattleCharacterKind.dragon);

      expect(spec.assetPath, endsWith('/dragon.riv'));
      expect(spec.stateMachineName, 'DragonMachine');
      expect(spec.triggerFor(BossBattleCharacterMotion.lowHp), 'rage');
      expect(spec.triggerFor(BossBattleCharacterMotion.defeat), 'defeat');
    });
  });
}
