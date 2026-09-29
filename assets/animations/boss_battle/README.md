# Boss Battle Rive asset contract

The Flutter integration is already wired. If the binary Rive files are absent
or fail to initialize, the screen automatically falls back to the animated
CustomPainter characters, so Boss Battle remains playable.

## Required files

### panda.riv
- State machine: `PandaMachine`
- Default state: looping idle
- Triggers: `ready`, `attack`, `hit`, `low_hp`, `victory`, `defeat`

### dragon.riv
- State machine: `DragonMachine`
- Default state: looping idle
- Triggers: `ready`, `attack`, `hit`, `rage`, `victory`, `defeat`

## Animation direction

Panda should breathe and blink in idle, anticipate before a strike, recoil after
impact, look tired at low HP, celebrate on victory, and collapse on defeat.

Dragon should breathe, blink, move its tail/wings in idle, charge before fire
breath, recoil on hit, become more aggressive in rage, roar on victory, and
stagger/collapse on defeat.

Rive is presentation only. Questions, HP, combo, score, session state, FSRS, and
rewards stay in the existing GetX/domain layers.
