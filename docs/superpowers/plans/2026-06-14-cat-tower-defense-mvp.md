# Cat Tower Defense MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first playable level of a cozy cat-themed tower defense game in the existing Godot 4.6 project.

**Architecture:** The MVP uses one main scene that switches between menu, level select, battle, and result screens. Battle logic is split into focused GDScript units for level data, enemies, towers, projectiles, and battle orchestration. Level content is loaded from JSON so later levels can be added without duplicating gameplay code.

**Tech Stack:** Godot 4.6.3, GDScript, JSON level config, Image2-generated PNG assets, headless Godot smoke tests.

---

### Task 1: Test Harness And Data Contract

**Files:**
- Create: `tests/run_unit_tests.gd`
- Create: `data/levels/level_001.json`

- [ ] **Step 1: Write failing tests**

Create a headless Godot test script that validates level config loading, tower targeting, enemy movement, and wave reward math.

- [ ] **Step 2: Verify red**

Run: `/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --script tests/run_unit_tests.gd`

Expected: non-zero exit because production scripts do not exist yet.

### Task 2: Core Battle Scripts

**Files:**
- Create: `scripts/core/level_data.gd`
- Create: `scripts/core/tower_stats.gd`
- Create: `scripts/battle/enemy.gd`
- Create: `scripts/battle/projectile.gd`
- Create: `scripts/battle/tower.gd`
- Create: `scripts/battle/build_slot.gd`
- Create: `scripts/battle/battle_scene.gd`

- [ ] **Step 1: Implement minimal logic**

Implement JSON loading, enemy path traversal, tower range targeting, projectile damage, build slot state, and battle orchestration.

- [ ] **Step 2: Verify green**

Run the same headless Godot test command. Expected: exit code 0.

### Task 3: Screens And Project Entry

**Files:**
- Create: `scripts/app/main.gd`
- Create: `scenes/main.tscn`
- Modify: `project.godot`

- [ ] **Step 1: Add app shell**

Create menu, level select, battle, and result flows. Set `run/main_scene` to `res://scenes/main.tscn`.

- [ ] **Step 2: Verify project imports**

Run: `/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhaok/cat --import --quit`

Expected: exit code 0.

### Task 4: Generated Assets

**Files:**
- Create: `assets/generated/level_001_meadow.png`
- Create: `assets/generated/cat_tower_orange.png`
- Create: `assets/generated/mouse_basic.png`
- Create: `assets/generated/mouse_fast.png`
- Create: `assets/generated/fish_base.png`
- Create: `assets/generated/assets_manifest.json`

- [ ] **Step 1: Generate Image2 assets**

Use the built-in image generation tool for the meadow map, cat tower, two enemies, and base object. Save final project-bound PNGs under `assets/generated/`.

- [ ] **Step 2: Wire assets**

Reference these PNG files from level config and gameplay scripts.

### Task 5: Final Verification

**Files:**
- Verify: all created scripts, scene, config, and generated assets

- [ ] **Step 1: Run tests**

Run headless unit tests and project import.

- [ ] **Step 2: Run short editor smoke**

Run: `/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --path /Users/zhaok/cat --editor --quit-after 120`

Expected: plugin and project load without fatal script parse errors.
