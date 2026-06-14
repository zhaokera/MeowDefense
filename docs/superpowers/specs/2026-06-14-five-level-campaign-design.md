# Five-Level Campaign Design

## Goal

Build a complete five-level version of the cat tower-defense game. The game must have five playable levels, Image2-generated assets organized by category, animated characters rather than stiff static sprites, and automated self-play coverage proving each level can be cleared.

## Current State

The project currently has one JSON level, one tower definition, two enemies, and a small generated asset set under `assets/generated/`. Battle logic builds the map from JSON, spawns enemies, lets the player place one tower type, and emits a result when all waves are defeated or the base reaches zero HP.

## Scope

This pass adds:

- Five level JSON files: `level_001.json` through `level_005.json`.
- Generated asset directories:
  - `assets/generated/backgrounds/`
  - `assets/generated/towers/`
  - `assets/generated/enemies/`
  - `assets/generated/bases/`
  - `assets/generated/ui/`
- At least five level backgrounds, two tower character sheets, four enemy character sheets, one animated base asset, and useful UI thumbnails/badges where needed.
- Level selection support for all five levels.
- Battle support for level-specific allowed towers and animated units.
- Automated playthrough tests that simulate building towers and verify all five levels can be won.

## Campaign

1. `鱼干小路`: starter level with gentle mouse waves and obvious build slots.
2. `奶酪森林`: longer route and split build slots; introduces heavier enemies.
3. `月光粮仓`: faster enemies and tighter timings.
4. `溪边栈桥`: longer route, high-health enemies, and wider tower coverage requirements.
5. `终点守卫战`: mixed wave pressure using all enemy types and both tower types.

## Gameplay Additions

The existing `orange_cat` tower stays as the reliable single-target tower. Add `tabby_slow_cat`, a slower support tower that deals moderate damage and applies a brief speed slow to enemies. This keeps the five levels from becoming pure stat inflation while staying within a small implementation.

Enemy roster:

- `mouse_basic`: balanced starter enemy.
- `mouse_fast`: fast low-HP enemy.
- `rat_tank`: slower high-HP enemy.
- `hamster_runner`: very fast but fragile enemy.

## Animation Design

Generated character art will be consumed as sprite-sheet-like assets when practical. The code must also apply procedural animation so the characters never look like static stickers:

- Enemies bob and squash while moving, flash on hit, and fade/squash on defeat.
- Towers breathe while idle, rotate/lean toward targets, recoil when firing, and pulse on upgrade.
- Base shakes when hit and pulses red at low HP.

The automated tests verify animation support by checking that units expose animation nodes/state and by running a short simulated battle.

## Asset Rules

All final project-referenced raster assets must live in the categorized `assets/generated/*/` directories, not only under Codex default generated-image storage. The manifest records each asset id, role, destination path, and prompt summary. Existing root-level generated assets may remain for compatibility but new level and character references must use categorized paths.

## Test Strategy

Add tests before implementation:

- Level data test: five level files load, have unique ids, at least three waves, at least five build slots, existing background/base assets, and valid tower/enemy ids.
- Asset manifest test: required categories and project-referenced assets are present.
- Animation test: tower, enemy, and battle base create animation-capable visuals.
- Playthrough test: for each level, instantiate the battle scene, auto-build available towers on recommended slots, simulate time, and assert victory with at least one star.

Existing unit, scene smoke, and menu tests remain part of the verification suite.

## Non-Goals

No shop economy, persistent progression database, online sharing, or complex skill tree is added in this pass. The point is to make the current prototype feel like a small complete tower-defense game with enough content and polish to test.
