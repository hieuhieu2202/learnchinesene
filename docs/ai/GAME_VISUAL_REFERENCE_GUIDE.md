# GAME VISUAL REFERENCE GUIDE
## APP Tiếng Trung — Flutter + GetX

> Mục tiêu của tài liệu này là biến các concept art đã thiết kế thành yêu cầu triển khai UI/game rõ ràng cho coding AI.
> Đây là **visual target / UX direction**, không phải yêu cầu copy pixel-perfect.
> Coding agent phải đọc `AGENTS.md` nếu có, `.agents/skills/getx_architecture/SKILL.md`, `docs/ai/BOSS_BATTLE_AI_IMPLEMENTATION_GUIDE.txt` và inspect repository thật trước khi code.

---

## 1. VISUAL NORTH STAR

Phong cách chung của toàn bộ game:

- mobile game 2D / 2.5D cartoon;
- màu sắc tươi, rõ, dễ đọc;
- cảm hứng Trung Hoa nhưng không làm UI nặng nề;
- mascot gấu trúc là visual anchor;
- background có chiều sâu bằng nhiều layer;
- card câu hỏi sáng, tương phản cao;
- button có depth, highlight, shadow và pressed state;
- feedback đúng/sai mạnh nhưng ngắn;
- combo, XP, coin, heart, HP có animation;
- particles có giới hạn;
- không cần realtime 3D.

Ưu tiên:
1. Question / learning content.
2. Answer choices / interaction.
3. Character action.
4. Progress/HP.
5. Combo/score/reward.
6. Decorative effects.

Không được để VFX che Hanzi, pinyin hoặc đáp án.

---

## 2. SHARED VISUAL SYSTEM

### 2.1 Layout layers

Mỗi màn hình game nên chia thành các layer logic:

```text
Background Far
↓
Background Mid
↓
Background Near / Stage
↓
Character Layer
↓
Gameplay Object Layer
↓
Question / Interaction Layer
↓
HUD Layer
↓
FX Layer
↓
Overlay / Result Layer
```

Không nhét tất cả vào một Stack khổng lồ không có ownership rõ ràng.

### 2.2 Shared HUD

Các game có thể reuse:
- Pause button.
- Hearts / player HP.
- Timer khi game cần.
- XP progress.
- Coin count.
- Combo indicator.
- Streak indicator.
- Reward popups.

HUD phải compact, không chiếm không gian học.

### 2.3 Shared card style

Question card:
- nền sáng dạng giấy/cuộn thư;
- border gỗ/đỏ/vàng vừa phải;
- Hanzi lớn;
- pinyin ngay dưới;
- meaning/context tùy game;
- audio button rõ ràng;
- không dùng quá nhiều font.

Answer cards:
- rounded corners;
- subtle depth;
- idle / pressed / correct / wrong / disabled states;
- correct dùng glow + check icon;
- wrong dùng shake nhẹ + X icon;
- không chỉ dùng màu để biểu thị trạng thái.

### 2.4 Shared motion language

Animation quan trọng theo:
```text
Anticipation → Action → Impact → Settle
```

Dùng hợp lý:
- squash/stretch;
- bounce;
- floating idle;
- hit flash;
- trail;
- damage number;
- star burst;
- coin burst;
- petal/confetti;
- screen shake nhẹ;
- parallax.

Không bật tất cả cùng lúc.

---

# 3. GAME CONCEPTS

## GAME 01 — BOSS BATTLE

### Fantasy
Người học chiến đấu với boss bằng cách trả lời câu hỏi tiếng Trung.

### Visual composition
- Phía trên: boss name + boss HP.
- Trung tâm: boss lớn ở phía đối diện mascot.
- Background: núi, đền, waterfall, cầu đá, sky layers.
- Mascot gấu trúc đứng foreground.
- Dưới: player HP / XP.
- Bottom panel: question + 4 answers.

### Correct flow
```text
tap answer
→ button squash
→ green glow
→ mascot anticipation
→ projectile / energy attack
→ boss hit
→ hit flash
→ damage number
→ bounded particles
→ HP drains
→ combo popup
```

### Wrong flow
```text
wrong answer
→ red feedback
→ boss anticipation
→ boss attack
→ mascot hit/shake
→ player HP drains
→ concise correction
```

### Reusable components
- AnimatedHealthBar
- BattleCharacter
- QuestionCard
- AnswerGrid
- ComboIndicator
- DamageNumber
- EffectLayer
- ResultOverlay

### Data
Không hardcode.
Dùng QuestionGenerator từ repository/database thật.

---

## GAME 02 — RADICAL BUILDER / 偏旁合字

### Fantasy
Ghép radical/component để tạo Hanzi đúng.

### Visual composition
- Study hall / temple workshop.
- Target Hanzi lớn ở center.
- Component tiles bay/được kéo vào vùng ghép.
- Correct merge tạo golden burst.
- Mascot dùng magic brush/wand.

### Core loop
```text
show target word/meaning
→ present 3–5 radicals/components
→ player select/drag correct parts
→ merge animation
→ reveal Hanzi
→ reward / explanation
```

### Learning focus
- radicals;
- components;
- structural awareness;
- Hanzi decomposition.

### Important
Chỉ dùng radical/component data nếu database thật có.
Nếu thiếu phải report MISSING, không tự bịa decomposition authoritative.

---

## GAME 03 — TONE NINJA

### Fantasy
Chém đúng tone/pinyin như ninja training.

### Visual composition
- Bamboo dojo / mountain courtyard.
- 4 tone targets nổi như training targets.
- Mascot cầm kiếm.
- Correct target bị slash, burst và điểm combo.

### Core loop
```text
play/show syllable
→ ask target tone
→ moving/static tone targets
→ user taps/swipes target
→ slash effect
→ instant tone feedback
```

### Skills
- tone recognition;
- pinyin;
- listening if audio exists.

### Accessibility
Không encode tone bằng màu duy nhất.
Luôn có tone mark / number / shape.

---

## GAME 04 — CHINESE RESTAURANT

### Fantasy
Người học phục vụ món ăn bằng câu/từ tiếng Trung đúng.

### Visual composition
- warm Chinese restaurant;
- panda chef;
- customer reactions;
- order ticket;
- food illustrations;
- reward coins/XP.

### Core loop
Ví dụ:
```text
customer speaks/order appears
→ user identifies food / sentence
→ choose item or compose sentence
→ panda serves food
→ customer reacts
→ reward
```

### Learning focus
- real-life vocabulary;
- food;
- measure words;
- sentence context;
- listening;
- situational dialogue.

### Important
Không biến thành purely decorative restaurant sim.
Learning decision phải là core action.

---

## GAME 05 — STROKE ORDER DOJO

### Fantasy
Luyện viết Hanzi như võ đường thư pháp.

### Visual composition
- scroll/paper center;
- Hanzi guide grid;
- numbered stroke hints when needed;
- glowing brush path;
- panda calligraphy master.

### Core loop
```text
show Hanzi
→ optionally animate reference stroke
→ player traces stroke
→ validate order/direction/shape tolerance
→ next stroke
→ completion flourish
```

### Learning focus
- stroke order;
- stroke direction;
- writing memory.

### Important
Không tự tạo stroke data từ hình ảnh.
Nếu DB chưa có stroke order data, cần data source/migration riêng.

---

## GAME 06 — LISTENING DETECTIVE

### Fantasy
Panda detective nghe câu và chọn scene đúng.

### Visual composition
- detective academy / study room;
- panda with listening horn;
- audio bubble;
- 4 illustrated scene cards;
- timer/combo.

### Core loop
```text
play sentence/audio
→ player identifies matching scene/meaning
→ select card
→ reveal transcript
→ feedback
```

### Learning focus
- listening comprehension;
- contextual meaning;
- sentence recognition.

### Data
Reuse existing audio/TTS pipeline.
Không tạo audio system song song.

---

## GAME 07 — HANZI MEMORY MATCH

### Fantasy
Memory card matching giữa Hanzi ↔ pinyin ↔ meaning/image.

### Visual composition
- garden / academy;
- 3x4 or responsive card grid;
- card flip animation;
- matched pair glow;
- panda reaction.

### Pair modes
- Hanzi ↔ Pinyin
- Hanzi ↔ Meaning
- Hanzi ↔ Image
- Pinyin ↔ Meaning

### Important
Difficulty tăng bằng:
- more cards;
- confusable words;
- shorter preview;
- limited mistakes.

Không random pair vô nghĩa.

---

## GAME 08 — SENTENCE TRAIN

### Fantasy
Sắp xếp từ thành đoàn tàu để tạo câu đúng.

### Visual composition
- mountain station;
- train cars are word tiles;
- locomotive panda theme;
- correct sequence launches train toward destination.

### Core loop
```text
show sentence goal/context
→ shuffled word cars
→ player arranges cars
→ validate
→ train departs
→ reward
```

### Learning focus
- word order;
- sentence structure;
- grammar;
- contextual sentence building.

### Important
Không chỉ compare raw string nếu Chinese tokenization/order allows variants.
Reuse challenge/sentence data model where possible.

---

## GAME 09 — PRONUNCIATION BATTLE

### Fantasy
Người học dùng giọng nói như năng lượng tấn công training dummy/enemy.

### Visual composition
- martial arts stage;
- microphone CTA;
- waveform;
- pronunciation accuracy meter;
- energy blast based on result.

### Core loop
```text
show word/sentence
→ play reference
→ user records
→ speech/pronunciation scoring
→ visual meter
→ attack power feedback
```

### Important
Nếu project hiện tại chỉ có speech_to_text chứ chưa có pronunciation scoring engine:
- không giả vờ STT confidence = pronunciation score;
- report limitation;
- tạo service boundary cho pronunciation assessment.

---

## GAME 10 — TREASURE MAP VOCABULARY

### Fantasy
Đi theo bản đồ núi/đền để mở rương bằng vocabulary challenges.

### Visual composition
- vertical adventure map;
- nodes/stages;
- 3-star score;
- treasure chests;
- panda moving between nodes;
- mini question panel.

### Core loop
```text
select map node
→ challenge
→ grade performance
→ award stars
→ unlock next node/chest
```

### Learning focus
- review progression;
- themed vocabulary;
- daily/weekly journey;
- weak-item reinforcement.

### Important
Unlock/reward state phải tách khỏi visual layer.

---

# 4. SHARED GAME ARCHITECTURE

Mục tiêu dài hạn:

```text
SQLite / Learning DB
        ↓
Learning Repository
        ↓
Question Generator
        ↓
Game Session
        ↓
┌─────────────┬─────────────┬─────────────┐
Boss Battle   Tone Ninja    Memory Match  ...
        ↓
Game Result / Question Review Events
        ↓
Scheduler / FSRS Boundary
        ↓
Reward / Economy Boundary
```

Không tạo một question system riêng cho từng game nếu cùng learning item có thể reuse.

Một learning item nên có thể xuất hiện trong nhiều game.

---

# 5. SHARED GAME KIT — CHỈ EXTRACT SAU VERTICAL SLICE

Sau khi Boss Battle chạy production-quality mới cân nhắc extract:

```text
GameQuestion
GameQuestionGenerator
GameSession
GameResult
QuestionReviewResult
GameQuestionCard
GameAnswerButton
AnimatedHealthBar
ComboIndicator
GameEffectLayer
GameAudioService
GameMotion
GameQuality
```

Không tạo “framework game” lớn trước khi có một vertical slice chạy thật.

---

# 6. FLUTTER / GETX RESPONSIBILITY

GetX Controller:
- game orchestration;
- logical state;
- phase;
- score/combo/HP;
- question state;
- user action coordination.

Widget/Renderer:
- visual;
- animation;
- layout;
- VFX presentation.

Repository:
- data access.

QuestionGenerator:
- selection/distractors/anti-repeat.

Scheduler:
- FSRS/SRS.

Reward Service:
- reward request/result boundary.

Không để một Controller làm tất cả.

---

# 7. PERFORMANCE TARGET

Target architecture:
- 60 FPS trên Android tầm trung;
- fine-grained Obx;
- không rebuild full scene khi HP đổi;
- preload assets;
- bounded particles;
- no heavy image decoding during gameplay;
- no unbounded AnimationController/timer;
- quality levels LOW/MEDIUM/HIGH.

Không tuyên bố đạt 60 FPS nếu chưa profile device thật.

---

# 8. PRODUCTION ASSET PIPELINE

Concept art không nên được cắt nguyên tấm thành interactive UI.

Pipeline mong muốn:

```text
Concept Art
→ Style Bible
→ Asset List
→ Clean/Redraw Production Assets
→ Separate Layers
→ Character Rig/Sprite
→ UI Components
→ VFX
→ Flutter Integration
→ Device Profiling
```

Các nhóm asset:
- background_far;
- background_mid;
- background_near;
- foreground;
- mascot;
- enemies;
- UI frame;
- icons;
- answer states;
- particles;
- rewards;
- audio.

Nếu AI coding agent không có production asset:
hãy implement architecture + asset manifest + graceful fallback,
không dựng một đống placeholder khó thay thế.

---

# 9. CONSISTENT BRANDING

Nên giữ một mascot chính xuyên suốt app.

Suggested identity:
- panda explorer / scholar;
- red/gold/green accent;
- Chinese mountain/temple/garden/restaurant/dojo environments;
- parchment + wooden sign UI language.

Mỗi game đổi fantasy nhưng vẫn nhận ra cùng một app.

---

# 10. MONETIZATION-AWARE DESIGN WITHOUT DAMAGING LEARNING

Thiết kế từ đầu để có thể kiếm tiền nhưng không làm core learning khó chịu.

Nên ưu tiên:
- subscription/premium learning features;
- premium cosmetic themes;
- optional character skins;
- extra adventure chapters;
- advanced pronunciation/AI feedback;
- offline packs;
- detailed progress analytics;
- family/teacher features sau này;
- ads chỉ ở vị trí không phá learning flow nếu app dùng ads.

Không nên:
- chèn interstitial giữa câu hỏi và feedback;
- bán “đáp án đúng”;
- ép mua currency để học nội dung cơ bản;
- pay-to-win leaderboard;
- reward economy dễ exploit.

Retention phải đến từ:
- progress;
- streak;
- mastery;
- collection;
- adventure;
- challenge variety;
- useful learning outcomes.

---

# 11. IMPLEMENTATION ORDER

Khuyến nghị:

1. Boss Battle vertical slice.
2. Stabilize shared question/session/result architecture.
3. Extract proven Game Kit.
4. Hanzi Memory Match.
5. Tone Ninja.
6. Sentence Train.
7. Listening Detective.
8. Radical Builder.
9. Stroke Order Dojo.
10. Chinese Restaurant.
11. Treasure Map meta-progression.
12. Pronunciation Battle khi scoring backend/service đủ tốt.

Không làm 10 game cùng lúc.

---

# 12. DEFINITION OF VISUAL SUCCESS

Một game được xem là “đẹp giống game” khi:

- background có depth;
- character có idle + action + hit/reaction;
- buttons có pressed/correct/wrong states;
- feedback xảy ra theo choreography;
- HUD rõ;
- không giống form app thông thường;
- không jank;
- question vẫn là trọng tâm;
- art direction nhất quán;
- animation có timing;
- reward có cảm giác thỏa mãn nhưng không kéo dài quá mức.

