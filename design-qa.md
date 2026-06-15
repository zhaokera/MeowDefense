**Source Visual Truth**
- Path: `/Users/zhaok/.codex/generated_images/019ec20a-5a2a-7b71-9540-c2f350624b39/ig_0038e85426156fa1016a2d95d49ae48191988d09dad216b911.png`
- State: main menu, direction 1
- Viewport: 1280 x 720 landscape target

**Implementation Evidence**
- Screenshot: `/Users/zhaok/cat/artifacts/main_menu.png`
- Full-view comparison: `/Users/zhaok/cat/artifacts/main_menu_comparison.png`
- State: main menu after loading `res://scenes/main.tscn`
- Viewport: 1280 x 720
- Focused region comparison: not needed for blocking QA because the full-view comparison keeps the title, primary actions, top resources, event badge, bottom nav, mascot, and mission card readable at the matched 16:9 viewport.

**Findings**
- No actionable P0/P1/P2 findings remain.

**Required Fidelity Surfaces**
- Fonts and typography: Implementation uses Godot default font with larger rounded-feeling Chinese labels. It does not match the illustrated lettering in the concept exactly, but text hierarchy and readability are acceptable for this implementation pass.
- Spacing and layout rhythm: Main call-to-action cluster, top resource strip, event badge, bottom navigation, mascot focus, and mission panel align to the selected direction. No visible overlap or cropped UI remains.
- Colors and visual tokens: Bright grass, cream panels, orange primary actions, blue/green secondary actions, and red event/reward accents match the selected sunny tower-defense direction.
- Image quality and asset fidelity: Uses existing project raster assets for the meadow map, cat tower, mouse, and fish base. The earlier oversized cat tower overflow was fixed by switching menu decoration assets to scaled `Sprite2D` nodes.
- Copy and content: Main menu, settings, album, level select, pause, and result copy are app-specific and match the cat-defense theme.

**Patches Made Since Previous QA Pass**
- Replaced overflowing menu decoration `TextureRect` usage with proportionally scaled `Sprite2D` assets.
- Moved the cat tower mascot to the battlefield center and moved the mission card to the right side.
- Increased the resource plus button width so the control is readable.

**Implementation Checklist**
- Main menu exposes start, level, settings, album, and reward actions.
- Level select supports back navigation and level one launch.
- Settings overlay supports music, effects, volume, and close controls.
- Album overlay opens and closes with game entities.
- Battle pause opens a full menu with resume, restart, settings, and quit-to-levels.
- Result screen supports retry and returning to level select.

**Follow-up Polish**
- P3: Replace plain Godot text title with a generated wooden title plaque asset for closer concept fidelity.
- P3: Add custom icon image assets to bottom navigation and resource counters.

final result: passed

---

**Five-Level Campaign QA**
- Level configs: `/Users/zhaok/cat/data/levels/level_001.json` through `/Users/zhaok/cat/data/levels/level_005.json`
- Asset manifest: `/Users/zhaok/cat/assets/generated/assets_manifest.json`
- Asset inventory: `/Users/zhaok/cat/artifacts/campaign_asset_inventory.md`
- Main menu screenshot: `/Users/zhaok/cat/artifacts/main_menu.png`
- Level select screenshot: `/Users/zhaok/cat/artifacts/level_select.png`

**Campaign Findings**
- No actionable P0/P1/P2 findings remain for the requested campaign scope.

**Campaign Verification Surfaces**
- Five playable levels: verified by campaign contract and automated playthrough tests.
- Image2 asset organization: verified by categorized folders, imported `.png.import` files, and `assets_manifest.json`.
- Character animation: verified by runtime animation support checks for every tower ID, every enemy ID, and the base object; implementation includes procedural motion so single-image assets are not static.
- Passability: verified by `run_playthrough_tests.gd`, which simulates each level to victory with at least one star.
- UI flow: verified by `run_menu_tests.gd`, including five level buttons, level-card layout bounds, clipped thumbnail art, and the slow-tower selector on level two.

**Final Campaign Polish**
- Re-captured `/Users/zhaok/cat/artifacts/main_menu.png` and `/Users/zhaok/cat/artifacts/level_select.png`.
- Fixed the level-select mission panel spacing and switched level cards to a stable centered 3+2 layout.
- Added `/Users/zhaok/cat/tests/capture_level_select.gd` so the level-select screenshot can be regenerated without a temporary script.

**Build Interaction Fix**
- Added visible build buttons on every cat-paw build slot so players can actually construct towers from the battle screen.
- Added a map-click fallback for empty build slots and enlarged the slot radius from 32 to 44.
- Added `/Users/zhaok/cat/tests/run_build_input_tests.gd` to verify pressing a visible build slot button builds a tower and spends fish.
- Captured `/Users/zhaok/cat/artifacts/battle_level_001.png` showing the new build buttons.

**Image2 Main Menu Restoration**
- Replaced the code-built main menu panels with the Image2 design reference asset at `/Users/zhaok/cat/assets/generated/ui/main_menu_design_reference.png`.
- Main menu controls are now transparent hit areas over the generated design, so the visible UI comes from the Image2 artwork rather than reconstructed Godot panels.
- Added menu-test assertions that the main menu uses `Image2DesignBackground` and no longer creates the old `TitleBadge` or `HeroPanel` code panels.
- Latest screenshot: `/Users/zhaok/cat/artifacts/main_menu.png`.

**Image2 Level Select Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/level_select_design_reference.png`.
- Replaced the code-built level cards, title, mission panel, and bottom navigation with the Image2 level-select design plus transparent level, settings, and navigation hit areas.
- Updated `run_menu_tests.gd` to require `LevelSelectDesignBackground` and reject the old code-drawn `LevelTitle`, `LevelMissionPanel`, `LevelCard1`, and `BottomNav` nodes.
- Latest screenshot: `/Users/zhaok/cat/artifacts/level_select.png`.

**Image2 Battle HUD Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/battle_hud_design_reference.png` as the full-page battle HUD design reference.
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_hud_asset_sheet_source.png` and cropped transparent runtime assets for the top resource bar, bottom build dock, pause button, and cat-paw build marker.
- Replaced the old code-drawn `BattleTopBar`, `BuildPanel`, pause button styling, and build-slot circle drawings with `TextureRect` Image2 assets plus transparent interaction layers.
- Added button press feedback on build markers, tower selector hotspots, and the pause control.
- Updated `run_build_input_tests.gd` to require the battle HUD Image2 nodes and reject the old code-drawn top/build panels.
- Latest screenshot: `/Users/zhaok/cat/artifacts/battle_level_001.png`.

**Image2 Tower Action Panel**
- Generated `/Users/zhaok/cat/assets/generated/ui/tower_action_panel.png` as a transparent Image2 battle management panel with upgrade, sell, and close action areas.
- Occupied build-slot buttons now stay clickable and open `TowerActionOverlay` instead of becoming dead controls.
- Added upgrade behavior that spends fish and refreshes tower level/range/damage labels, plus sell behavior that refunds fish and frees the build slot.
- Added pop-in/button feedback for the management panel and `/Users/zhaok/cat/tests/run_tower_action_tests.gd` to verify Image2 panel use, upgrade, sell, refund, and slot reuse.
- Added `/Users/zhaok/cat/tests/capture_tower_action.gd` to regenerate `/Users/zhaok/cat/artifacts/tower_action_overlay.png`.

**Image2 Pause Menu Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/battle_pause_menu_design_reference.png` as the full-page pause overlay design reference.
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_pause_menu_asset_sheet_source.png` and cropped transparent runtime assets for the pause panel plus continue, restart, settings, and quit button frames.
- Replaced the old code-drawn `PausePanel` and pause menu button styles with `TextureRect` Image2 assets plus transparent hit areas.
- Added press feedback to all pause menu actions while keeping resume, restart, settings, and quit behavior intact.
- Added `/Users/zhaok/cat/tests/run_pause_menu_tests.gd` to require the Image2 pause assets and reject the old `PausePanel`.
- Latest screenshot: `/Users/zhaok/cat/artifacts/pause_menu.png`.

**Image2 Settings Overlay Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/settings_overlay_design_reference.png` as the full-page settings dialog design reference.
- Generated `/Users/zhaok/cat/assets/generated/ui/settings_overlay_asset_sheet_source.png` and cropped transparent runtime assets for the settings panel, on/off toggles, volume slider track, fish knob, and confirm button.
- Replaced the old code-drawn `SettingsPanel` with `SettingsDesignPanel` and hid the default CheckButton/HSlider visuals behind Image2 frames.
- Kept music, effects, volume, and close interactions intact with transparent input layers and Image2 click feedback.
- Updated `/Users/zhaok/cat/tests/run_menu_tests.gd` to require the settings Image2 assets and reject the old `SettingsPanel`.
- Latest screenshot: `/Users/zhaok/cat/artifacts/settings_overlay.png`.

**Image2 Battle Pause Settings Restoration**
- Replaced the code-drawn battle pause settings `Panel` with the shared Image2 settings panel, toggles, slider track, fish knob, and confirm button assets.
- Added transparent toggles, slider, and close hit areas on top of the Image2 visuals while preserving pause state and returning to the main pause menu after closing.
- Hidden pause-menu controls while the secondary settings dialog is open so translucent Image2 button art does not reveal stale underlying menu labels.
- Updated `/Users/zhaok/cat/tests/run_pause_menu_tests.gd` to require the Image2 settings assets, reject the old code panel, and verify menu controls hide and restore.
- Added `/Users/zhaok/cat/tests/capture_pause_settings.gd` to regenerate the battle pause settings screenshot.
- Latest screenshot: `/Users/zhaok/cat/artifacts/pause_settings.png`.

**Image2 Result Screen Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/result_screen_design_reference.png` as the full-page victory result design reference.
- Generated `/Users/zhaok/cat/assets/generated/ui/result_screen_asset_sheet_source.png` and cropped transparent result button, panel, resource, star, and fish reward assets.
- Replaced the old code-drawn `ResultPanel`, `ResourceStrip`, and right-side result button layout with the full-screen Image2 result design plus bottom Image2 action frames and transparent hit areas.
- Kept retry, level-map, next-level, fish reward, best stars, and progress behavior intact while adding button press feedback through the shared Image2 feedback helper.
- Added `ResultRewardCelebrationLayer` for wins, using Image2 `result_star_badge.png` and `result_fish_chip.png` as reward pulse/fly-in pieces without changing the full-screen result design background.
- Added `/Users/zhaok/cat/tests/run_result_screen_tests.gd` to require the Image2 result design/buttons and reject the old result panel/resource strip.
- Latest screenshot: `/Users/zhaok/cat/artifacts/result_screen.png`.

**Image2 Defeat Result Screen**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/result_screen_defeat_design_reference.png` as the full-page failed-level result design reference.
- Failed result now uses `RESULT_SCREEN_DEFEAT_DESIGN` while victory continues using `RESULT_SCREEN_DESIGN`.
- Defeat next-level slot uses the Image2 background's locked button visual plus a disabled transparent hit area, avoiding a victory `ResultNextFrame` overlay.
- Defeat result explicitly skips `ResultRewardCelebrationLayer`, so reward pulse/fly-in feedback remains victory-only.
- Added `/Users/zhaok/cat/tests/run_result_defeat_screen_tests.gd` to require the defeat design, disabled next-level action, and no progress reward on failure.
- Added `/Users/zhaok/cat/tests/capture_result_defeat_screen.gd` to regenerate the failed-level screenshot.
- Latest screenshot: `/Users/zhaok/cat/artifacts/result_defeat_screen.png`.

**Image2 Album Overlay Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/album_overlay_design_reference.png` as the full-page guide/encyclopedia design reference.
- Generated `/Users/zhaok/cat/assets/generated/ui/album_overlay_asset_sheet_source.png` and cropped transparent album panel, card frame, close button, and paw badge assets.
- Replaced the old code-drawn `AlbumPanel` and `AlbumTowerCard`/`AlbumMouseCard`/`AlbumBaseCard` panels with Image2 textures plus existing character sprites, dynamic labels, and transparent card/close hit areas.
- Added card press feedback and an overlay pop-in animation so the guide no longer feels like a static code panel.
- Added `/Users/zhaok/cat/tests/run_album_overlay_tests.gd` to require the Image2 album assets and reject the old code-drawn album nodes.
- Latest screenshot: `/Users/zhaok/cat/artifacts/album_overlay.png`.

**Album Entry Detail Overlay**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/album_entry_detail_design_reference.png` as the full-screen Image2 encyclopedia detail design.
- Album cards now open `AlbumEntryDetailOverlay` instead of only pulsing; the detail layer shows selected entry art, stats, description, close control, and a `去关卡` action.
- The detail action routes to the level select screen, turning the guide into a playable navigation path.
- Added `/Users/zhaok/cat/tests/run_album_entry_detail_tests.gd` to verify Image2 detail rendering, selected tower data, and action routing.
- Added `/Users/zhaok/cat/tests/capture_album_entry_detail.gd` to regenerate `/Users/zhaok/cat/artifacts/album_entry_detail.png`.

**Image2 Reward Overlay Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/reward_overlay_design_reference.png` as the full-page daily reward design reference.
- Generated `/Users/zhaok/cat/assets/generated/ui/reward_overlay_asset_sheet_source.png` and cropped transparent reward panel, fish chest, claim button, and reward chip assets.
- Replaced the old code-drawn `RewardPanel` with Image2 textures plus transparent hit areas and the shared pop-in/button feedback.
- Changed the reward action from a close-only button into a real one-time claim that adds 20 fish to `_total_fish`.
- Added `/Users/zhaok/cat/tests/run_reward_overlay_tests.gd` to require Image2 reward assets, reject `RewardPanel`, and verify the fish reward is granted.
- Latest screenshot: `/Users/zhaok/cat/artifacts/reward_overlay.png`.

**Daily Reward Reset And Streak**
- Upgraded the Image2 daily reward overlay from a permanent one-time claim into a date-based daily claim flow.
- Added `daily_reward_claimed_on` and `daily_reward_streak` save fields while keeping the old `daily_reward_claimed` field as a migration-compatible current-day state.
- Same-day claims now disable the transparent claim hit area, while the new transparent close hit area keeps the overlay dismissible.
- The reward overlay now shows a dynamic streak label on top of the existing Image2 reward panel without adding code-drawn visual panels.
- Added `/Users/zhaok/cat/tests/run_daily_reward_reset_tests.gd` to verify same-day lockout, reload persistence, next-day reset, and consecutive streak growth.
- Added `/Users/zhaok/cat/tests/capture_daily_reward_streak.gd` to regenerate `/Users/zhaok/cat/artifacts/daily_reward_streak.png`.

**Image2 Daily Task Overlay**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/daily_task_overlay_design_reference.png` as the full-screen daily task design reference.
- Replaced the old main-menu daily task shortcut-to-levels behavior with `DailyTaskOverlay`, using `DailyTaskDesignBackground`, dynamic task labels, transparent claim/close hit areas, and shared pop-in/click feedback.
- Added claimable daily tasks for first clear, 3-star progress, and yarn-trap readiness; claimed tasks grant fish, disable their claim button, and persist in `claimed_daily_tasks`.
- Added `/Users/zhaok/cat/tests/run_daily_task_overlay_tests.gd` to require the Image2 design, reject code-drawn task panels, verify reward grants, and verify persistence after reload.
- Added `/Users/zhaok/cat/tests/capture_daily_task_overlay.gd` to regenerate `/Users/zhaok/cat/artifacts/daily_task_overlay.png`.

**Daily Task Date Reset**
- Upgraded daily task claims from permanent one-time flags into date-bucketed claims saved in `claimed_daily_tasks_by_date`.
- Kept `claimed_daily_tasks` as the current-day compatibility snapshot so older save files migrate into today's task state.
- Same-day task claims stay disabled after reload, while the next date resets completed tasks to claimable again.
- Added `/Users/zhaok/cat/tests/run_daily_task_reset_tests.gd` to verify same-day lockout, reload persistence, next-day reset, repeat rewards, and date-bucket save state.
- Re-captured `/Users/zhaok/cat/artifacts/daily_task_overlay.png` after the persistence change.

**Energy Flow And Empty State**
- Generated `/Users/zhaok/cat/assets/generated/ui/energy_empty_overlay_design_reference.png` as a full-screen Image2 out-of-energy feedback design.
- Converted the static `15/15` energy display into persistent `_energy`, `_max_energy`, and `_energy_refilled_on` state.
- Starting a level now consumes 1 energy, zero energy blocks battle entry, and the Image2 `EnergyEmptyOverlay` explains the current energy state.
- Energy refills to max on the next real date through the same date-key helper used by daily rewards and tasks.
- Backpack and shop energy counters now show `_energy_text()` instead of hard-coded `15/15`.
- Added `/Users/zhaok/cat/tests/run_energy_flow_tests.gd` to verify consumption, zero-energy blocking, Image2 empty-state rendering, persistence, and next-day refill.
- Added `/Users/zhaok/cat/tests/capture_energy_empty_overlay.gd` to regenerate `/Users/zhaok/cat/artifacts/energy_empty_overlay.png`.

**Image2 Town Feature Overlay Restoration**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/backpack_overlay_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/achievements_overlay_design_reference.png`, and `/Users/zhaok/cat/assets/generated/ui/shop_overlay_design_reference.png`.
- Replaced the main-menu bottom `背包`, `成就`, and `商店` proxy behavior with distinct Image2 full-screen overlays plus transparent close/action hit areas.
- Added overlay pop-in and press feedback, and made the shop starter pack grant a one-time `+15` fish reward instead of being a static placeholder.
- Added `/Users/zhaok/cat/tests/run_town_feature_overlay_tests.gd` to require the three Image2 design backgrounds, prevent reward/album proxy reuse, and verify the shop grant state.
- Added `/Users/zhaok/cat/tests/capture_town_feature_overlays.gd` to regenerate backpack, achievements, and shop screenshots.
- Latest screenshots: `/Users/zhaok/cat/artifacts/backpack_overlay.png`, `/Users/zhaok/cat/artifacts/achievements_overlay.png`, `/Users/zhaok/cat/artifacts/shop_overlay.png`.

**Backpack Item Detail Overlay**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/backpack_item_detail_design_reference.png` as the Image2 full-screen item detail design.
- Backpack item buttons now open `BackpackItemDetailOverlay` instead of only pulsing the page; the detail layer shows the selected item icon, owned count, explanatory copy, close control, and contextual action button.
- Yarn trap details use `/Users/zhaok/cat/assets/generated/ui/yarn_trap_item_icon.png` and route `去战斗` to the level select screen.
- Added `/Users/zhaok/cat/tests/run_backpack_item_detail_tests.gd` to verify Image2 detail rendering, selected item data, and action routing.
- Added `/Users/zhaok/cat/tests/capture_backpack_item_detail.gd` to regenerate `/Users/zhaok/cat/artifacts/backpack_item_detail.png`.

**Backpack Organize Reward**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/backpack_organize_reward_design_reference.png` as the Image2 full-screen organize reward design.
- `OrganizeBackpackButton` now grants a one-time `+5` fish reward, updates the backpack fish counter, disables itself as `已整理`, and persists `_backpack_organized`.
- The reward appears in `BackpackOrganizeRewardOverlay` with the Image2 background, fish chip, dynamic reward amount, close control, and confirmation button.
- Added `/Users/zhaok/cat/tests/run_backpack_organize_reward_tests.gd` to verify reward grant, Image2 overlay, counter refresh, disabled state, and persistence after reload.
- Added `/Users/zhaok/cat/tests/capture_backpack_organize_reward.gd` to regenerate `/Users/zhaok/cat/artifacts/backpack_organize_reward.png`.

**Achievement Claim Rewards**
- Generated `/Users/zhaok/cat/assets/generated/ui/achievement_claimed_stamp.png` as a transparent Image2 cat-paw claimed stamp for achievement rows.
- Added claimable achievement rewards for first clear, 15-star collection, and full campaign completion; rewards grant fish and cat-paw badges, then persist in `claimed_achievements` and `paw_tokens`.
- Backpack now reflects the current cat-paw badge count from achievement rewards.
- Added `/Users/zhaok/cat/tests/run_achievement_claim_tests.gd` to verify Image2 achievement visuals, reward grants, persistence, and backpack badge count.
- Added `/Users/zhaok/cat/tests/capture_achievement_claimed.gd` to regenerate `/Users/zhaok/cat/artifacts/achievements_claimed_overlay.png`.

**Shop Yarn Trap Purchase**
- Generated `/Users/zhaok/cat/assets/generated/ui/yarn_trap_item_icon.png` as a transparent Image2 yarn trap item icon for the shop inventory flow.
- Converted the shop's yarn trap product from a locked placeholder into a purchasable 25-fish item that increments `_yarn_traps`, updates the fish counter, persists through saves, and appears in the backpack count.
- Kept the shop and backpack full-screen Image2 designs as the visual base, adding only dynamic labels, the small Image2 item badge, and transparent hit areas.
- Added `/Users/zhaok/cat/tests/run_shop_yarn_trap_tests.gd` to verify purchase, cost, inventory count, persistence, and backpack display.
- Added `/Users/zhaok/cat/tests/capture_shop_yarn_trap.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_yarn_trap_purchase.png` and `/Users/zhaok/cat/artifacts/backpack_yarn_trap_item.png`.

**Shop Paw Bundle Purchase**
- Reused `/Users/zhaok/cat/assets/generated/ui/album_paw_badge.png` as the Image2 item badge for the shop paw bundle.
- Converted the shop's paw bundle product from a locked placeholder into a purchasable 45-fish item that grants 2 `_paw_tokens`, updates the fish counter, persists through saves, and appears in the backpack badge count.
- Kept the shop and backpack full-screen Image2 designs as the visual base, adding only dynamic labels, the small Image2 item badge, and transparent hit areas.
- Added `/Users/zhaok/cat/tests/run_shop_paw_bundle_tests.gd` to verify purchase, cost, badge count, persistence, and backpack display.
- Added `/Users/zhaok/cat/tests/capture_shop_paw_bundle.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_paw_bundle_purchase.png`.

**Shop Energy Refill Purchase**
- Added `BuyShopEnergyRefillButton` as a transparent hit area over the Image2 shop energy `+` control.
- Buying energy refill spends 10 fish, restores up to 5 energy, refreshes the shop fish and energy counters, persists through saves, and allows level entry immediately.
- Kept the Image2 shop design as the visual base; only dynamic status text and transparent interaction were added around the existing energy resource strip.
- Added `/Users/zhaok/cat/tests/run_shop_energy_refill_tests.gd` to verify affordability, purchase cost, energy restore, persistence, and post-refill battle entry.
- Added `/Users/zhaok/cat/tests/capture_shop_energy_refill.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_energy_refill_purchase.png`.

**Battle Yarn Trap Consumable**
- Generated `/Users/zhaok/cat/assets/generated/ui/yarn_trap_field_effect.png` as a transparent Image2 battlefield yarn snare effect.
- Battle HUD now exposes `YarnTrapHudIcon`, `YarnTrapCountLabel`, and `UseYarnTrapButton` using the Image2 item icon plus transparent interaction layer.
- Pressing the trap button consumes one saved inventory item, emits `yarn_traps_changed`, slows active enemies near the target, and shows `YarnTrapFieldEffectN` on the battlefield.
- Main scene passes `_yarn_traps` into `CatDefenseBattleScene` before level start and persists the reduced count when a trap is used.
- Added `/Users/zhaok/cat/tests/run_battle_yarn_trap_tests.gd` and `/Users/zhaok/cat/tests/run_battle_yarn_inventory_flow_tests.gd` to verify battle behavior, inventory handoff, and save persistence.
- Added `/Users/zhaok/cat/tests/capture_battle_yarn_trap.gd` to regenerate `/Users/zhaok/cat/artifacts/battle_yarn_trap.png`.

**Progression Persistence And Level Locking**
- Generated `/Users/zhaok/cat/assets/generated/ui/level_lock_badge.png` as a transparent Image2 cat-paw lock badge for locked level cards.
- Added persistent progress at `user://meow_defense_save.json` for best stars by level, total fish, unlocked level, reward claims, and basic settings.
- Fresh progress now unlocks only level 1; winning a level unlocks the next level and writes the save before the result screen appears.
- Level-select locked cards keep the Image2 map as the visual source of truth and add only `LevelNLockedBadge` Image2 texture overlays plus disabled transparent hit areas.
- Added `/Users/zhaok/cat/tests/run_progression_persistence_tests.gd` to verify fresh locks, save creation, reload restore, and next-level unlock behavior without touching the real player save.
- Added `/Users/zhaok/cat/tests/capture_level_select_locked.gd` to regenerate `/Users/zhaok/cat/artifacts/level_select_locked.png`.

**Battle Wave Preview And Speed Control**
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_chip.png` and `/Users/zhaok/cat/assets/generated/ui/battle_speed_button.png` as transparent Image2 HUD assets.
- Added `WavePreviewFrame` and `WavePreviewLabel` to show the next/current wave enemy, count, and countdown without drawing a code panel.
- Added `SpeedControlFrame`, `SpeedToggleButton`, and `SpeedMultiplierLabel` so players can toggle battle simulation between 1x and 2x with press feedback.
- Added `/Users/zhaok/cat/tests/run_battle_speed_wave_tests.gd` to verify Image2 asset use, 1x/2x state, doubled process-time simulation, and live wave preview updates.

**Battle Resource Shortage Feedback**
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_resource_shortage_design_reference.png` as the full-screen Image2 direction for insufficient-fish battle feedback.
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_resource_shortage_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/battle_resource_shortage_burst.png` for runtime use.
- Build and upgrade failures now show `BattleResourceFeedback`, using the Image2 burst with dynamic Chinese shortage text, pop-in, shake, and fade feedback instead of relying only on the bottom tip label.
- Added `/Users/zhaok/cat/tests/run_battle_resource_feedback_tests.gd` to verify insufficient build and upgrade actions preserve coins/tower state and show the Image2 feedback asset.
- Added `/Users/zhaok/cat/tests/capture_battle_resource_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/battle_resource_shortage_feedback.png`.

**Battle Base Damage Feedback**
- Generated `/Users/zhaok/cat/assets/generated/ui/base_damage_warning_design_reference.png` as the full-screen Image2 direction for cat-food base damage feedback.
- Generated `/Users/zhaok/cat/assets/generated/ui/base_damage_warning_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/base_damage_warning_burst.png` for runtime use.
- Enemies reaching the base now show `BaseDamageFeedback` near the protected cat-food jar, using the Image2 burst with dynamic damage text, pop-in, shake, upward drift, and fade feedback.
- The base HP label refreshes immediately when damage lands and gets a pulse, while the existing base sprite shake/red flash remains active.
- Added `/Users/zhaok/cat/tests/run_base_damage_feedback_tests.gd` to verify base HP loss and Image2 warning rendering.
- Added `/Users/zhaok/cat/tests/capture_base_damage_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/base_damage_feedback.png`.

**Battle Enemy Reward Feedback**
- Generated `/Users/zhaok/cat/assets/generated/ui/enemy_reward_feedback_design_reference.png` as the full-screen Image2 direction for enemy defeat reward feedback.
- Generated `/Users/zhaok/cat/assets/generated/ui/enemy_reward_fish_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/enemy_reward_fish_burst.png` for runtime use.
- Defeated enemies now show `EnemyRewardFeedbackN` near the battle path, using the Image2 fish burst with dynamic reward text, pop-in, wobble, upward drift, and fade feedback.
- The fish counter refreshes immediately and gets a pulse when the enemy reward is granted.
- Added `/Users/zhaok/cat/tests/run_enemy_reward_feedback_tests.gd` to verify fish reward accounting and Image2 reward rendering.
- Added `/Users/zhaok/cat/tests/capture_enemy_reward_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/enemy_reward_feedback.png`.

**Battle Enemy Hit Feedback**
- Generated `/Users/zhaok/cat/assets/generated/effects/enemy_hit_feedback_design_reference.png` as the full-screen Image2 direction for tower hit feedback.
- Generated `/Users/zhaok/cat/assets/generated/effects/enemy_hit_fish_spark_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/effects/enemy_hit_fish_spark.png` for runtime use.
- Built towers now connect their `fired` signal into the battle scene and show `EnemyHitFeedbackN` at the target position using the Image2 fishbone sparkle.
- The hit effect pops, rotates, drifts, and fades quickly so tower attacks feel less stiff without covering build controls.
- Added `/Users/zhaok/cat/tests/run_enemy_hit_feedback_tests.gd` to verify real tower damage and Image2 hit feedback rendering.
- Added `/Users/zhaok/cat/tests/capture_enemy_hit_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/enemy_hit_feedback.png`.

**Battle Enemy Defeat Feedback**
- Generated `/Users/zhaok/cat/assets/generated/effects/enemy_defeat_feedback_design_reference.png` as the full-screen Image2 direction for nonviolent enemy defeat feedback.
- Generated `/Users/zhaok/cat/assets/generated/effects/enemy_defeat_mouse_puff_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/effects/enemy_defeat_mouse_puff.png` for runtime use.
- Defeated enemies now show `EnemyDefeatFeedbackN` at the defeated enemy position using the Image2 cat-paw dust puff, fishbone crumbs, stars, and mouse tail/ear silhouette.
- The fish reward feedback now offsets to the side of the defeated enemy so the defeat puff remains readable instead of being covered by the reward card.
- Added `/Users/zhaok/cat/tests/run_enemy_defeat_feedback_tests.gd` to verify enemy list removal, Image2 defeat feedback rendering, and no reward/defeat overlap.
- Added `/Users/zhaok/cat/tests/capture_enemy_defeat_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/enemy_defeat_feedback.png`.

**Battle Build Success Feedback**
- Generated `/Users/zhaok/cat/assets/generated/effects/build_success_feedback_design_reference.png` as the full-screen Image2 direction for successful tower construction feedback.
- Generated `/Users/zhaok/cat/assets/generated/effects/build_success_cat_paw_puff_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/effects/build_success_cat_paw_puff.png` for runtime use.
- Successful builds now show `BuildSuccessFeedbackN` at the build slot using the Image2 cat-paw puff, fish snacks, and star sparkles.
- The build feedback pops, rotates, drifts, and fades quickly so placing a tower has an immediate tactile response without blocking controls.
- Added `/Users/zhaok/cat/tests/run_build_success_feedback_tests.gd` to verify real build creation and Image2 build feedback rendering.
- Added `/Users/zhaok/cat/tests/capture_build_success_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/build_success_feedback.png`.

**Battle Tower Upgrade Feedback**
- Generated `/Users/zhaok/cat/assets/generated/effects/tower_upgrade_feedback_design_reference.png` as the full-screen Image2 direction for successful tower upgrade feedback.
- Generated `/Users/zhaok/cat/assets/generated/effects/tower_upgrade_cat_starburst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/effects/tower_upgrade_cat_starburst.png` for runtime use.
- Successful upgrades now show `TowerUpgradeFeedbackN` at the upgraded tower using the Image2 golden cat-paw starburst, upward light beams, fishbones, and sparkles.
- The upgrade feedback pops, rotates, rises, and fades quickly while the tower action panel remains readable.
- Added `/Users/zhaok/cat/tests/run_tower_upgrade_feedback_tests.gd` to verify real upgrade behavior and Image2 upgrade feedback rendering.
- Added `/Users/zhaok/cat/tests/capture_tower_upgrade_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/tower_upgrade_feedback.png`.

**Battle Tower Sell Feedback**
- Generated `/Users/zhaok/cat/assets/generated/effects/tower_sell_feedback_design_reference.png` as the full-screen Image2 direction for selling a tower and refunding fish-cookie currency.
- Generated `/Users/zhaok/cat/assets/generated/effects/tower_sell_fish_refund_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/effects/tower_sell_fish_refund_burst.png` for runtime use.
- Successful sells now show `TowerSellFeedbackN` at the sold tower slot using the Image2 fish-cookie and cat-paw refund burst.
- The sell feedback pops, rotates, travels up-left toward the fish counter, and fades while the tower slot immediately becomes buildable again.
- Added `/Users/zhaok/cat/tests/run_tower_sell_feedback_tests.gd` to verify real sell behavior, refund accounting, and Image2 sell feedback rendering.
- Added `/Users/zhaok/cat/tests/capture_tower_sell_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/tower_sell_feedback.png`.

**Battle Tower Fire Feedback**
- Generated `/Users/zhaok/cat/assets/generated/effects/tower_fire_feedback_design_reference.png` as the full-screen Image2 direction for cat tower firing feedback.
- Generated `/Users/zhaok/cat/assets/generated/effects/tower_fire_fishbone_muzzle_flash_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/effects/tower_fire_fishbone_muzzle_flash.png` for runtime use.
- Tower `fired` signals now show `TowerFireFeedbackN` near the tower muzzle, using the Image2 fishbone projectile flash rotated toward the target.
- The fire feedback pops, travels forward slightly, and fades quickly so cat towers feel less like static images while preserving the existing hit spark at the enemy.
- Added `/Users/zhaok/cat/tests/run_tower_fire_feedback_tests.gd` to verify real tower attack behavior and Image2 firing feedback rendering.
- Added `/Users/zhaok/cat/tests/capture_tower_fire_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/tower_fire_feedback.png`.

final result: passed
