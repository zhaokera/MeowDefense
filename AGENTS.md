# MeowDefense Agent Rules

These rules apply to all future work in this repository.

## Core Direction

- Treat MeowDefense as a polished mobile-style cat tower-defense game, not a plain Godot prototype.
- Follow the current home screen production model: Image2 first, Godot implementation second.
- Visible game UI should come from generated raster design assets whenever practical. Do not rebuild polished screens with default Godot panels, flat colors, or hand-coded faux art.

## Image2-First Workflow

For every player-facing screen or major visual feature:

1. Generate a full-page Image2 design mockup for the target screen.
2. Generate or extract the matching assets needed for dynamic parts: buttons, badges, panels, icons, rewards, tower cards, enemy cards, effects, and state overlays.
3. Copy final project-bound images into categorized project folders under `assets/generated/`.
4. Update `assets/generated/assets_manifest.json` and any relevant inventory or QA notes.
5. Implement the screen in Godot using the generated artwork as the visual source of truth.

Use full-screen Image2 designs plus transparent hit areas for mostly static menu screens. Use separate Image2 UI pieces for dynamic screens where state must change, such as battle HUD, rewards, health, coins, stars, and unlock status.

When a full-screen Image2 design already contains a static visual element, do not visibly stack the same cropped asset over it. Use dynamic labels, state-specific images, or transparent hit areas only where the runtime value or interaction needs to change.

## No Hard-Coded Visual UI

- Do not hand-code visible premium UI panels, title plaques, ornate buttons, wooden boards, badges, icons, or reward cards when Image2 can provide the visual.
- Godot code may create transparent buttons, hit areas, containers, state machines, labels for truly dynamic values, animation players, and runtime effects.
- Simple debug-only or invisible layout nodes are fine, but they must not define the final look of a player-facing screen.
- If a code-drawn UI element is unavoidable, document why in `design-qa.md`.

## Interaction And Motion

Every player-facing control should have tactile feedback:

- Buttons: press scale, bounce, glow, or depressed-state feedback.
- Page transitions: slide, fade, pop-in, or staged reveal.
- Rewards: fish/star fly-in, sparkle, count-up, or pulse.
- Battle actions: build, upgrade, sell, enemy hit, slow, base damage, and victory/failure feedback.
- Cards and tabs: selected state, hover/focus if applicable, and click response.

Avoid stiff static screens. Generated images provide the visual base; Godot should add life through animation and state feedback.

## Gameplay Improvements

Prefer work that makes the game more complete and playable:

- Level unlock and best-star persistence.
- Tests that touch persistence must use an isolated `user://` save path instead of deleting or overwriting the real player save.
- Tower upgrade, sell/cancel, and clearer tower selection.
- Wave preview, speed-up, pause/restart, and next-level flow.
- Reward collection, failure guidance, and post-level progression.
- Functional atlas/encyclopedia, settings, backpack, shop, and achievements screens.
- Clear build affordances: visible build buttons, sufficient hit targets, and immediate feedback.

## Asset Organization

- Backgrounds: `assets/generated/backgrounds/`
- UI screens and UI pieces: `assets/generated/ui/`
- Towers: `assets/generated/towers/`
- Enemies: `assets/generated/enemies/`
- Bases: `assets/generated/bases/`
- Effects: `assets/generated/effects/`

Never leave a project-referenced generated asset only in `$CODEX_HOME/generated_images/`. Copy it into the project and reference it through `res://`.

## Verification

Before calling work complete:

- Capture screenshots for changed player-facing screens.
- Visually compare implemented screens against their Image2 design references.
- Run relevant Godot tests. For broad UI/gameplay changes, run:

```bash
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_campaign_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_playthrough_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_menu_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_album_overlay_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_album_entry_detail_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_reward_overlay_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_daily_reward_reset_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_daily_task_overlay_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_daily_task_reset_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_town_feature_overlay_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_backpack_item_detail_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_backpack_organize_reward_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_achievement_claim_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_shop_yarn_trap_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_shop_paw_bundle_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_battle_yarn_trap_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_battle_yarn_inventory_flow_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_build_input_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_tower_action_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_battle_speed_wave_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_progression_persistence_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_pause_menu_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_result_screen_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_result_defeat_screen_tests.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_scene_smoke.gd
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_unit_tests.gd
```

Update `design-qa.md` with what changed, what screenshots prove it, and what tests passed.

## Git Hygiene

- Keep `.godot/`, `.agents/`, and local cache files out of commits.
- Keep generated assets that the project uses in git unless they are temporary rejected variants.
- Commit focused changes with clear messages and push to `origin/master` when the user asks to publish or continue the GitHub project state.
