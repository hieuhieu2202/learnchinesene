# GAME IMPLEMENTATION ROADMAP
## APP Tiếng Trung — nhánh hieu

## Mục tiêu

Xây game theo hướng production, nhưng triển khai từng vertical slice để tránh AI tạo hàng loạt code khó bảo trì.

## Phase 0 — Audit
Coding AI phải inspect repository, database thật, GetX, DI, navigation, services, models, theme, audio, tests.
Không code.
Output: current architecture + data map + missing capabilities + plan.

## Phase 1 — Boss Battle
Dùng:
- docs/ai/BOSS_BATTLE_AI_IMPLEMENTATION_GUIDE.txt
- docs/ai/GAME_VISUAL_REFERENCE_GUIDE.md

Deliver:
- real data questions;
- explicit state machine;
- HP/combo/score;
- correct/wrong attack flows;
- animation/effects boundaries;
- learning event boundary;
- reward boundary;
- tests;
- verification.

## Phase 2 — Stabilize shared contracts
Chỉ extract phần đã chứng minh reuse:
- GameQuestion;
- GameSession;
- GameResult;
- QuestionReviewResult;
- QuestionGenerator contract;
- shared answer/question widgets nếu thật sự reusable.

Không over-engineer.

## Phase 3 — Memory Match
Dùng cùng learning repository.
Ưu tiên Hanzi↔pinyin / Hanzi↔meaning.

## Phase 4 — Tone Ninja
Tập trung pinyin/tone.
Có audio nếu hệ thống hiện tại hỗ trợ.

## Phase 5 — Sentence Train
Dùng sentence/challenge data thật.
Không hardcode câu.

## Phase 6 — Listening Detective
Reuse Audio/TTS service.
Không tạo audio engine thứ hai.

## Phase 7 — Radical Builder
Chỉ triển khai production khi radical/component data tồn tại hoặc migration/data import đã được duyệt.

## Phase 8 — Stroke Order Dojo
Chỉ triển khai validation thật khi có stroke path/order data đáng tin cậy.

## Phase 9 — Chinese Restaurant
Tạo contextual game loop dùng vocabulary/sentence data.

## Phase 10 — Treasure Map
Meta progression:
- nodes;
- stars;
- chapters;
- chest unlock;
- daily/weekly challenge;
- weak-item review.

Progression state không nằm trong renderer.

## Phase 11 — Pronunciation Battle
Không dùng STT confidence giả làm pronunciation score.
Cần pronunciation assessment service phù hợp.

## Phase 12 — Monetization
Chỉ sau khi core learning loop ổn.

Ưu tiên:
1. Premium subscription.
2. Advanced AI/pronunciation feedback.
3. Offline/content packs.
4. Cosmetics.
5. Premium adventure chapters.
6. Progress analytics.
7. Optional ads ở điểm không phá learning.

Phải có analytics trước khi tối ưu monetization:
- session_start;
- session_complete;
- question_answered;
- correct_rate;
- session_duration;
- game_selected;
- level_started;
- level_completed;
- reward_claimed;
- streak_updated;
- paywall_viewed;
- trial_started;
- purchase_completed.

Không log sensitive content không cần thiết.

## Rule quan trọng

Không triển khai nhiều game song song trước khi Boss Battle đạt Definition of Done.
