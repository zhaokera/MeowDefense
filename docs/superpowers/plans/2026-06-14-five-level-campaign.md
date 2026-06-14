# Five-Level Campaign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Add a five-level playable cat tower-defense campaign with categorized Image2 assets, animated characters, and automated playthrough verification.

**Architecture:** Keep the existing JSON-driven Godot battle scene, but expand data and animation behavior in place. New assets are organized under categorized `assets/generated/*` folders and recorded in the manifest. Tests prove the content contract before and after implementation.

**Tech Stack:** Godot 4.6 GDScript, JSON level configs, built-in Image2/Image Gen for raster assets, Godot SceneTree test scripts.

---

### Task 1: Content Contract Tests

**Files:**
- Create: `tests/run_campaign_tests.gd`
- Create: `tests/run_playthrough_tests.gd`
- Modify: `tests/run_unit_tests.gd`

- [x] Write `run_campaign_tests.gd` to assert five level files exist, ids 1-5 are unique, all referenced backgrounds/base textures exist, each level has at least five build slots and three waves, and every tower/enemy id exists in `TowerStats`.
- [x] Write `run_playthrough_tests.gd` to load each level into `CatDefenseBattleScene`, build towers on all slots when enough coins are available, simulate frames until finished, and fail if the level is not won.
- [x] Extend unit tests to assert animation support exists on enemy and tower instances.
- [x] Run the new tests and verify they fail because levels/assets/animation support do not exist yet.

### Task 2: Image2 Asset Generation And Organization

**Files:**
- Create directories under `assets/generated/backgrounds`, `assets/generated/towers`, `assets/generated/enemies`, `assets/generated/bases`, `assets/generated/ui`
- Modify: `assets/generated/assets_manifest.json`

- [x] Generate five 1280x720 battle backgrounds using Image2: meadow, cheese forest, moon granary, creek bridge, final pantry.
- [x] Generate two tower character sheets using Image2: orange cat cannon and tabby slow cat yarn tower.
- [x] Generate four enemy character sheets using Image2: basic mouse, fast mouse/hamster, tank rat, runner hamster.
- [x] Generate or move one base asset into `assets/generated/bases/`.
- [x] Copy generated files from Codex default generated-image storage into the categorized asset folders with stable filenames.
- [x] Update `assets_manifest.json` with id, role, category, path, and prompt summary for every final asset.

### Task 3: Data Expansion

**Files:**
- Modify: `scripts/core/tower_stats.gd`
- Modify: `data/levels/level_001.json`
- Create: `data/levels/level_002.json`
- Create: `data/levels/level_003.json`
- Create: `data/levels/level_004.json`
- Create: `data/levels/level_005.json`

- [x] Add `tabby_slow_cat` to `TowerStats.TOWERS` with cost, range, damage, fire interval, slow fields, texture, and accent.
- [x] Add `rat_tank` and `hamster_runner` to `TowerStats.ENEMIES`; update existing enemies to categorized paths.
- [x] Write five balanced level configs with distinct path points, build slots, start coins, rewards, allowed towers, and wave mixes.
- [x] Run campaign contract tests and verify failures now only point at unimplemented code or balance.

### Task 4: Animated Units And Battle Feedback

**Files:**
- Modify: `scripts/battle/enemy.gd`
- Modify: `scripts/battle/tower.gd`
- Modify: `scripts/battle/battle_scene.gd`

- [x] Add movement bob/squash, hit flash, slow status, and defeat animation to enemies.
- [x] Add idle breathing, target-facing/recoil feedback, and slow application support to towers.
- [x] Add base node state in battle scene with hit shake and low-health pulse.
- [x] Ensure animations are procedural fallback even when generated art is a single image.
- [x] Run unit and campaign tests until animation assertions pass.

### Task 5: Five-Level Menu Flow

**Files:**
- Modify: `scripts/app/main.gd`
- Modify: `tests/run_menu_tests.gd`

- [x] Update level select to render all five levels from a small level list instead of one hard-coded card.
- [x] Track best stars per level and total fish rewards.
- [x] Start the selected level path and return results to the correct level record.
- [x] Update menu tests to click at least level one and verify all five level buttons exist.

### Task 6: Playthrough Balance And Verification

**Files:**
- Modify: `tests/run_playthrough_tests.gd`
- Modify level JSON/stats as needed.

- [x] Run playthrough tests.
- [x] If a level fails, inspect whether the failure is balance, pathing, or automation strategy.
- [x] Adjust wave counts, enemy HP/speed/rewards, start coins, or recommended build strategy until all five levels are won by the automated player.
- [x] Run final suite: campaign tests, playthrough tests, menu tests, scene smoke, and unit tests.

### Task 7: Evidence And Handoff

**Files:**
- Create: `artifacts/campaign_asset_inventory.md`
- Create/Update: `design-qa.md`

- [x] Write asset inventory with categorized paths and note Image2 generation prompts.
- [x] Capture at least one level/menu screenshot if Godot rendering is available.
- [x] Update QA notes with final test commands and outcomes.
- [x] Keep the goal active until all explicit requirements are verified.
