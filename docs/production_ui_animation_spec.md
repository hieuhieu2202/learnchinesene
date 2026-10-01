# Production UI + Art + Animation Spec

Branch target: `hieu`  
Scope: Home, Game Hub, Boss Battle, progression, audio and production-art pipeline.

## 1. Product goal

The app should feel like a polished Chinese-learning game, not a form-based learning utility.
The visual target is the current reference mockup: warm Home surface, large illustrated game cards,
full-screen Boss Battle, readable combat HUD, strong correct/wrong feedback and expressive panda/dragon states.

The implementation is split into two layers:

- **Flutter UI layer:** cards, HUD, answers, navigation, layout, progress, responsiveness.
- **Production art layer:** backgrounds, panda, dragon, particles, victory/defeat art.

Do not attempt to recreate production characters only with `CustomPainter` once final art is available.
Painter-based art stays as a fallback until the production assets are delivered.

## 2. Visual system

### Palette

- App cream: `#FFF8ED`
- App cream strong: `#FFEED4`
- Primary blue: `#2E93E8`
- Success green: `#22B868`
- Reward gold: `#FFB62E`
- Game orange: `#F47B2D`
- Danger red: `#E44737`
- Boss burgundy: `#7D1D24`
- Battle night: `#241728`

The source of truth is `lib/core/theme/game_visual_tokens.dart`.

### Radius

- Small: 12
- Medium: 18
- Large: 24
- XL: 30

### Spacing

- Page padding: 16
- Section gap: 18
- Card gap: 12

### Typography

- Screen title: 26–30 / weight 900
- Feature title: 20–25 / weight 900
- Card title: 15–17 / weight 900
- Body: 11–13 / weight 600–700
- HUD numbers: 12–18 / weight 900

## 3. Home screen spec

### Header
- 50x50 panda avatar.
- Greeting + one-line motivation.
- Streak badge on the right.
- No unbounded-height widgets inside scroll content.

### Hero
- Target ratio: ~2.15:1 on phone.
- Production layers:
  - `home_sky.webp`
  - `home_mountains.webp`
  - `home_pagoda.webp`
  - `home_blossom_fg.webp`
  - `panda_home.webp`
- CTA is Flutter UI, not baked into artwork.

### Stats
Three equal cards:
- study days
- lessons
- XP

### Today lesson
- illustration area 60x60
- title + subtitle + progress
- CTA button
- minimum touch target 44x44

### Quick actions
Four equal tiles:
- vocabulary
- grammar
- listening
- speaking

## 4. Game Hub spec

Implemented in `lib/screen/game_hub/game_hub_screen.dart`.

### Header
- centered title
- small subtitle
- 3-state filter

### Boss Battle featured card
- 186 px base height on phone
- full illustrated scene
- panda on right
- text and tags on left
- full-card tap target
- deep shadow + gold border

### Secondary games
- 76x76 thumbnail
- title, short description, status badge
- consistent 20px corner radius

## 5. Boss Battle stage map

### Data
Use Supabase-driven `boss_stages`.
Never hardcode production stage count in the UI.

Each row should expose:
- id
- stage order
- section/unit
- title
- difficulty
- boss name
- boss HP
- player HP
- theme
- question count

### UX
- alternating path cards
- every 7th stage is visually a boss gate
- stage theme influences accent/background
- after victory, return to map and highlight the next stage

## 6. Boss Battle gameplay layout

Reference design target:

1. top HUD: pause, boss name/level, boss HP, settings
2. battle scene: panda left/bottom, dragon right/top
3. question card above answers
4. four answers in 2x2 grid
5. player HUD bottom-left
6. combo bottom-right

### Responsive constraints
- no hard assumptions about 375x812
- base art positions on `LayoutBuilder` percentages
- question/answer area must remain readable at 360px width
- avoid nested unbounded scrollables

## 7. Character animation contract

### Panda states
- idle
- ready
- attack
- hit
- low_hp
- victory
- defeat

### Dragon states
- idle
- turn
- charge_fire
- fire_breath
- hit
- low_hp
- defeat

### Event timing

Correct answer:
- 0ms answer turns green
- 80ms panda readies
- 180ms projectile leaves panda
- 420ms impact
- 440ms boss damage number + HP tween
- 650ms combo settles

Wrong answer:
- 0ms answer turns red
- 100ms dragon turns
- 220ms mouth charge
- 420ms fire starts
- 650ms impact + screen shake
- 680ms player HP tween
- 850ms return to idle

## 8. Production art manifest

### Home
`assets/art/home/`
- home_sky.webp
- home_mountains.webp
- home_pagoda.webp
- home_blossom_fg.webp
- panda_home.webp

### Game Hub
`assets/art/game_hub/`
- boss_battle_thumb.webp
- radical_builder_thumb.webp
- tone_ninja_thumb.webp
- chinese_restaurant_thumb.webp

### Boss Battle
`assets/art/boss_battle/`
- arena_spring_bg.webp
- arena_sunset_bg.webp
- arena_night_bg.webp
- arena_inferno_bg.webp
- victory_bg.webp
- defeat_bg.webp

### Panda animation
`assets/art/boss_battle/panda/`
- panda_idle.riv
- or sprite sheets for idle/attack/hit/victory/defeat

### Dragon animation
`assets/art/boss_battle/dragon/`
- dragon_idle.riv
- or sprite sheets for idle/turn/fire/hit/defeat

### FX
`assets/art/boss_battle/fx/`
- arrow.webp
- hit_burst.webp
- fire_core.webp
- fire_smoke.webp
- spark.webp
- combo_glow.webp

Final production assets should replace fallback painter art without changing game logic.

## 9. Audio contract

Required channels:
- pronunciation
- UI tap
- correct
- wrong
- arrow
- dragon fire
- hit
- victory
- defeat

Rules:
- pronunciation tap should stop previous pronunciation before replay
- combat SFX must not block answer-state transitions
- audio failures must not break gameplay
- keep a mute toggle for SFX/voice

## 10. Supabase contract

Public content:
- readable by the client under explicit RLS policies

User progress:
- authenticated user can read/write only own rows

Recommended game tables:
- boss_stages
- boss_stage_progress
- game_worlds
- game_rewards

Do not move combat reward authority to the client when rewards become spendable.

## 11. Performance budget

Target:
- 60 FPS on midrange Android
- avoid unnecessary `saveLayer`
- isolate animated FX with `RepaintBoundary`
- static scene art should be precomposed where possible
- avoid adding a full game engine until Flutter rendering is proven insufficient
- do not bundle large unused assets
- pronunciation audio should be remote/cache-on-demand rather than shipping a huge pack

## 12. Implementation milestones

### M1 — stable polished shell
- Home stable
- visual tokens
- Game Hub production layout
- no render exceptions

### M2 — battle polish
- responsive battle composition
- HP tweens
- answer feedback
- stronger cartoon fire/arrow FX
- screen shake and damage popups

### M3 — production assets
- replace fallback panda/dragon
- 4 battle themes
- victory/defeat illustrations

### M4 — audio polish
- pronunciation
- correct/wrong
- combat SFX
- music/mute settings

### M5 — progression
- unlock logic
- stage stars
- best score/combo
- map highlight
- rewards

## 13. Acceptance checklist

A screen is not considered finished until:
- no overflow/render exceptions at 360x720, 390x844, 450x708
- all tap targets work
- text does not clip
- loading/error/empty states exist
- no duplicate controller initialization
- game state prevents double answer taps
- animation does not block navigation
- UI matches the reference composition before adding more features
