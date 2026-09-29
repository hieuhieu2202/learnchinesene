-- Applied to Supabase project hrlahralknhijnkypjix on 2026-09-29.
-- Security hardening + covering indexes for cloud-first runtime queries.

revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
grant execute on function public.rls_auto_enable() to service_role;

create index if not exists duo_challenges_character_id_idx
  on public.duo_challenges(character_id);
create index if not exists duo_levels_unit_id_idx
  on public.duo_levels(unit_id);
create index if not exists duo_sections_course_id_idx
  on public.duo_sections(course_id);
create index if not exists duo_units_section_id_idx
  on public.duo_units(section_id);

create index if not exists lexicon_characters_radical_id_idx
  on public.lexicon_characters(radical_id);
create index if not exists lexicon_examples_unit_id_idx
  on public.lexicon_examples(unit_id);
create index if not exists lexicon_speaking_practice_example_id_idx
  on public.lexicon_speaking_practice(example_id);
create index if not exists lexicon_speaking_practice_user_id_idx
  on public.lexicon_speaking_practice(user_id);
create index if not exists lexicon_speaking_practice_word_id_idx
  on public.lexicon_speaking_practice(word_id);
create index if not exists lexicon_user_progress_word_id_idx
  on public.lexicon_user_progress(word_id);
create index if not exists lexicon_word_sources_topic_id_idx
  on public.lexicon_word_sources(topic_id);
create index if not exists lexicon_word_sources_unit_id_idx
  on public.lexicon_word_sources(unit_id);
create index if not exists lexicon_word_sources_word_id_idx
  on public.lexicon_word_sources(word_id);
create index if not exists lexicon_word_topics_topic_id_idx
  on public.lexicon_word_topics(topic_id);
create index if not exists lexicon_word_units_unit_id_idx
  on public.lexicon_word_units(unit_id);
create index if not exists lexicon_words_main_character_id_idx
  on public.lexicon_words(main_character_id);
create index if not exists lexicon_words_part_of_speech_id_idx
  on public.lexicon_words(part_of_speech_id);
