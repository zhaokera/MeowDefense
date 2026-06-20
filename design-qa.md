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

**Daily Reward Claim Success Feedback**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/daily_reward_claim_success_design_reference.png` as the full-screen Image2 daily reward success design.
- Generated `/Users/zhaok/cat/assets/generated/ui/daily_reward_claim_success_burst_source.png` and transparent `/Users/zhaok/cat/assets/generated/ui/daily_reward_claim_success_burst.png` for the animated success burst.
- Claiming the daily reward now closes the claim popup and opens `DailyRewardClaimSuccessOverlay` with the Image2 design, dynamic fish reward amount, streak count, close/confirm hit areas, and pulse feedback.
- Updated `/Users/zhaok/cat/tests/run_reward_overlay_tests.gd` to require the success feedback overlay, design texture, burst texture, close behavior, manifest entries, fish reward, and streak label.
- Added `/Users/zhaok/cat/tests/capture_daily_reward_claim_success.gd` to regenerate `/Users/zhaok/cat/artifacts/daily_reward_claim_success.png`.
- Verification: targeted daily reward/reward-chain checks passed, manifest JSON parsed cleanly, and full Godot regression passed with `FULL_REGRESSION_PASS_CLEAN 45 tests`.

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

**Daily Task Claim Reward Feedback**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/daily_task_claim_reward_design_reference.png` as the full-screen Image2 claim reward design.
- Generated `/Users/zhaok/cat/assets/generated/ui/daily_task_claim_reward_burst_source.png` and transparent `/Users/zhaok/cat/assets/generated/ui/daily_task_claim_reward_burst.png` for the animated reward burst.
- Claiming a daily task now opens `DailyTaskClaimRewardOverlay` with the Image2 design, dynamic task title/detail, fish reward amount, transparent close/confirm hit areas, and pulse feedback on the reward burst.
- Updated `/Users/zhaok/cat/tests/run_daily_task_overlay_tests.gd` to require the reward feedback overlay, design texture, burst texture, close behavior, manifest entries, and persisted fish reward.
- Added `/Users/zhaok/cat/tests/capture_daily_task_claim_reward.gd` to regenerate `/Users/zhaok/cat/artifacts/daily_task_claim_reward.png`.
- Verification: targeted daily-task/reward/shop overlay checks passed, and full Godot regression passed with `FULL_REGRESSION_PASS_CLEAN 45 tests`.

**Daily Task Row State Assets**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/daily_task_state_design_reference.png` as the Image2 state reference for ready-to-claim, unfinished-progress, and claimed task rows.
- Generated chroma-key sources and transparent final assets for `/Users/zhaok/cat/assets/generated/ui/daily_task_claim_button_plate.png`, `/Users/zhaok/cat/assets/generated/ui/daily_task_claimed_stamp.png`, and `/Users/zhaok/cat/assets/generated/ui/daily_task_progress_chip.png`.
- Daily task rows now layer Image2 state art under dynamic Godot labels and transparent hit areas, with button feedback targeting the visible state asset.
- Generated `/Users/zhaok/cat/assets/generated/ui/daily_task_overlay_state_slots_design_reference.png` as a replacement full-screen background with blank right-side state slots, preventing runtime claim/progress/claimed assets from stacking over baked-in green buttons.
- Added `/Users/zhaok/cat/tests/run_daily_task_state_asset_tests.gd` to verify the ready button plate, unfinished progress chip, claimed stamp, dynamic claimed label, disabled claimed state, and manifest entries.
- Added `/Users/zhaok/cat/tests/capture_daily_task_state_assets.gd` to regenerate `/Users/zhaok/cat/artifacts/daily_task_state_ready.png` and `/Users/zhaok/cat/artifacts/daily_task_state_claimed.png`.
- Updated `/Users/zhaok/cat/tests/run_daily_task_overlay_tests.gd` to require the state-slot background and scan the three right-side state regions for baked-in green button pixels.
- Verification: targeted daily-task state/overlay/reset checks passed, non-headless screenshot capture passed, and full Godot regression passed with `FULL_REGRESSION_PASS_CLEAN 53 tests`.

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

**Achievement Claim Reward Feedback Overlay**
- Generated `/Users/zhaok/cat/assets/generated/ui/achievement_claim_reward_design_reference.png` as the full-screen Image2 reward moment shown after claiming an achievement.
- Generated `/Users/zhaok/cat/assets/generated/ui/achievement_claim_reward_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/achievement_claim_reward_burst.png` for runtime use.
- Claiming an achievement now opens `AchievementClaimRewardOverlay` with the Image2 design background, dynamic achievement/reward labels, the transparent reward burst, a close hit area, and button/burst pulse feedback.
- Updated `/Users/zhaok/cat/tests/run_achievement_claim_tests.gd` to verify the reward feedback overlay, Image2 asset paths, manifest entries, reward labels, close behavior, reward accounting, persistence, and backpack badge count.
- Updated `/Users/zhaok/cat/tests/capture_achievement_claimed.gd` to wait for animation frames and regenerate `/Users/zhaok/cat/artifacts/achievements_claimed_overlay.png`, which now captures the reward feedback overlay.
- Verified the new reward screenshot visually, passed the targeted achievement/town/backpack/reward checks, and passed the full `tests/run_*.gd` regression suite with 44 clean Godot tests.

**Achievement Progress Guidance Overlay**
- Generated `/Users/zhaok/cat/assets/generated/ui/achievement_progress_guidance_design_reference.png` as the full-screen Image2 guidance design for unfinished achievement rows.
- Generated `/Users/zhaok/cat/assets/generated/ui/achievement_progress_guidance_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/achievement_progress_guidance_burst.png` for runtime pulse feedback.
- Clicking an unfinished achievement row now opens `AchievementProgressGuidanceOverlay` with the Image2 design background, dynamic title/requirement/reward/copy labels, a closable hit area, a pulsing progress burst, and `GoLevelsFromAchievementProgressButton` to route back to level select.
- Added `/Users/zhaok/cat/tests/run_achievement_progress_guidance_tests.gd` to verify asset paths, manifest entries, no accidental rewards or claims, close behavior, and level-select routing.
- Added `/Users/zhaok/cat/tests/capture_achievement_progress_guidance.gd` to regenerate `/Users/zhaok/cat/artifacts/achievement_progress_guidance.png`, which was visually checked for text placement and non-overlap.
- Passed `/Users/zhaok/cat/tests/run_achievement_progress_guidance_tests.gd`, `/Users/zhaok/cat/tests/run_achievement_claim_tests.gd`, `/Users/zhaok/cat/tests/run_town_feature_overlay_tests.gd`, `/Users/zhaok/cat/tests/run_menu_tests.gd`, and `python3 -m json.tool /Users/zhaok/cat/assets/generated/assets_manifest.json`.
- Passed the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with 49 clean Godot tests.

**Shop Buyable Product Design**
- Generated `/Users/zhaok/cat/assets/generated/ui/shop_overlay_buyable_design_reference.png` as the updated full-screen Image2 shop design where the paw bundle and yarn trap kit are visible buyable products instead of locked placeholders.
- The new shop design keeps resource counters and button labels blank so Godot can render live fish/star/energy counts, affordability, and purchase state without fighting baked text.
- `ShopOverlay` now uses `ShopDesignBackground` from the buyable design, and removed duplicate runtime title/product labels and duplicate item icons that were already part of the Image2 background.
- Added `/Users/zhaok/cat/tests/run_shop_buyable_design_tests.gd` to verify the new design path, manifest entry, no duplicate runtime art/title overlays, and button text placement on the Image2 button plates.
- Regenerated `/Users/zhaok/cat/artifacts/shop_overlay.png` and verified the buyable shop screen visually.

**Shop Insufficient Fish Feedback**
- Generated `/Users/zhaok/cat/assets/generated/ui/shop_insufficient_fish_design_reference.png` as the full-screen Image2 feedback design shown when a shop product cannot be afforded.
- Generated `/Users/zhaok/cat/assets/generated/ui/shop_insufficient_fish_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/shop_insufficient_fish_burst.png` for runtime use.
- Unaffordable paw bundle, yarn trap, and energy refill controls now keep their disabled purchase buttons but add transparent shortage hit areas that open `ShopInsufficientFishOverlay` instead of feeling dead.
- The feedback overlay uses the Image2 background, transparent empty-pouch burst, dynamic missing-fish text, close hit area, pulse feedback, and `GoDailyTaskFromShopShortageButton` to route players toward daily tasks.
- Added `/Users/zhaok/cat/tests/run_shop_insufficient_fish_feedback_tests.gd` to verify shortage hit areas, Image2 assets, missing-fish copy, no accidental rewards/spend, close behavior, daily-task routing, and manifest entries.
- Added `/Users/zhaok/cat/tests/capture_shop_insufficient_fish.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_insufficient_fish_feedback.png`, which was visually checked for text placement.

**Shop Yarn Trap Purchase**
- Generated `/Users/zhaok/cat/assets/generated/ui/yarn_trap_item_icon.png` as a transparent Image2 yarn trap item icon for backpack and battle consumable flows.
- Converted the shop's yarn trap product from a locked placeholder into a purchasable 25-fish item that increments `_yarn_traps`, updates the fish counter, persists through saves, and appears in the backpack count.
- Kept the shop and backpack full-screen Image2 designs as the visual base, adding only dynamic labels and transparent hit areas over the generated product art.
- Added `/Users/zhaok/cat/tests/run_shop_yarn_trap_tests.gd` to verify purchase, cost, inventory count, persistence, and backpack display.
- Added `/Users/zhaok/cat/tests/capture_shop_yarn_trap.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_yarn_trap_purchase.png` and `/Users/zhaok/cat/artifacts/backpack_yarn_trap_item.png`.

**Shop Paw Bundle Purchase**
- Reused `/Users/zhaok/cat/assets/generated/ui/album_paw_badge.png` as Image2 badge art for backpack and achievement-related surfaces; the shop paw bundle product art now comes from the buyable shop design.
- Converted the shop's paw bundle product from a locked placeholder into a purchasable 45-fish item that grants 2 `_paw_tokens`, updates the fish counter, persists through saves, and appears in the backpack badge count.
- Kept the shop and backpack full-screen Image2 designs as the visual base, adding only dynamic labels and transparent hit areas over the generated product art.
- Added `/Users/zhaok/cat/tests/run_shop_paw_bundle_tests.gd` to verify purchase, cost, badge count, persistence, and backpack display.
- Added `/Users/zhaok/cat/tests/capture_shop_paw_bundle.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_paw_bundle_purchase.png`.

**Shop Energy Refill Purchase**
- Added `BuyShopEnergyRefillButton` as a transparent hit area over the Image2 shop energy `+` control.
- Buying energy refill spends 10 fish, restores up to 5 energy, refreshes the shop fish and energy counters, persists through saves, and allows level entry immediately.
- Kept the Image2 shop design as the visual base; only dynamic status text and transparent interaction were added around the existing energy resource strip.
- Added `/Users/zhaok/cat/tests/run_shop_energy_refill_tests.gd` to verify affordability, purchase cost, energy restore, persistence, and post-refill battle entry.
- Added `/Users/zhaok/cat/tests/capture_shop_energy_refill.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_energy_refill_purchase.png`.

**Shop Purchase Reward Feedback Overlay**
- Generated `/Users/zhaok/cat/assets/generated/ui/shop_purchase_feedback_design_reference.png` as the full-screen Image2 purchase-success reward moment for fish packs, paw badge bundles, yarn traps, and energy refills.
- Generated `/Users/zhaok/cat/assets/generated/ui/shop_purchase_reward_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/shop_purchase_reward_burst.png` for runtime use.
- Fish pack, paw bundle, yarn trap, and energy refill purchases now open `ShopPurchaseRewardOverlay` with the Image2 design background, dynamic purchase/reward labels, the transparent reward burst, close hit areas, and button/burst pulse feedback.
- Added `/Users/zhaok/cat/tests/run_shop_purchase_feedback_tests.gd` to verify all four shop purchase paths trigger the Image2 feedback layer, use the manifest-registered assets, display the correct dynamic reward text, and close cleanly.
- Added `/Users/zhaok/cat/tests/capture_shop_purchase_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_purchase_feedback.png`.
- Verified `/Users/zhaok/cat/artifacts/shop_purchase_feedback.png` visually, passed the targeted shop/backpack/inventory checks, and passed the full `tests/run_*.gd` regression suite with 45 clean Godot tests.

**Shop Product State Assets**
- Generated `/Users/zhaok/cat/assets/generated/ui/shop_product_state_design_reference.png` as the full-screen Image2 direction for buyable and insufficient-fish product states.
- Generated `/Users/zhaok/cat/assets/generated/ui/shop_product_buy_button_plate_source.png`, `/Users/zhaok/cat/assets/generated/ui/shop_product_insufficient_fish_stamp_source.png`, and `/Users/zhaok/cat/assets/generated/ui/shop_energy_refill_button_plate_source.png`, then removed chroma-key backgrounds into transparent runtime PNGs.
- Paw bundle and yarn trap cards now show `Shop*BuyButtonFrame` Image2 green-gold button plates when affordable and `Shop*InsufficientStamp` Image2 red paw stamps when fish is insufficient; energy refill uses the same state pattern with its own lightning-plus plate.
- Runtime labels still provide live price, count, and "鱼干不足" text; transparent hit areas keep the existing purchase, shortage routing, and reward behavior.
- Added `/Users/zhaok/cat/tests/run_shop_product_state_asset_tests.gd` to verify the Image2 state assets, manifest entries, dynamic text overlays, disabled state, and shortage feedback routing.
- Added `/Users/zhaok/cat/tests/capture_shop_product_states.gd` to regenerate `/Users/zhaok/cat/artifacts/shop_product_state_affordable.png` and `/Users/zhaok/cat/artifacts/shop_product_state_insufficient.png`.
- Verified both shop product state screenshots visually, passed the targeted shop checks, and passed the full `tests/run_*.gd` regression suite with 52 clean Godot tests.

**Battle Yarn Trap Consumable**
- Generated `/Users/zhaok/cat/assets/generated/ui/yarn_trap_field_effect.png` as a transparent Image2 battlefield yarn snare effect.
- Battle HUD now exposes `YarnTrapHudIcon`, `YarnTrapCountLabel`, and `UseYarnTrapButton` using the Image2 item icon plus transparent interaction layer.
- Pressing the trap button consumes one saved inventory item, emits `yarn_traps_changed`, slows active enemies near the target, and shows `YarnTrapFieldEffectN` on the battlefield.
- Main scene passes `_yarn_traps` into `CatDefenseBattleScene` before level start and persists the reduced count when a trap is used.
- Added `/Users/zhaok/cat/tests/run_battle_yarn_trap_tests.gd` and `/Users/zhaok/cat/tests/run_battle_yarn_inventory_flow_tests.gd` to verify battle behavior, inventory handoff, and save persistence.
- Added `/Users/zhaok/cat/tests/capture_battle_yarn_trap.gd` to regenerate `/Users/zhaok/cat/artifacts/battle_yarn_trap.png`.

**Battle Yarn Trap Empty Feedback**
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_yarn_trap_empty_burst_source.png` with Image2 as a chroma-key source, then removed the key into `/Users/zhaok/cat/assets/generated/ui/battle_yarn_trap_empty_burst.png` for runtime use.
- Tapping `UseYarnTrapButton` with zero inventory now keeps the trap count at `x0`, avoids placing a field effect, updates the bottom tip, and spawns `BattleYarnTrapEmptyFeedback` with a pulse, float, and fade animation.
- The feedback layer uses the generated empty basket/restock burst plus `BattleYarnTrapEmptyFeedbackLabel` so the dead button now tells the player to restock in the shop.
- Added `/Users/zhaok/cat/tests/run_battle_yarn_empty_feedback_tests.gd` to verify empty-inventory behavior, manifest coverage, and the Image2 feedback node.
- Added `/Users/zhaok/cat/tests/capture_battle_yarn_empty_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/battle_yarn_empty_feedback.png`.

**Battle Tower Selector Cards**
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_tower_selector_cards_design_reference.png` as the full-screen Image2 direction for replacing plain tower text buttons with tactile tower cards.
- Generated `/Users/zhaok/cat/assets/generated/ui/battle_tower_card_orange_cat_source.png`, `/Users/zhaok/cat/assets/generated/ui/battle_tower_card_tabby_slow_cat_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_tower_card_selected_badge_source.png`, then removed chroma-key backgrounds into runtime transparent PNGs.
- The battle HUD now renders `TowerCardOrangeCatFrame` and `TowerCardTabbySlowCatFrame` Image2 textures with dynamic name/cost labels, transparent hit areas, press feedback, and `TowerCard*SelectedState` golden paw overlays.
- Selecting the tabby card updates `_selected_tower_id`, moves the selected-state overlay, and building from a paw slot creates `tabby_slow_cat` instead of always defaulting visually to the orange tower.
- Added `/Users/zhaok/cat/tests/run_battle_tower_selector_card_tests.gd` to verify card assets, selected-state switching, empty button text, manifest coverage, and actual selected-tower building behavior.
- Added `/Users/zhaok/cat/tests/capture_battle_tower_selector_cards.gd` to regenerate `/Users/zhaok/cat/artifacts/battle_tower_selector_cards.png`.
- Verified `/Users/zhaok/cat/artifacts/battle_tower_selector_cards.png` visually, passed the targeted tower/menu/build/playthrough checks, and passed the full `tests/run_*.gd` regression suite with 51 clean Godot tests.

**Progression Persistence And Level Locking**
- Generated `/Users/zhaok/cat/assets/generated/ui/level_lock_badge.png` as a transparent Image2 cat-paw lock badge for locked level cards.
- Added persistent progress at `user://meow_defense_save.json` for best stars by level, total fish, unlocked level, reward claims, and basic settings.
- Fresh progress now unlocks only level 1; winning a level unlocks the next level and writes the save before the result screen appears.
- Level-select locked cards keep the Image2 map as the visual source of truth and add only `LevelNLockedBadge` Image2 texture overlays plus disabled transparent hit areas.
- Added `/Users/zhaok/cat/tests/run_progression_persistence_tests.gd` to verify fresh locks, save creation, reload restore, and next-level unlock behavior without touching the real player save.
- Added `/Users/zhaok/cat/tests/capture_level_select_locked.gd` to regenerate `/Users/zhaok/cat/artifacts/level_select_locked.png`.

**Locked Level Feedback**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/locked_level_feedback_design_reference.png` as the full-screen Image2 design reference for tapping a locked level.
- Generated `/Users/zhaok/cat/assets/generated/ui/locked_level_feedback_burst_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/ui/locked_level_feedback_burst.png` for the animated lock/key burst.
- Locked level cards now keep disabled `StartLevelNButton` controls plus Image2 lock badges, and add `LockedLevelNInfoButton` transparent hit areas so tapping a locked card opens guidance instead of doing nothing.
- `LockedLevelFeedbackOverlay` uses the Image2 design background, dynamic title/requirement/copy labels, close hit area, pulse feedback, and `PlayPreviousLevelButton` to send the player to the prerequisite level.
- Added `/Users/zhaok/cat/tests/run_locked_level_feedback_tests.gd` to verify the disabled locked start path, feedback hit area, Image2 assets, manifest entries, close behavior, and previous-level routing.
- Added `/Users/zhaok/cat/tests/capture_locked_level_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/locked_level_feedback.png`.
- Verified `/Users/zhaok/cat/artifacts/locked_level_feedback.png` visually, passed the targeted locked-level/menu/progression/energy/result checks, parsed the asset manifest cleanly, and passed the full `tests/run_*.gd` regression suite with 46 clean Godot tests.

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

**Battle Enemy Spawn Feedback**
- Generated `/Users/zhaok/cat/assets/generated/effects/enemy_spawn_feedback_design_reference.png` as the full-screen Image2 direction for a mouse enemy entering the path from a dirt burrow.
- Generated `/Users/zhaok/cat/assets/generated/effects/enemy_spawn_mouse_dust_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/effects/enemy_spawn_mouse_dust.png` for runtime use.
- Newly spawned enemies now show `EnemySpawnFeedbackN` at their entry point using the Image2 burrow, cat-paw dust, stars, and footprint effect.
- The spawn effect pops, rotates, drifts, and fades quickly so enemies feel like they arrive on the path instead of appearing abruptly.
- Added `/Users/zhaok/cat/tests/run_enemy_spawn_feedback_tests.gd` to verify enemy creation and Image2 entrance feedback rendering.
- Added `/Users/zhaok/cat/tests/capture_enemy_spawn_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/enemy_spawn_feedback.png`.

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

**Orange Cat Tower Animation Sheet**
- Generated `/Users/zhaok/cat/assets/generated/towers/orange_cat_tower_animation_design_reference.png` as the full-screen Image2 direction for the core orange cat tower feeling animated in battle.
- Generated `/Users/zhaok/cat/assets/generated/towers/orange_cat_tower_sheet_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/towers/orange_cat_tower_sheet.png` for runtime use.
- The `orange_cat` tower now uses the 2x2 Image2 sprite sheet instead of the old single static tower image.
- Firing switches the orange cat tower from idle to the recoil frame, so the first playable tower has character motion in addition to muzzle and hit effects.
- Added `/Users/zhaok/cat/tests/run_orange_cat_tower_animation_tests.gd` to verify the Image2 sheet path, sprite-sheet regions, and firing frame switch.
- Added `/Users/zhaok/cat/tests/capture_orange_cat_tower_animation.gd` to regenerate `/Users/zhaok/cat/artifacts/orange_cat_tower_animation.png`.

**Tabby Slow Cat Tower Animation Sheet**
- Generated `/Users/zhaok/cat/assets/generated/towers/tabby_slow_cat_animation_design_reference.png` as the full-screen Image2 direction for the tabby yarn tower firing a slow projectile in battle.
- Generated `/Users/zhaok/cat/assets/generated/towers/tabby_slow_cat_sheet_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/towers/tabby_slow_cat_sheet.png` for runtime use.
- The `tabby_slow_cat` tower now has the same Image2 source-chain documentation as the orange cat tower while continuing to use a 2x2 sprite sheet for idle, aim, recoil, and celebration poses.
- Firing switches the tabby tower to the recoil frame and applies the slow timer/multiplier to enemies in range.
- Added `/Users/zhaok/cat/tests/run_tabby_slow_tower_animation_tests.gd` to verify the Image2 sheet path, sprite-sheet regions, firing frame switch, slow application, and manifest source entries.
- Added `/Users/zhaok/cat/tests/capture_tabby_slow_tower_animation.gd` to regenerate `/Users/zhaok/cat/artifacts/tabby_slow_tower_animation.png`.

**Basic Mouse Enemy Animation Sheet**
- Generated `/Users/zhaok/cat/assets/generated/enemies/mouse_basic_animation_design_reference.png` as the full-screen Image2 direction for the first common mouse enemy feeling animated in battle.
- Generated `/Users/zhaok/cat/assets/generated/enemies/mouse_basic_sheet_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/enemies/mouse_basic_sheet.png` for runtime use.
- The `mouse_basic` enemy now uses the 2x2 Image2 sprite sheet instead of the old single static enemy image.
- Moving enemies with sprite sheets now alternate between walking frames 0 and 2 based on distance traveled, while hit and defeated poses still use frames 1 and 3.
- Added `/Users/zhaok/cat/tests/run_mouse_basic_animation_tests.gd` to verify the Image2 sheet path, sprite-sheet regions, and walking-frame cycling.
- Added `/Users/zhaok/cat/tests/capture_mouse_basic_animation.gd` to regenerate `/Users/zhaok/cat/artifacts/mouse_basic_animation.png`.

**Fast Mouse Enemy Animation Sheet**
- Generated `/Users/zhaok/cat/assets/generated/enemies/mouse_fast_animation_design_reference.png` as the full-screen Image2 direction for the fast red-scarf mouse/hamster enemy feeling animated in battle.
- Generated `/Users/zhaok/cat/assets/generated/enemies/mouse_fast_sheet_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/enemies/mouse_fast_sheet.png` for runtime use.
- The `mouse_fast` enemy now uses the 2x2 Image2 sprite sheet instead of the old single static enemy image.
- The existing distance-based walking frame cycling now makes the fast enemy switch sprint frames while moving, while hit and defeated poses use frames 1 and 3.
- Added `/Users/zhaok/cat/tests/run_mouse_fast_animation_tests.gd` to verify the Image2 sheet path, sprite-sheet regions, and walking-frame cycling.
- Added `/Users/zhaok/cat/tests/capture_mouse_fast_animation.gd` to regenerate `/Users/zhaok/cat/artifacts/mouse_fast_animation.png`.

**Rat Tank Enemy Animation Sheet**
- Generated `/Users/zhaok/cat/assets/generated/enemies/rat_tank_animation_design_reference.png` as the full-screen Image2 direction for the chunky tank rat marching under cat tower fire.
- Generated `/Users/zhaok/cat/assets/generated/enemies/rat_tank_sheet_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/enemies/rat_tank_sheet.png` for runtime use.
- The `rat_tank` enemy now has the same Image2 source-chain documentation as the lighter mouse enemies while continuing to use a 2x2 sprite sheet for heavy walk, hit, heavy walk alternate, and defeated poses.
- The existing distance-based enemy walking frame cycling moves the tank rat between heavy walk frames, while hit and defeated reactions use frames 1 and 3.
- Added `/Users/zhaok/cat/tests/run_rat_tank_animation_tests.gd` to verify the Image2 sheet path, sprite-sheet regions, heavy walking-frame cycling, hit/defeat frame switches, and manifest source entries.
- Added `/Users/zhaok/cat/tests/capture_rat_tank_animation.gd` to regenerate `/Users/zhaok/cat/artifacts/rat_tank_animation.png`.

**Hamster Runner Enemy Animation Sheet**
- Generated `/Users/zhaok/cat/assets/generated/enemies/hamster_runner_animation_design_reference.png` as the full-screen Image2 direction for the tiny fast hamster runner sprinting through cat tower fire.
- Generated `/Users/zhaok/cat/assets/generated/enemies/hamster_runner_sheet_source.png`, then removed the chroma-key background into `/Users/zhaok/cat/assets/generated/enemies/hamster_runner_sheet.png` for runtime use.
- The `hamster_runner` enemy now has the same Image2 source-chain documentation as the other enemy classes while continuing to use a 2x2 sprite sheet for sprint, sprint alternate, hit, and defeated poses.
- The existing distance-based enemy walking frame cycling moves the hamster runner between sprint frames, while hit and defeated reactions use frames 1 and 3.
- Added `/Users/zhaok/cat/tests/run_hamster_runner_animation_tests.gd` to verify the Image2 sheet path, sprite-sheet regions, sprint-frame cycling, hit/defeat frame switches, and manifest source entries.
- Added `/Users/zhaok/cat/tests/capture_hamster_runner_animation.gd` to regenerate `/Users/zhaok/cat/artifacts/hamster_runner_animation.png`.
- Verified `/Users/zhaok/cat/artifacts/hamster_runner_animation.png` visually against the Image2 reference, then passed the targeted hamster/tank/fast-enemy/playthrough/unit checks and the full `tests/run_*.gd` regression suite with 44 clean Godot tests.

final result: passed

---

**Image2 Enemy Health Bar**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/enemy_health_bar_design_reference.png` as the full-screen Image2 battle reference for object-like enemy health bars.
- Generated chroma-key source assets and transparent runtime textures for `/Users/zhaok/cat/assets/generated/ui/enemy_health_bar_under.png`, `/Users/zhaok/cat/assets/generated/ui/enemy_health_bar_fill.png`, and `/Users/zhaok/cat/assets/generated/ui/enemy_health_bar_danger_fill.png`.
- Enemy health UI now uses an Image2 frame `TextureRect` with paw badge and fish-bone cap plus an inner `TextureProgressBar` for healthy/danger fill states, avoiding the old code-drawn `ColorRect` and preventing the fill from covering decorative caps.
- Damaged enemies pulse the full Image2 health-bar group and switch to the danger fill below 40% HP.
- Added `/Users/zhaok/cat/tests/run_enemy_health_bar_asset_tests.gd` to verify Image2 frame/fill paths, no `ColorRect` health bar, readable battle-scale dimensions, low-health danger state, and manifest entries.
- Added `/Users/zhaok/cat/tests/capture_enemy_health_bar.gd` to regenerate `/Users/zhaok/cat/artifacts/enemy_health_bar.png`.
- Verified `/Users/zhaok/cat/artifacts/enemy_health_bar.png` visually against the Image2 reference, then passed the targeted enemy health, hit feedback, enemy animation, build input, playthrough, menu, and scene smoke checks.

**Image2 Tower Projectile**
- Generated and archived `/Users/zhaok/cat/assets/generated/effects/tower_projectile_design_reference.png` as the full-screen Image2 battle reference for a cat fishbone shot traveling from tower to enemy.
- Generated `/Users/zhaok/cat/assets/generated/effects/tower_fishbone_projectile_source.png`, then removed the chroma-key background and cropped the transparent runtime sprite into `/Users/zhaok/cat/assets/generated/effects/tower_fishbone_projectile.png`.
- Tower fire now spawns `Image2ProjectileN` as a textured `Sprite2D` traveling from the tower muzzle toward the target, while the old `projectile.gd` code-drawn circle has been removed.
- The projectile keeps damage application disabled in the current tower signal path, so existing tower balance stays intact while the shot becomes visible and animated.
- Updated `/Users/zhaok/cat/tests/run_tower_fire_feedback_tests.gd` to verify real tower attack behavior, Image2 muzzle feedback, Image2 projectile texture, rotation toward target, manifest entries, and no `draw_circle` fallback.
- Updated `/Users/zhaok/cat/tests/capture_tower_fire_feedback.gd` to regenerate `/Users/zhaok/cat/artifacts/tower_fire_feedback.png` with a clearer in-flight projectile frame.
- Verified `/Users/zhaok/cat/artifacts/tower_fire_feedback.png` visually against the Image2 projectile reference and passed the targeted tower fire feedback check.

**Image2 Tower Range Aura**
- Added `/Users/zhaok/cat/assets/generated/effects/tower_range_aura_design_reference.png` as the full-screen battle reference for replacing the old code-drawn tower range arc.
- Derived `/Users/zhaok/cat/assets/generated/effects/tower_range_aura_source.png` and `/Users/zhaok/cat/assets/generated/effects/tower_range_aura.png` from existing Image2 cat-paw/yarn battlefield effect art, then tuned the runtime alpha for range feedback.
- Tower visuals now create `TowerRangeAura` as a textured `Sprite2D` behind the tower, scaled from `attack_range` and given a subtle breathing alpha/scale motion.
- Removed the tower `_draw()` fallback circles, lines, and range arc so player-visible tower/range art comes from generated assets instead of code drawing.
- Added `/Users/zhaok/cat/tests/run_tower_range_aura_tests.gd` to verify the Image2 aura sprite, manifest entries, readable scale, z-order, and no `draw_arc`/`draw_circle`/`draw_line` fallback in `tower.gd`.
- Added `/Users/zhaok/cat/tests/capture_tower_range_aura.gd` to regenerate `/Users/zhaok/cat/artifacts/tower_range_aura.png`.
- Verified `/Users/zhaok/cat/artifacts/tower_range_aura.png` visually in battle and passed the targeted tower range aura check.

**Image2 Enemy Fallback**
- Enemy visual fallback now uses `/Users/zhaok/cat/assets/generated/enemies/mouse_basic_sheet.png` instead of drawing a circle face when a configured enemy texture is missing.
- Removed `enemy.gd` code-drawn fallback circles and mouth arc so even error/future-content paths stay on generated sprite art.
- Added `/Users/zhaok/cat/tests/run_enemy_fallback_asset_tests.gd` to verify missing enemy textures still render a sprite-sheet `Sprite2D`, use the Image2 mouse sheet, keep readable scale, and contain no `draw_circle`/`draw_arc` fallback.
- Added `/Users/zhaok/cat/tests/capture_enemy_fallback_asset.gd` to regenerate `/Users/zhaok/cat/artifacts/enemy_fallback_asset.png` on the generated level background.
- Verified `/Users/zhaok/cat/artifacts/enemy_fallback_asset.png` visually and passed targeted fallback plus normal enemy animation checks.

**Image2 Battle Background Fallback**
- Battle scenes now always create `BattleBackground` as a `Sprite2D`; if a level config references a missing background, it falls back to `/Users/zhaok/cat/assets/generated/backgrounds/level_001_meadow.png`.
- Removed the old `battle_scene.gd` `_draw()` fallback that painted grass, path lines, and base circles with code.
- Added `/Users/zhaok/cat/tests/run_battle_background_fallback_tests.gd` to verify missing-background levels still render an Image2 background and that `battle_scene.gd` no longer contains `draw_rect`/`draw_line`/`draw_circle` fallback drawing.
- Added `/Users/zhaok/cat/tests/capture_battle_background_fallback.gd` to regenerate `/Users/zhaok/cat/artifacts/battle_background_fallback.png`.
- Verified `/Users/zhaok/cat/artifacts/battle_background_fallback.png` visually and passed the targeted fallback, playthrough, and scene smoke checks.

**Image2 App Helper Cleanup**
- Removed unused legacy `main.gd` helpers that could recreate visible UI with `Panel`, code-styled `Button`, `CheckButton`, and `StyleBoxFlat` instead of the current Image2 screen and transparent hit-area model.
- Kept transparent hotspot/style helpers for interaction layers over generated UI art.
- Added `/Users/zhaok/cat/tests/run_app_legacy_ui_helper_tests.gd` to prevent reintroducing the old visible Panel/Button/StyleBoxFlat helper path.
- Passed the new source hygiene check plus menu, town feature overlay, scene smoke, and unit tests.

**Image2 Battle Helper Cleanup**
- Removed unused legacy `battle_scene.gd` helpers that could recreate code-styled pause buttons and panels with `StyleBoxFlat`.
- Kept the active pause menu on Image2 button frames plus transparent hit/text controls.
- Added `/Users/zhaok/cat/tests/run_battle_legacy_ui_helper_tests.gd` to prevent reintroducing the old code-styled pause button path.
- Passed the new source hygiene check plus pause menu, playthrough, battle speed/wave, scene smoke, and unit tests.

**Image2 Common Overlay Dim**
- Added `/Users/zhaok/cat/assets/generated/ui/common_overlay_dim_design_reference.png` and `/Users/zhaok/cat/assets/generated/ui/common_overlay_dim_vignette.png` as the common warm Image2-derived modal dim treatment.
- App overlays and the battle pause overlay now use the common `TextureRect` dim layer instead of code-drawn `ColorRect` blocks.
- Raised `PauseMenuOverlay` above battle HUD controls so tower cards and build controls cannot overlap the pause panel.
- Updated `/Users/zhaok/cat/assets/generated/assets_manifest.json` with the common overlay entries.
- Added `/Users/zhaok/cat/tests/run_overlay_dim_asset_tests.gd` and extended `/Users/zhaok/cat/tests/run_pause_menu_tests.gd` to prevent ColorRect dim regressions and pause overlay z-order regressions.
- Regenerated `/Users/zhaok/cat/artifacts/settings_overlay.png`, `/Users/zhaok/cat/artifacts/pause_menu.png`, and `/Users/zhaok/cat/artifacts/pause_settings.png`; headless screenshots could not read the viewport texture, so GUI Godot capture was used for visual evidence.
- Passed overlay dim, menu, pause menu, playthrough, scene smoke, and unit tests.

**Image2 Hotspot Tap Feedback**
- Added `/Users/zhaok/cat/assets/generated/ui/ui_tap_feedback_design_reference.png` and `/Users/zhaok/cat/assets/generated/ui/ui_tap_feedback_paw_spark.png` for lightweight paw sparkle feedback on transparent hit-area buttons.
- Base `_hotspot_button()` controls now spawn a non-blocking Image2 `TextureRect` tap effect at the pointer position, with a center fallback for programmatic or keyboard-triggered button presses.
- Added `/Users/zhaok/cat/tests/run_hotspot_feedback_tests.gd` to verify project-bound tap art, `UI_TAP_FEEDBACK_TEXTURE`, pointer-centered feedback, and non-blocking input.
- Added `/Users/zhaok/cat/tests/capture_hotspot_feedback.gd` and regenerated `/Users/zhaok/cat/artifacts/hotspot_tap_feedback.png` for the main menu start-button press state.
- Passed the hotspot feedback, menu, and scene smoke checks.

**Image2 Battle Tap Feedback**
- Added `/Users/zhaok/cat/assets/generated/ui/battle_tap_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_tap_feedback_starburst_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_tap_feedback_starburst.png` as the battle-specific tap feedback asset chain.
- Battle buttons using `_attach_press_feedback()` now spawn a non-blocking Image2 `TextureRect` burst. Map/build-slot controls stay pointer-centered; edge HUD controls clamp the burst inside the viewport so the feedback remains visible near screen edges.
- Removed the empty `build_slot.gd` `_draw()` hook and `queue_redraw()` path so build slots stay on Image2 marker art plus transparent interaction layers.
- Added `/Users/zhaok/cat/tests/run_battle_tap_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_tap_feedback.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/battle_tap_feedback.png`; GUI capture was required because headless viewport texture capture returned a null texture.
- Passed battle tap, build input, battle speed/wave, pause menu, playthrough, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite.

**Image2 Settings Control Feedback**
- Settings overlay toggle and slider hit areas now spawn Image2 tap feedback using `/Users/zhaok/cat/assets/generated/ui/ui_tap_feedback_paw_spark.png` while keeping the visible toggle, track, and knob art Image2-driven.
- Music/effects toggles pulse their Image2 toggle frames on pointer/touch press; the volume slider pulses the Image2 knob and keeps the feedback centered on the pointer.
- Added `/Users/zhaok/cat/tests/run_settings_control_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_settings_control_feedback.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/settings_control_feedback.png`; GUI capture was required because headless viewport texture capture returned a null texture.
- Passed settings control feedback, hotspot feedback, menu, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite.

**Image2 Screen Entry Animation**
- Main menu and level select now animate their full-screen Image2 designs with a short fade, slide, and tactile zoom settle instead of hard-cutting between static screens.
- The animation is applied to the full Image2 screen container, not by rebuilding or layering visible UI panels in code.
- Added `/Users/zhaok/cat/tests/run_image2_screen_entry_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_image2_screen_entry_animation.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/image2_screen_entry_animation.png`; GUI capture was required because headless viewport texture capture returned a null texture.
- Passed Image2 screen entry animation, menu, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite.

**Image2 Settings Overlay Exit Animation**
- Settings overlay close now runs `_animate_overlay_exit()` instead of removing the Image2 panel immediately, so the modal fades, scales down, and slides slightly before cleanup.
- The exit state marks `image2_overlay_exit_animation`, disables the close button, and makes the overlay ignore mouse input while it is leaving.
- Updated `/Users/zhaok/cat/tests/run_menu_tests.gd` to wait for the close transition instead of assuming the overlay disappears on the next frame.
- Added `/Users/zhaok/cat/tests/run_settings_overlay_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_settings_overlay_exit_animation.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/settings_overlay_exit_animation.png`; GUI capture was required because headless viewport texture capture returned a null texture.
- Passed settings overlay exit animation, menu, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 65 tests`.

**Image2 Album Overlay Exit Animation**
- Album overlay close now reuses `_animate_overlay_exit()` instead of hard-removing the Image2 guide panel, so the panel fades, scales, and slides out before cleanup.
- The exit state marks `image2_overlay_exit_animation`, disables `CloseAlbumButton`, and makes the overlay ignore mouse input while the animation is running.
- Updated `/Users/zhaok/cat/tests/run_album_overlay_tests.gd` and `/Users/zhaok/cat/tests/run_menu_tests.gd` to wait for the animated close.
- Added `/Users/zhaok/cat/tests/run_album_overlay_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_album_overlay_exit_animation.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/album_overlay_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed album overlay exit animation, album overlay, menu, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 66 tests`.

**Image2 Town Feature Overlay Exit Animations**
- Backpack, achievements, and shop overlays now reuse `_animate_overlay_exit()` instead of hard-removing their full-screen Image2 panels.
- Each exit state marks `image2_overlay_exit_animation`, disables the close hit area, and makes the overlay ignore mouse input while the panel fades, scales, and slides out.
- Updated `/Users/zhaok/cat/tests/run_town_feature_overlay_tests.gd` to wait for the animated close on all three overlays.
- Added `/Users/zhaok/cat/tests/run_town_feature_overlay_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_town_feature_overlay_exit_animations.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/backpack_overlay_exit_animation.png`, `/Users/zhaok/cat/artifacts/achievements_overlay_exit_animation.png`, and `/Users/zhaok/cat/artifacts/shop_overlay_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed town feature overlay exit animation, town feature overlay, menu, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 67 tests`.

**Image2 Reward Feedback Exit Animations**
- Daily reward success and daily task claim reward overlays now reuse `_animate_overlay_exit()` instead of hard-removing the full-screen Image2 reward feedback art.
- Their primary close and dismiss controls both mark `image2_overlay_exit_animation`, disable the pressed control, and make the overlay ignore mouse input while fading, scaling, and sliding out.
- Updated `/Users/zhaok/cat/tests/run_reward_overlay_tests.gd` and `/Users/zhaok/cat/tests/run_daily_task_overlay_tests.gd` to wait for the animated close.
- Added `/Users/zhaok/cat/tests/run_reward_feedback_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_reward_feedback_exit_animations.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/daily_reward_claim_success_exit_animation.png` and `/Users/zhaok/cat/artifacts/daily_task_claim_reward_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed reward feedback exit animation, reward overlay, daily task overlay, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 68 tests`.

**Image2 Guidance Overlay Exit Animations**
- Locked-level feedback, energy-empty feedback, and the daily-task overlay now reuse `_animate_overlay_exit()` instead of hard-removing their Image2 guidance panels.
- `_animate_overlay_exit()` now cancels any active `image2_overlay_entry_tween` and applies an immediate small alpha change before tweening out, so fast close taps still give visible exit feedback instead of fighting the entry animation.
- Updated `/Users/zhaok/cat/tests/run_locked_level_feedback_tests.gd` to wait for the animated close; energy and daily-task behavior are covered by the new exit animation test.
- Added `/Users/zhaok/cat/tests/run_guidance_overlay_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_guidance_overlay_exit_animations.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/locked_level_feedback_exit_animation.png`, `/Users/zhaok/cat/artifacts/energy_empty_overlay_exit_animation.png`, and `/Users/zhaok/cat/artifacts/daily_task_overlay_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed guidance overlay exit animation, locked-level feedback, energy flow, daily task overlay, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 69 tests`.

**Image2 Detail Overlay Exit Animations**
- Album entry detail, backpack item detail, and achievement progress guidance now reuse `_animate_overlay_exit()` instead of hard-removing their full-screen Image2 detail panels.
- Each close state marks `image2_overlay_exit_animation`, disables the pressed close hit area, and makes the overlay ignore mouse input while fading, scaling, and sliding out.
- Updated `/Users/zhaok/cat/tests/run_achievement_progress_guidance_tests.gd` to wait for the animated close; album and backpack detail action flows remain covered by their existing detail tests.
- Added `/Users/zhaok/cat/tests/run_detail_overlay_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_detail_overlay_exit_animations.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/album_entry_detail_exit_animation.png`, `/Users/zhaok/cat/artifacts/backpack_item_detail_exit_animation.png`, and `/Users/zhaok/cat/artifacts/achievement_progress_guidance_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed detail overlay exit animation, album entry detail, backpack item detail, achievement progress guidance, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 70 tests`.

**Image2 Reward And Shop Feedback Exit Animations**
- Backpack organize reward, achievement claim reward, shop purchase reward, and shop insufficient-fish feedback now reuse `_animate_overlay_exit()` instead of hard-removing their full-screen Image2 feedback panels.
- Primary and dismiss close controls on the reward-style panels now mark `image2_overlay_exit_animation`, disable the pressed control, make the overlay ignore input, and start fading immediately before cleanup.
- Hardened existing exit-animation tests to assert the immediate Image2 exit state instead of depending on the next headless frame still landing before the short tween completes.
- Updated `/Users/zhaok/cat/tests/run_achievement_claim_tests.gd`, `/Users/zhaok/cat/tests/run_shop_purchase_feedback_tests.gd`, and `/Users/zhaok/cat/tests/run_shop_insufficient_fish_feedback_tests.gd` to wait for animated close completion.
- Added `/Users/zhaok/cat/tests/run_reward_shop_feedback_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_reward_shop_feedback_exit_animations.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/backpack_organize_reward_exit_animation.png`, `/Users/zhaok/cat/artifacts/achievement_claim_reward_exit_animation.png`, `/Users/zhaok/cat/artifacts/shop_purchase_reward_exit_animation.png`, and `/Users/zhaok/cat/artifacts/shop_insufficient_fish_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed reward/shop feedback exit animation, backpack organize reward, achievement claim, shop purchase feedback, shop insufficient-fish feedback, scene smoke, unit tests, all exit-animation tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 71 tests`.

**Image2 Reward Overlay Exit Animation**
- The base daily reward overlay close button now reuses `_animate_overlay_exit()` instead of hard-removing the Image2 reward panel.
- The close state marks `image2_overlay_exit_animation`, disables `CloseRewardButton`, makes the overlay ignore input, and starts the fade immediately before cleanup.
- Added `/Users/zhaok/cat/tests/run_reward_overlay_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_reward_overlay_exit_animation.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/reward_overlay_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed reward overlay exit animation, reward overlay, reward feedback exit animation, daily reward reset, menu, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 72 tests`.

**Image2 Battle Overlay Exit Animations**
- Tower action close, pause settings close, and pause resume now use `_animate_hud_overlay_exit()` instead of hard-removing battle HUD overlays.
- The battle HUD exit state marks `image2_overlay_exit_animation`, disables the pressed control, makes the overlay ignore input, and fades/scales/slides out before cleanup. Pause settings keeps the pause menu buttons hidden until its exit completes.
- Added `/Users/zhaok/cat/tests/run_battle_overlay_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_overlay_exit_animations.gd`.
- Updated `/Users/zhaok/cat/tests/run_pause_menu_tests.gd` and `/Users/zhaok/cat/tests/run_menu_tests.gd` to wait for animated pause overlay cleanup.
- Regenerated `/Users/zhaok/cat/artifacts/tower_action_exit_animation.png`, `/Users/zhaok/cat/artifacts/pause_settings_exit_animation.png`, and `/Users/zhaok/cat/artifacts/pause_menu_exit_animation.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed battle overlay exit animation, pause menu, tower action, menu, playthrough, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 73 tests`.

**Image2 Result Screen Exit Animation**
- Result screen actions now use `_animate_result_screen_exit()` before routing away, so retry, level-map, and next-level taps fade/scale/slide the full Image2 result screen instead of hard-cutting.
- The exit state marks `image2_result_exit_animation`, disables all result action buttons, ignores input on the result screen, and preserves the existing Image2 victory/defeat designs as the visual source.
- Retry and next-level actions keep the current energy/lock checks before animating; if a level cannot start, the existing guidance flow stays on the result screen.
- Added `/Users/zhaok/cat/tests/run_result_screen_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_result_screen_exit_animation.gd`.
- Updated `/Users/zhaok/cat/tests/run_result_screen_tests.gd` to wait for the animated level-map transition.
- Regenerated `/Users/zhaok/cat/artifacts/result_screen_exit_animation.png`; GUI capture was required because headless capture stalled waiting for a rendered frame.
- Passed result screen exit animation, result screen, defeat result, menu, playthrough, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 74 tests`.

**Image2 Result Screen Entry Animation**
- Victory and defeat result screens now run `_animate_result_screen_entry()` after their Image2 result design, dynamic labels, reward pieces, and action hit areas are assembled.
- The entry state marks `image2_result_entry_animation` and starts the full result screen slightly lowered, lightly zoomed, and faded, then settles to the normal Image2 layout.
- The entry completion callback uses a `WeakRef` so quick result-button transitions cannot produce stale tween captures if the result screen is removed before the entry tween ends.
- Added `/Users/zhaok/cat/tests/run_result_screen_entry_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_result_screen_entry_animation.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/result_screen_entry_animation.png`; GUI capture was used for visual evidence.
- Passed result screen entry animation, result screen, defeat result, result screen exit animation, playthrough, scene smoke, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 75 tests`.

**Image2 Overlay Action Exit Animations**
- Overlay action buttons now route through the Image2 exit animation before navigating away: locked-level challenge, album detail go-to-levels, backpack item action, achievement progress go-to-levels, and shop shortage go-to-daily-tasks.
- `_animate_overlay_exit()` now accepts an optional completion callback while preserving the existing close-button behavior. The exit state still marks `image2_overlay_exit_animation`, disables the pressed action, ignores input, and fades/scales/slides the Image2 overlay before running the route.
- Existing action-flow tests were updated to wait for the animated transition instead of expecting a one-frame hard cut.
- Added `/Users/zhaok/cat/tests/run_overlay_action_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_overlay_action_exit_animations.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/locked_level_action_exit_animation.png`, `/Users/zhaok/cat/artifacts/album_detail_action_exit_animation.png`, `/Users/zhaok/cat/artifacts/backpack_detail_action_exit_animation.png`, `/Users/zhaok/cat/artifacts/achievement_guidance_action_exit_animation.png`, and `/Users/zhaok/cat/artifacts/shop_shortage_action_exit_animation.png`; GUI capture was used for visual evidence.
- Passed overlay action exit animation, locked-level feedback, album entry detail, backpack item detail, achievement progress guidance, shop insufficient-fish feedback, menu, playthrough, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 76 tests`.

**Image2 Daily Reward Claim Action Exit Animation**
- Claiming the daily reward now runs the base Image2 reward panel through `_animate_overlay_exit()` before opening `DailyRewardClaimSuccessOverlay`, avoiding the previous hard cut from the claim panel to the success screen.
- The claim exit state marks `image2_overlay_exit_animation`, disables `ClaimRewardButton`, makes the reward overlay ignore input, and preserves the single fish grant before the success overlay appears.
- Updated reward feedback tests and daily reward capture scripts to wait for the animated claim transition instead of expecting the success overlay immediately.
- Added `/Users/zhaok/cat/tests/run_reward_claim_action_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_reward_claim_action_exit_animation.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/reward_claim_action_exit_animation.png`; GUI capture was used for visual evidence.
- Passed reward claim action exit animation, reward overlay, reward overlay exit animation, reward feedback exit animation, daily reward reset, menu, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 77 tests`.

**Image2 Pause Menu Action Exit Animations**
- Pause menu restart and quit actions now reuse `_animate_hud_overlay_exit()` before resetting the battle or routing back to level select, matching the existing Image2 resume exit behavior instead of hard-cutting.
- The action exit state marks `image2_overlay_exit_animation`, disables the pressed pause action button, makes the pause menu ignore input, and delays restart/quit routing until the Image2 pause panel has faded, scaled, and slid out.
- Updated `/Users/zhaok/cat/tests/run_menu_tests.gd` to wait for the animated quit-to-levels transition.
- Added `/Users/zhaok/cat/tests/run_pause_menu_action_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_pause_menu_action_exit_animations.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/pause_restart_action_exit_animation.png` and `/Users/zhaok/cat/artifacts/pause_quit_action_exit_animation.png`; GUI capture was used for visual evidence.
- Passed pause menu action exit animation, menu, pause menu, battle overlay exit animation, playthrough, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 78 tests`.

**Image2 Tower Sell Action Exit Animation**
- Selling a tower from the Image2 tower action panel now applies the sale immediately, keeps the refund and slot-restore feedback responsive, and runs the management panel through `_animate_hud_overlay_exit()` instead of hard-removing it.
- The sell exit state marks `image2_overlay_exit_animation`, disables `SellTowerButton`, makes `TowerActionOverlay` ignore input, and leaves the Image2 panel visible long enough to fade, scale, and slide out over the sell feedback.
- Added `/Users/zhaok/cat/tests/run_tower_sell_action_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_tower_sell_action_exit_animation.gd`.
- Regenerated `/Users/zhaok/cat/artifacts/tower_sell_action_exit_animation.png`; GUI capture was used for visual evidence.
- Passed tower sell action exit animation, tower action, battle overlay exit animation, tower sell feedback, tower upgrade feedback, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 79 tests`.

**Image2 Screen Exit Animation**
- Main menu and level-select transitions now run an Image2 full-screen exit animation before the next screen is built, so start, back, and bottom-navigation flows no longer hard-cut between static Image2 pages.
- The outgoing screen marks `image2_screen_exit_animation`, disables all buttons under the exiting screen, ignores input, then fades, scales, and slides out before the target Image2 page runs its existing entry animation.
- Added `/Users/zhaok/cat/tests/run_image2_screen_exit_animation_tests.gd` and `/Users/zhaok/cat/tests/capture_image2_screen_exit_animation.gd`; setup-only tests and capture scripts now use `_show_main_menu_now()` / `_show_level_select_now()` so they do not mask the player-facing transition test.
- Regenerated `/Users/zhaok/cat/artifacts/main_menu_screen_exit_animation.png` and `/Users/zhaok/cat/artifacts/level_select_screen_exit_animation.png`; GUI capture was used for visual evidence.
- Passed Image2 screen exit animation, Image2 screen entry animation, menu, energy flow, progression persistence, locked-level feedback, town feature overlay, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 80 tests`.

**Image2 Battle Wave Rush**
- Generated and archived `/Users/zhaok/cat/assets/generated/ui/battle_wave_rush_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_wave_rush_burst_source.png`, and transparent runtime `/Users/zhaok/cat/assets/generated/ui/battle_wave_rush_burst.png`.
- The existing Image2 `WavePreviewFrame` now has a transparent `RushNextWaveButton`; pressing it keeps the visible chip art as the source of truth, advances the next pending wave to the current time, spawns the first enemy immediately, and updates the preview label to the active wave state.
- Added `BattleWaveRushFeedback` with the generated Image2 burst, dynamic `提前开波` feedback text, wave-chip pulse, and bottom build-tip guidance so the action feels tactile instead of silently changing timers.
- Added `/Users/zhaok/cat/tests/run_battle_wave_rush_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_wave_rush.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_wave_rush_feedback.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed battle wave rush, battle speed/wave, battle tap feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 81 tests`.

**Image2 Tower Max Level State**
- Added feature-specific project assets `/Users/zhaok/cat/assets/generated/ui/tower_max_level_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/tower_max_level_stamp.png`, and `/Users/zhaok/cat/assets/generated/ui/tower_max_level_burst.png` from existing Image2 tower-upgrade and claimed-stamp artwork.
- Towers now have `max_level = 3`; upgrade attempts at max level do not spend fish, do not increase the tower level, and instead show a tactile Image2 max-level burst plus bottom guidance text.
- The Image2 tower action panel now overlays `TowerMaxLevelStamp` and dynamic `满级` text when a tower reaches the cap, while keeping the existing panel art as the visual source of truth.
- Added `/Users/zhaok/cat/tests/run_tower_max_level_tests.gd` and `/Users/zhaok/cat/tests/capture_tower_max_level.gd`.
- Captured `/Users/zhaok/cat/artifacts/tower_max_level_overlay.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed tower max level, tower action, tower upgrade feedback, playthrough, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 82 tests`.

**Image2 Battle Tower Affordability State**
- Added battle-specific project asset `/Users/zhaok/cat/assets/generated/ui/battle_tower_card_insufficient_fish_stamp.png`, derived from the existing Image2 insufficient-fish stamp, so unaffordable tower cards use raster art instead of a code-drawn warning.
- Each battle tower card now exposes `InsufficientFishState` and dynamic `InsufficientFishLabel` layers; `_update_hud()` refreshes them whenever fish changes.
- When a tower card is unaffordable, the card dims, the Image2 stamp appears, and the label shows the missing fish amount, while the transparent tower-card hit area still handles selection feedback.
- Added `/Users/zhaok/cat/tests/run_battle_tower_affordability_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_tower_affordability.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_tower_affordability.png`; GUI capture was used for visual evidence.
- Passed battle tower affordability, tower selector card, build input, battle resource feedback, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 83 tests`.

**Image2 Battle Yarn Trap Ready State**
- Added battle-specific project asset `/Users/zhaok/cat/assets/generated/ui/battle_yarn_trap_ready_burst.png`, derived from existing Image2 tap feedback artwork, for the armed yarn-trap state.
- Pressing the yarn trap with inventory but no active enemies now arms the trap instead of silently doing nothing; it does not spend inventory until an enemy appears.
- The armed state shows `BattleYarnTrapReadyFeedback` and `YarnTrapReadyHudGlow` using the Image2 ready burst, colors the yarn item icon, and updates the bottom guidance text.
- When the next enemy appears, the armed trap auto-fires, consumes one trap, emits the inventory update, clears the HUD glow, and places the existing Image2 battlefield yarn effect.
- Added `/Users/zhaok/cat/tests/run_battle_yarn_trap_ready_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_yarn_trap_ready.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_yarn_trap_ready.png`; GUI capture was used for visual evidence.
- Passed battle yarn trap ready, yarn trap, yarn inventory flow, yarn empty feedback, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 84 tests`.

**Image2 Build Slot Range Preview**
- Empty build slots now show the project-bound Image2 `tower_range_aura.png` as a translucent pre-build range preview, scaled to the currently selected tower.
- Selecting a different tower card refreshes every empty slot preview with a small rotation feedback; occupied slots hide the preview while other empty slots keep showing it.
- This slice reuses `/Users/zhaok/cat/assets/generated/effects/tower_range_aura.png`, so no visible battle guidance falls back to code-drawn circles or arcs.
- Added `/Users/zhaok/cat/tests/run_build_slot_range_preview_tests.gd` and `/Users/zhaok/cat/tests/capture_build_slot_range_preview.gd`.
- Captured `/Users/zhaok/cat/artifacts/build_slot_range_preview.png`; GUI capture was used for visual evidence.
- Passed build slot range preview, build input, tower selector card, tower range aura, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 85 tests`.

**Image2 Build Slot Tower Ghost Preview**
- Empty build slots now show a translucent Image2 tower ghost above the cat-paw marker, using the idle frame from the currently selected tower sprite sheet.
- Selecting a different tower card swaps every empty slot ghost to the selected cat and plays a small rotation feedback; occupied slots hide the ghost while other empty slots keep showing it.
- This slice reuses `/Users/zhaok/cat/assets/generated/towers/orange_cat_tower_sheet.png` and `/Users/zhaok/cat/assets/generated/towers/tabby_slow_cat_sheet.png`, so the pre-build affordance uses the same generated character art as real towers.
- Added `/Users/zhaok/cat/tests/run_build_slot_tower_ghost_tests.gd` and `/Users/zhaok/cat/tests/capture_build_slot_tower_ghost.gd`.
- Captured `/Users/zhaok/cat/artifacts/build_slot_tower_ghost.png`; GUI capture was used for visual evidence.
- Passed build slot tower ghost, build slot range preview, build input, tower selector card, battle tower affordability, tower range aura, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 86 tests`.

**Image2 Build Slot Affordability Preview**
- Empty build slots now mirror the selected tower affordability state: unaffordable tower ghosts dim and show the Image2 red paw insufficient-fish stamp before the player taps.
- The stamp uses `/Users/zhaok/cat/assets/generated/ui/battle_tower_card_insufficient_fish_stamp.png` and is scaled by texture size so it stays slot-sized instead of covering the map.
- When fish increases enough to afford the selected tower, `_update_hud()` restores the build-slot ghost color and hides the stamp without changing the selected tower.
- Added `/Users/zhaok/cat/tests/run_build_slot_affordability_preview_tests.gd` and `/Users/zhaok/cat/tests/capture_build_slot_affordability_preview.gd`.
- Captured `/Users/zhaok/cat/artifacts/build_slot_affordability_preview.png`; GUI capture was used for visual evidence.
- Passed build slot affordability preview, build slot tower ghost, build slot range preview, battle tower affordability, battle resource feedback, build input, tower selector card, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 87 tests`.

**Image2 Build Slot Affordability Feedback**
- Tapping an unaffordable empty build slot now pulses the local Image2 insufficient-fish stamp, so the failure feedback happens at the exact slot the player touched instead of only in the HUD.
- The tap still keeps the existing global `BattleResourceFeedback`, does not create a tower, and does not spend fish.
- The local stamp marks `image2_slot_affordability_feedback` during the pop animation and restores its texture-scaled badge size afterward.
- Added `/Users/zhaok/cat/tests/run_build_slot_affordability_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_build_slot_affordability_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/build_slot_affordability_feedback.png`; GUI capture was used for visual evidence.
- Passed build slot affordability feedback, build slot affordability preview, battle resource feedback, build slot tower ghost, build slot range preview, build input, tower selector card, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 88 tests`.

**Image2 Build Slot Manage Badge**
- Occupied build slots now show a small HUD-layer Image2 paw badge using `/Users/zhaok/cat/assets/generated/ui/album_paw_badge.png`, making the tower management entry visible after building.
- Tapping an occupied slot still opens the Image2 tower action panel and now pulses the local manage badge with `image2_slot_manage_feedback`; selling hides the badge and restores the buildable slot state.
- The badge is a transparent HUD texture and does not block the existing transparent build/manage hit area.
- Added `/Users/zhaok/cat/tests/run_build_slot_manage_badge_tests.gd` and `/Users/zhaok/cat/tests/capture_build_slot_manage_badge.gd`.
- Captured `/Users/zhaok/cat/artifacts/build_slot_manage_badge.png`; GUI capture was used for visual evidence.
- Passed build slot manage badge, tower action, tower sell action exit animation, build input, build slot affordability feedback, build slot affordability preview, build slot tower ghost, build slot range preview, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 89 tests`.

**Image2 Battle Speed Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_speed_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_speed_feedback_burst_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_speed_feedback_burst.png`, assembled from the existing Image2 battle HUD, tap feedback, and wave-rush art.
- Pressing the Image2 speed button now creates `BattleSpeedFeedback#` near the top-right HUD, shows a dynamic `1x` or `2x` label, and marks the speed frame with `image2_speed_feedback` while the burst pops.
- The visible speed control still comes from `/Users/zhaok/cat/assets/generated/ui/battle_speed_button.png`; Godot only adds the transparent hit area, dynamic label, and tweened feedback.
- Added `/Users/zhaok/cat/tests/run_battle_speed_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_speed_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_speed_feedback.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed battle speed feedback, battle speed/wave, battle wave rush, battle tap feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 90 tests`.

**Image2 Battle Wave Clear Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_wave_clear_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_wave_clear_burst_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_wave_clear_burst.png`, assembled from existing Image2 battle HUD, reward, tap, and wave-rush art.
- Spawned enemies now keep their wave index, and the battle scene tracks already-cleared waves so the feedback appears once when the last enemy from a wave leaves the field.
- Clearing a wave creates `BattleWaveClearFeedback#` with dynamic `第 N/M 波 清理完成` text, pulses the Image2 wave preview chip, and updates the bottom guidance copy for the next defensive decision.
- Added `/Users/zhaok/cat/tests/run_battle_wave_clear_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_wave_clear_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_wave_clear_feedback.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed battle wave clear feedback, battle speed/wave, battle wave rush, enemy reward feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 91 tests`.

**Image2 Battle Wave Incoming Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_wave_incoming_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_wave_incoming_burst_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_wave_incoming_burst.png`, assembled from existing Image2 battle HUD, enemy-spawn, wave-rush, and wave-preview art.
- The first enemy spawned from each wave now triggers `BattleWaveIncomingFeedback#` with dynamic `第 N/M 波 来袭` text, pulses the Image2 wave preview chip, and updates the bottom guidance copy.
- Subsequent enemies in the same wave do not repeat the incoming feedback, keeping the action readable.
- Added `/Users/zhaok/cat/tests/run_battle_wave_incoming_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_wave_incoming_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_wave_incoming_feedback.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed battle wave incoming feedback, battle speed/wave, battle wave rush, enemy spawn feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 92 tests`.

**Image2 Result Next-Level Unlock Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/result_next_level_unlock_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/result_next_level_unlock_burst_source.png`, and `/Users/zhaok/cat/assets/generated/ui/result_next_level_unlock_burst.png`, assembled from existing Image2 result, level, lock, paw, and star art.
- The victory result screen now detects when the current clear actually raises `_unlocked_level` and shows `ResultNextLevelUnlockFeedback` with dynamic `新关卡开放` and `第 N 关 <name>` copy near the next-level button.
- Replaying an already unlocked level does not repeat the new-level feedback, while the newly unlocked next-level button remains playable.
- Added `/Users/zhaok/cat/tests/run_result_next_level_unlock_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_result_next_level_unlock_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/result_next_level_unlock_feedback.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed result next-level unlock feedback, result screen, result screen exit animation, progression persistence, menu, playthrough, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 93 tests`.

**Image2 Result Reward Fly Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/result_reward_fly_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/result_reward_fly_fish_chip_source.png`, and `/Users/zhaok/cat/assets/generated/ui/result_reward_fly_fish_chip.png`, assembled from existing Image2 result fish chip, paw, and star art.
- The victory result screen now creates `ResultRewardFlyLayer` with three `ResultRewardFlyFish#` chips that launch from the reward area toward the top `FishCounter`.
- The fish counter marks `image2_reward_fly_target` and pulses when the reward fly feedback starts; defeat results and zero-reward results do not show the fly layer.
- Added `/Users/zhaok/cat/tests/run_result_reward_fly_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_result_reward_fly_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/result_reward_fly_feedback.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed result reward fly feedback, result screen, result next-level unlock feedback, result defeat screen, menu, playthrough, scene smoke, unit tests, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 94 tests`.

**Image2 Level Select New Unlock Hint**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/level_select_new_unlock_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/level_select_new_unlock_hint_source.png`, and `/Users/zhaok/cat/assets/generated/ui/level_select_new_unlock_hint.png`, assembled from existing Image2 level-select, lock, paw, thumbnail, and star art.
- The level-select screen now marks the highest unlocked uncleared level with `Level#NewUnlockHint` and dynamic `新关卡` label, while cleared unlocked levels do not keep the hint.
- Locked levels still show `Level#LockedBadge`, and the highlighted newly unlocked level remains playable through the existing transparent hotspot.
- The hint enters with a pop and settles into a subtle floating loop; the animation uses a weak reference so fast screen transitions do not leave freed-node callback errors.
- Added `/Users/zhaok/cat/tests/run_level_select_new_unlock_hint_tests.gd` and `/Users/zhaok/cat/tests/capture_level_select_new_unlock_hint.gd`.
- Captured `/Users/zhaok/cat/artifacts/level_select_new_unlock_hint.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed level select new unlock hint, progression persistence, menu, locked level feedback, result next-level unlock feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 95 tests`.

**Image2 Battle Wave Preview Detail**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_detail_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_detail_panel_source.png`, `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_detail_panel.png`, `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_info_badge.png`, `/Users/zhaok/cat/assets/generated/enemies/rat_tank.png`, and `/Users/zhaok/cat/assets/generated/enemies/hamster_runner.png`, assembled or extracted from existing Image2 battle HUD, album panel, card, chip, button, and enemy sprite-sheet art.
- The battle HUD now shows `WavePreviewInfoBadge` on the Image2 wave chip with a separate transparent `WavePreviewInfoButton`, leaving the existing `RushNextWaveButton` behavior intact.
- Tapping the info badge opens `BattleWavePreviewDetailOverlay` with the Image2 panel, next enemy icon, dynamic wave title, enemy count, countdown, fish reward guidance, close action, and `StartWaveFromPreviewButton`.
- Starting a wave from the detail panel triggers the existing early-wave logic, spawns the next enemy immediately, and closes the panel with the HUD overlay exit animation.
- Added `/Users/zhaok/cat/tests/run_battle_wave_preview_detail_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_wave_preview_detail.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_wave_preview_detail.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed battle wave preview detail, battle wave rush, battle wave incoming feedback, battle wave clear feedback, battle speed/wave, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 96 tests`.

**Image2 Battle First-Build Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_build_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_build_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_build_guidance_badge.png`, assembled from existing Image2 battle HUD, build marker, tap burst, paw badge, and orange cat tower art.
- The battle HUD now shows `BattleBuildGuidanceHint` near the first empty cat-paw build slot before any tower is built, with `mouse_filter` ignored so `BuildSlot1Button` remains tappable.
- The guidance enters with a pop and settles into a subtle floating loop; successfully building the first tower removes the hint immediately while the existing Image2 build-success feedback plays.
- Added `/Users/zhaok/cat/tests/run_battle_build_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_build_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_build_guidance.png`; GUI capture was used for visual evidence.
- Passed battle build guidance, build input, build success feedback, build slot range preview, build slot tower ghost, build slot affordability preview, battle tap feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 97 tests`.

**Image2 Result Defeat Retry Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/result_defeat_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/result_defeat_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/result_defeat_guidance_badge.png`, assembled from existing Image2 result button, paw, fish, star, and tap-burst art.
- Failed-level results now show `ResultDefeatGuidance` above the orange retry action with dynamic `再试一次守住` copy, while victory results do not show the defeat-only guidance.
- The guidance is a transparent, non-blocking Image2 badge with pop-in and subtle floating motion; it pulses the existing retry frame and leaves the retry, level-map, and disabled next-level actions intact.
- Added `/Users/zhaok/cat/tests/run_result_defeat_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_result_defeat_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/result_defeat_guidance.png`; GUI capture was used for visual evidence.
- Passed result defeat guidance, result defeat screen, result screen, result screen entry animation, result screen exit animation, result next-level unlock feedback, result reward fly feedback, menu, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 98 tests`.

**Image2 Energy Empty Refill Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/energy_empty_refill_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/energy_empty_refill_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/energy_empty_refill_guidance_badge.png`, assembled from existing Image2 energy, reward, tap, and paw art.
- Zero-energy level starts now show `EnergyEmptyRefillGuidance` on the Image2 energy-empty overlay, with dynamic `去补体力` copy and a transparent `EnergyEmptyRefillButton` over the existing bottom action area.
- Pressing the refill guidance exits the energy-empty overlay, opens the Image2 shop overlay, and marks/pulses `ShopEnergyRefillButtonFrame` with `image2_energy_refill_guidance_target`; it does not grant energy until the actual shop purchase button is pressed.
- `CloseEnergyEmptyButton` remains available as a small close action and still uses the shared Image2 overlay exit animation.
- Added `/Users/zhaok/cat/tests/run_energy_empty_refill_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_energy_empty_refill_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/energy_empty_refill_guidance.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed energy empty refill guidance, energy flow, shop energy refill, guidance overlay exit animation, shop product state asset, menu, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 99 tests`.

**Image2 Shop Energy Refill Return Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/shop_energy_refill_return_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/shop_energy_refill_return_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/shop_energy_refill_return_badge.png`, assembled from existing Image2 energy, level-select, play-button, paw, and tap-burst art.
- Successful shop energy-refill purchases now add `ShopEnergyRefillReturnGuidance` to the Image2 purchase success overlay, with dynamic `去闯关` copy and a transparent `ShopEnergyRefillReturnButton`.
- Pressing the return guidance exits the purchase reward overlay through the shared Image2 exit animation, leaves the shop overlay, opens level select, and preserves the purchased energy for immediate level entry.
- The original `CloseShopPurchaseRewardButton` remains available as `留在商店` on energy-refill purchases, while non-energy shop purchases keep the previous `收好补给` behavior.
- Added `/Users/zhaok/cat/tests/run_shop_energy_refill_return_tests.gd` and `/Users/zhaok/cat/tests/capture_shop_energy_refill_return.gd`.
- Captured `/Users/zhaok/cat/artifacts/shop_energy_refill_return.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed shop energy refill return, shop energy refill, shop purchase feedback, reward/shop feedback exit animation, energy empty refill guidance, menu, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 100 tests`.

**Image2 Level Select Energy-Ready Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/level_select_energy_ready_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/level_select_energy_ready_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/level_select_energy_ready_badge.png`, assembled from existing Image2 level-select, energy, play-button, paw, and tap-burst art.
- Returning to level select from a successful energy refill now sets a one-time `Level1EnergyReadyGuidance` hint near the first playable level, with dynamic `点这里开局` copy and `mouse_filter` ignored so `StartLevel1Button` remains the real hit target.
- Normal level-select visits do not show the post-refill guidance. Pressing the guided level enters battle and consumes one purchased energy.
- Added `/Users/zhaok/cat/tests/run_level_select_energy_ready_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_level_select_energy_ready_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/level_select_energy_ready_guidance.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed level select energy-ready guidance, shop energy refill return, level select new unlock hint, shop energy refill, energy flow, menu, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 101 tests`.

**Image2 Tower Action Cancel Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/tower_action_cancel_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/tower_action_cancel_feedback_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/tower_action_cancel_feedback_badge.png`, assembled from existing Image2 tower action, paw, fish, play-button, and tap-burst art.
- Closing the tower management panel now shows `TowerActionCancelFeedback` near the managed tower with dynamic `继续建造` copy, while preserving the existing Image2 overlay exit animation.
- Canceling tower management does not remove the tower, spend fish, or refund fish; it only updates the guidance copy so the player can continue building.
- Added `/Users/zhaok/cat/tests/run_tower_action_cancel_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_tower_action_cancel_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/tower_action_cancel_feedback.png`; GUI capture was required because headless viewport texture capture returns a null texture in this project.
- Passed tower action cancel feedback, tower action, battle overlay exit animation, tower sell action exit animation, build input, build slot manage badge, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 102 tests`.

**Image2 Battle Tower Selection Placement Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_tower_selection_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_tower_selection_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_tower_selection_guidance_badge.png`, assembled from existing Image2 battle HUD, tower card, selected-state, build-slot, and tap-burst art.
- Selecting an affordable tower card now shows `BattleTowerSelectionGuidance` near the first empty cat-paw build slot with dynamic `点猫爪放置` copy.
- The guidance uses `mouse_filter = IGNORE`, so the real transparent `BuildSlot#Button` remains the tappable target; successfully building the selected tower removes the guidance.
- Added `/Users/zhaok/cat/tests/run_battle_tower_selection_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_tower_selection_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_tower_selection_guidance.png`; GUI capture was used for visual evidence.
- Passed battle tower selection guidance, tower selector card, build slot tower ghost, build slot range preview, tower affordability, build input, battle build guidance, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 103 tests`.

**Image2 Battle Post-Build Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_post_build_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_post_build_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_post_build_guidance_badge.png`, assembled from existing Image2 battle guidance, paw, tower, and tap-burst art.
- Building the first tower now shows `BattlePostBuildGuidance` near the next empty cat-paw build slot with dynamic `继续补防` copy, making the second build step visible on the map.
- The guidance uses `mouse_filter = IGNORE`, so the real transparent `BuildSlot#Button` remains the tappable target; building the next tower or opening tower management removes the guidance.
- Added `/Users/zhaok/cat/tests/run_battle_post_build_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_post_build_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_post_build_guidance.png`; GUI capture was used for visual evidence.
- Passed battle post-build guidance, battle build guidance, battle tower selection guidance, build input, build success feedback, build slot manage badge, tower selector card, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 104 tests`.

**Image2 Battle Reward Fly Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_reward_fly_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_reward_fly_fish_chip_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_reward_fly_fish_chip.png`, assembled from existing Image2 fish chip, reward burst, and tap sparkle art.
- Defeating an enemy now keeps the existing local `EnemyRewardFeedback#` burst and also creates `BattleRewardFlyFish#`, a non-blocking fish chip that flies toward the top fish counter.
- The top `CoinsLabel` is marked as `image2_battle_reward_fly_target` and pulses as the fly chip arrives, making the reward-to-resource transfer clearer.
- Added `/Users/zhaok/cat/tests/run_battle_reward_fly_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_reward_fly_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_reward_fly_feedback.png`; GUI capture was used for visual evidence.
- Passed battle reward fly feedback, enemy reward feedback, enemy defeat feedback, battle wave clear feedback, battle wave incoming feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 105 tests`.

**Image2 Tower Upgrade Spend Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/tower_upgrade_spend_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/tower_upgrade_spend_fish_chip_source.png`, and `/Users/zhaok/cat/assets/generated/ui/tower_upgrade_spend_fish_chip.png`, assembled from existing Image2 battle, fish chip, and upgrade art.
- Successful tower upgrades now create `TowerUpgradeSpendFish#`, a non-blocking fish chip with dynamic `-N` text that travels from the top fish counter toward the upgraded tower before fading.
- The top `CoinsLabel` is marked as `image2_tower_upgrade_spend_source`, updates to the post-upgrade fish total before the chip launches, and pulses during the spend motion.
- Added `/Users/zhaok/cat/tests/run_tower_upgrade_spend_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_tower_upgrade_spend_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/tower_upgrade_spend_feedback.png`; GUI capture was used for visual evidence.
- Passed tower upgrade spend feedback, tower upgrade feedback, tower action, tower max level, battle tower affordability, battle resource feedback, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 106 tests`.

**Image2 Tower Sell Refund Fly Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/tower_sell_refund_fly_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/tower_sell_refund_fish_chip_source.png`, and `/Users/zhaok/cat/assets/generated/ui/tower_sell_refund_fish_chip.png`, assembled from existing Image2 sell, fish chip, and refund art.
- Successful tower sells now keep the existing local `TowerSellFeedback#` burst and also create `TowerSellRefundFlyFish#`, a non-blocking fish chip with dynamic `+N` text that flies from the sold tower slot toward the top fish counter.
- The top `CoinsLabel` is marked as `image2_tower_sell_refund_target`, updates to the post-sell fish total before the chip launches, and pulses as the refund arrives.
- Added `/Users/zhaok/cat/tests/run_tower_sell_refund_fly_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_tower_sell_refund_fly_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/tower_sell_refund_fly_feedback.png`; GUI capture was used for visual evidence.
- Passed tower sell refund fly feedback, tower sell feedback, tower sell action exit animation, tower action, build slot manage badge, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 107 tests`.

**Image2 Pause Restart Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/pause_restart_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/pause_restart_feedback_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/pause_restart_feedback_badge.png`, assembled from existing Image2 battle, pause, fish, and tap-burst art.
- Restarting from the pause menu still waits for the Image2 pause panel exit animation, then resets the level and creates `PauseRestartFeedback`, a non-blocking restart badge with dynamic `重新开局` copy.
- The restarted battle keeps build controls usable while the badge pops in, floats briefly, and fades out.
- Added `/Users/zhaok/cat/tests/run_pause_restart_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_pause_restart_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/pause_restart_feedback.png`; GUI capture was used for visual evidence.
- Passed pause restart feedback, pause menu action exit animation, pause menu, battle overlay exit animation, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 108 tests`.

**Image2 Pause Resume Feedback**
- Added project-bound Image2 assets `/Users/zhaok/cat/assets/generated/ui/pause_resume_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/pause_resume_feedback_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/pause_resume_feedback_badge.png`, combining a fresh Image2 pause-resume reference/source with existing Image2 pause, tap-burst, and battle art.
- Resuming from the pause menu still unpauses immediately and waits for the Image2 pause panel exit animation before creating `PauseResumeFeedback`, a non-blocking continue badge with dynamic `继续守卫` copy.
- The resumed battle keeps build controls usable while the green continue badge pops in, floats briefly, and fades out.
- Added `/Users/zhaok/cat/tests/run_pause_resume_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_pause_resume_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/pause_resume_feedback.png`; GUI capture was used for visual evidence.
- Passed pause resume feedback, pause restart feedback, pause menu action exit animation, pause menu, battle overlay exit animation, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 109 tests`.

**Image2 Pause Quit Level Return Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/level_select_pause_quit_return_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/level_select_pause_quit_return_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/level_select_pause_quit_return_badge.png`, assembled from existing Image2 level-select, map-button, fish, and tap-spark art.
- Exiting a paused battle to the level map now sets a one-time `PauseQuitLevelReturnGuidance` on the Image2 level-select screen, with dynamic `重新选择` copy and `回到关卡地图` support text.
- Normal level-select visits do not show the guidance, and the badge uses `mouse_filter = IGNORE` so `StartLevel1Button` remains the real hit target.
- Added `/Users/zhaok/cat/tests/run_pause_quit_level_return_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_pause_quit_level_return_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/pause_quit_level_return_guidance.png`; GUI capture was used for visual evidence.
- Passed pause quit level return guidance, menu, pause menu action exit animation, pause menu, level-select energy-ready guidance, level-select new-unlock hint, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 110 tests`.

**Image2 Battle Wave Preview Close Feedback**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_close_feedback_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_close_feedback_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/battle_wave_preview_close_feedback_badge.png`, assembled from existing Image2 wave-preview, map-button, rush, fish, and info-badge art.
- Closing the wave preview detail overlay now waits for the Image2 panel exit animation, then creates `WavePreviewCloseFeedback`, a non-blocking badge with dynamic `情报收起` copy and `继续布防` support text.
- The wave chip remains usable after the close feedback appears, and the `StartWaveFromPreviewButton` still uses the existing early-wave rush feedback path.
- Added `/Users/zhaok/cat/tests/run_battle_wave_preview_close_feedback_tests.gd` and `/Users/zhaok/cat/tests/capture_battle_wave_preview_close_feedback.gd`.
- Captured `/Users/zhaok/cat/artifacts/battle_wave_preview_close_feedback.png`; GUI capture was used for visual evidence.
- Passed battle wave preview close feedback, battle wave preview detail, battle wave rush, battle speed/wave, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 111 tests`.

**Image2 Achievement Continue Level Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/achievement_continue_level_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/achievement_continue_level_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/achievement_continue_level_guidance_badge.png`, assembled from existing Image2 achievement plaque and star assets.
- Pressing `AchievementsActionButton` now marks a one-time continue-challenge hint, runs `AchievementsOverlay` through the shared Image2 overlay exit animation, then opens the level-select screen.
- The level map now shows `AchievementContinueLevelGuidance`, a non-blocking Image2 badge with dynamic `继续挑战` and `选择关卡` copy, while leaving `StartLevel1Button` tappable.
- Added `/Users/zhaok/cat/tests/run_achievement_continue_level_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_achievement_continue_level_guidance.gd`; stabilized `/Users/zhaok/cat/tests/run_shop_energy_refill_return_tests.gd` with condition-based waits for chained Image2 transitions.
- Captured `/Users/zhaok/cat/artifacts/achievement_continue_level_guidance.png`; GUI capture was used for visual evidence.
- Passed achievement continue level guidance, overlay action exit animation, achievement progress guidance, achievement claim, menu, playthrough, the shop-return suffix regression, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 112 tests`.

**Image2 Backpack Yarn Level Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/backpack_yarn_level_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/backpack_yarn_level_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/backpack_yarn_level_guidance_badge.png`, assembled from existing Image2 yarn item and achievement plaque art.
- Tapping `去战斗` from the backpack yarn trap detail now preserves the existing Image2 detail exit animation, marks a one-time level-select hint when yarn traps are available, and routes to the level map.
- The level map now shows `BackpackYarnLevelGuidance`, a non-blocking Image2 badge with dynamic `毛线就绪` and `选关开战` copy, while leaving `StartLevel1Button` tappable and preserving yarn inventory until battle use.
- Added `/Users/zhaok/cat/tests/run_backpack_yarn_level_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_backpack_yarn_level_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/backpack_yarn_level_guidance.png`; GUI capture was used for visual evidence.
- Passed backpack yarn level guidance, backpack item detail, overlay action exit animation, battle yarn inventory flow, battle yarn trap, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 113 tests`.

**Image2 Shop Shortage Daily Task Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/shop_shortage_daily_task_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/shop_shortage_daily_task_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/shop_shortage_daily_task_guidance_badge.png`, assembled from existing Image2 daily-task, fish reward, reward burst, and shop button art after the fresh Image2 generation drifted into an unrelated fish-bone battle visual.
- Tapping `去今日任务` from `ShopInsufficientFishOverlay` now preserves the shared Image2 overlay exit animation, marks a one-time earning hint, and opens the daily task overlay.
- The daily task overlay now shows `ShopShortageDailyTaskGuidance`, a non-blocking Image2 badge with dynamic `赚鱼干` and `完成任务` copy, while leaving ready claim buttons tappable and granting no fish until the player actually claims a task.
- Added `/Users/zhaok/cat/tests/run_shop_shortage_daily_task_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_shop_shortage_daily_task_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/shop_shortage_daily_task_guidance.png`; GUI capture was used for visual evidence.
- Passed shop shortage daily-task guidance, shop insufficient fish feedback, overlay action exit animation, daily task overlay, daily task reset, shop product state asset, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 114 tests`.

**Image2 Album Detail Level Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/album_detail_level_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/album_detail_level_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/album_detail_level_guidance_badge.png`, assembled from existing Image2 album badge, orange cat tower, fish reward, and level-select art.
- Tapping `去关卡` from `AlbumEntryDetailOverlay` now preserves the existing Image2 detail exit animation, marks a one-time level-select hint, and opens the level map.
- The level map now shows `AlbumDetailLevelGuidance`, a non-blocking Image2 badge with dynamic `图鉴出发` and `选择关卡` copy, while leaving `StartLevel1Button` tappable.
- Added `/Users/zhaok/cat/tests/run_album_detail_level_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_album_detail_level_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/album_detail_level_guidance.png`; GUI capture was used for visual evidence.
- Passed album detail level guidance, album entry detail, overlay action exit animation, menu, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 115 tests`.

**Image2 Shop Yarn Purchase Backpack Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/shop_yarn_purchase_backpack_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/shop_yarn_purchase_backpack_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/shop_yarn_purchase_backpack_guidance_badge.png`, assembled from existing Image2 shop purchase, backpack, yarn, fish-chip, and button art.
- Buying `毛线陷阱` now shows `ShopYarnPurchaseBackpackGuidance`, a non-blocking Image2 badge with dynamic `去背包` and `查看毛线` copy on the purchase success overlay.
- Pressing `ShopYarnPurchaseBackpackButton` preserves the shared Image2 purchase-overlay exit animation, disables the route button during the transition, then opens `BackpackOverlay` with the purchased yarn trap inventory intact.
- Non-yarn purchases continue to show the regular purchase reward path and do not create the yarn backpack guidance.
- Added `/Users/zhaok/cat/tests/run_shop_yarn_purchase_backpack_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_shop_yarn_purchase_backpack_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/shop_yarn_purchase_backpack_guidance.png`; GUI capture was used for visual evidence.
- Passed shop yarn purchase backpack guidance, shop yarn trap, shop purchase feedback, reward shop feedback exit animation, backpack item detail, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 116 tests`.

**Image2 Daily Task Shop Return Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/daily_task_shop_return_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/daily_task_shop_return_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/daily_task_shop_return_guidance_badge.png`, assembled from existing Image2 daily-task reward, shop button, yarn, and fish art after the fresh Image2 output was not exposed as a file by the local Codex image tool.
- Routing from a shop insufficient-fish state to today tasks now marks a one-claim shop-return context without granting fish early.
- Claiming a ready daily task from that context now shows `DailyTaskShopReturnGuidance`, a non-blocking Image2 badge with dynamic `回商店` and `继续购买` copy on the reward overlay.
- Pressing `DailyTaskShopReturnButton` preserves the shared Image2 reward-overlay exit animation, disables the route button during the transition, then opens `ShopOverlay` with the earned fish intact so the yarn trap purchase is affordable.
- Normal daily task claims continue to show the regular reward overlay and do not create the shop-return guidance.
- Added `/Users/zhaok/cat/tests/run_daily_task_shop_return_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_daily_task_shop_return_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/daily_task_shop_return_guidance.png`; GUI capture was used for visual evidence.
- Passed daily task shop-return guidance, shop shortage daily-task guidance, shop insufficient fish feedback, daily task overlay, reward feedback exit animation, overlay action exit animation, shop yarn trap, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 117 tests`.

**Image2 Shop Paw Purchase Achievement Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/shop_paw_purchase_achievement_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/shop_paw_purchase_achievement_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/shop_paw_purchase_achievement_guidance_badge.png`, assembled from existing Image2 shop purchase, paw badge, achievement, star, fish, and shop button art after the fresh Image2 output was not exposed as a file by the local Codex image tool.
- Buying `猫爪徽章包` now shows `ShopPawPurchaseAchievementGuidance`, a non-blocking Image2 badge with dynamic `去成就` and `查看徽章` copy on the purchase success overlay.
- Pressing `ShopPawPurchaseAchievementButton` preserves the shared Image2 purchase-overlay exit animation, disables the route button during the transition, then opens `AchievementsOverlay` with purchased paw tokens and remaining fish intact.
- Non-paw purchases continue to show their own purchase guidance paths and do not create the paw achievement guidance.
- Added `/Users/zhaok/cat/tests/run_shop_paw_purchase_achievement_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_shop_paw_purchase_achievement_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/shop_paw_purchase_achievement_guidance.png`; GUI capture was used for visual evidence.
- Passed shop paw purchase achievement guidance, shop paw bundle, shop purchase feedback, reward shop feedback exit animation, achievement claim, shop yarn purchase backpack guidance, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 118 tests`.

**Image2 Achievement Claim Shop Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/achievement_claim_shop_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/achievement_claim_shop_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/achievement_claim_shop_guidance_badge.png`, assembled from existing Image2 achievement reward, shop-paw guidance, and cat-shop UI pieces after the fresh Image2 output was not exposed as a project-copyable file by the local Codex image tool.
- Claiming an achievement reward now shows `AchievementClaimShopGuidance`, a non-blocking Image2 badge with dynamic `去商店` and `购买补给` copy on the achievement reward overlay.
- Pressing `AchievementClaimShopButton` preserves the shared Image2 reward-overlay exit animation, disables the route button during the transition, then opens `ShopOverlay` with the claimed fish and paw token intact.
- Normal shop purchase reward overlays do not create the achievement-claim shop guidance.
- Added `/Users/zhaok/cat/tests/run_achievement_claim_shop_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_achievement_claim_shop_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/achievement_claim_shop_guidance.png`; GUI capture was used for visual evidence.
- Passed achievement claim shop guidance, achievement claim, reward shop feedback exit animation, shop buyable design, shop yarn trap, shop paw bundle, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 119 tests`.

**Image2 Result Achievement Claim Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/result_achievement_claim_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/result_achievement_claim_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/result_achievement_claim_guidance_badge.png`, assembled from existing Image2 victory result and achievement badge art after the fresh Image2 output was not exposed as a project-copyable file by the local Codex image tool.
- Winning a level now detects completed but unclaimed achievements and shows `ResultAchievementClaimGuidance`, a non-blocking Image2 badge with dynamic `去成就` and claim-ready copy on the victory result screen.
- Pressing `ResultAchievementClaimGuidanceButton` preserves the shared Image2 result-screen exit animation, disables the route button during transition, then opens `AchievementsOverlay` on the main menu with the claimable achievement intact.
- Defeat results and already-claimed achievement states do not create this result guidance.
- Added `/Users/zhaok/cat/tests/run_result_achievement_claim_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_result_achievement_claim_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/result_achievement_claim_guidance.png`; GUI capture was used for visual evidence.
- Passed result achievement claim guidance, result screen, result screen exit animation, result next-level unlock feedback, achievement claim, progression persistence, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 120 tests`.

**Image2 Daily Reward Shop Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/daily_reward_shop_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/daily_reward_shop_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/daily_reward_shop_guidance_badge.png`, assembled from the existing Image2 daily reward success reference and shop-return badge art after the fresh Image2 output was not exposed as a project-copyable file by the local Codex image tool.
- Claiming the daily reward now shows `DailyRewardShopGuidance`, a non-blocking Image2 badge with dynamic `去商店` copy on the daily reward success overlay.
- Pressing `DailyRewardShopButton` preserves the shared Image2 reward-overlay exit animation, disables the route button during the transition, then opens `ShopOverlay` with the claimed 20 fish intact.
- Daily task reward overlays continue to use their own reward paths and do not create the daily reward shop guidance.
- Added `/Users/zhaok/cat/tests/run_daily_reward_shop_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_daily_reward_shop_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/daily_reward_shop_guidance.png`; GUI capture was used for visual evidence, and the subtitle was removed after visual QA because it collided with the Image2 badge edge.
- Passed daily reward shop guidance, daily reward reset, reward overlay, reward feedback exit animation, reward claim action exit animation, shop buyable design, shop yarn trap, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 121 tests`.

**Image2 Result Reward Shop Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/result_reward_shop_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/result_reward_shop_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/result_reward_shop_guidance_badge.png`, assembled from existing Image2 result, fish reward, and shop guidance art after the fresh Image2 output was not exposed as a project-copyable file by the local Codex image tool.
- Winning a replayed level with fish reward now shows `ResultRewardShopGuidance`, a non-blocking Image2 badge with dynamic `去商店` copy on the victory result screen when no claimable achievement is pending.
- Pressing `ResultRewardShopGuidanceButton` preserves the shared Image2 result-screen exit animation, disables the route button during transition, then opens `ShopOverlay` with the earned fish intact and yarn purchase affordable when the reward covers it.
- Claimable achievement guidance and new-level unlock feedback keep priority, so the shop badge does not stack over those result-screen moments; defeat and zero-fish results do not show it.
- Added `/Users/zhaok/cat/tests/run_result_reward_shop_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_result_reward_shop_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/result_reward_shop_guidance.png`; GUI capture was used for visual evidence, and the badge was moved upward after visual QA to avoid colliding with new-level feedback and bottom actions.
- Passed result reward shop guidance, result achievement claim guidance, result next-level unlock feedback, result screen, result screen exit animation, result reward fly feedback, shop buyable design, shop yarn trap, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 122 tests`.

**Image2 Shop Starter Yarn Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/shop_starter_yarn_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/shop_starter_yarn_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/shop_starter_yarn_guidance_badge.png`, assembled from existing Image2 shop purchase, yarn, fish, and battle-ready art after the fresh Image2 output was not exposed as a project-copyable file by the local Codex image tool.
- Claiming the free starter fish pack now refreshes the yarn trap product state when the +15 fish makes the 25-fish purchase affordable: the old shortage route and stamp are removed, the Image2 buy plate appears, and the buy button becomes enabled immediately.
- The starter claim reward overlay now shows `ShopStarterYarnGuidance`, a non-blocking Image2 badge with dynamic `买毛线` copy.
- Pressing `ShopStarterYarnButton` preserves the shared Image2 purchase-overlay exit animation, disables the route button during transition, then highlights the now-buyable yarn trap target in the shop.
- Non-starter purchases do not create the starter yarn guidance, and buying yarn afterward still opens the existing backpack guidance.
- Added `/Users/zhaok/cat/tests/run_shop_starter_yarn_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_shop_starter_yarn_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/shop_starter_yarn_guidance.png`; GUI capture was used for visual evidence.
- Passed shop starter yarn guidance, shop purchase feedback, shop yarn trap, shop yarn purchase backpack guidance, shop shortage daily-task guidance, shop buyable design, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 123 tests`.

**Image2 Backpack Organize Shop Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/backpack_organize_shop_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/backpack_organize_shop_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/backpack_organize_shop_guidance_badge.png`, assembled from existing Image2 backpack reward, shop, yarn, and fish art after the fresh Image2 output was not exposed as a project-copyable file by the local Codex image tool.
- Organizing the backpack now detects when the +5 fish reward crosses the 25-fish yarn-trap price and shows `BackpackOrganizeShopGuidance`, a non-blocking Image2 badge with dynamic `去商店` copy on the reward overlay.
- Pressing `BackpackOrganizeShopButton` preserves the shared Image2 reward-overlay exit animation, disables the route button during transition, closes the backpack overlay, opens `ShopOverlay`, and highlights the now-buyable yarn trap target.
- Smaller organize rewards that do not make yarn affordable keep the regular reward overlay and do not create the shop guidance.
- Added `/Users/zhaok/cat/tests/run_backpack_organize_shop_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_backpack_organize_shop_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/backpack_organize_shop_guidance.png`; GUI capture was used for visual evidence, and the reward copy was tightened after visual QA so it no longer collides with the guidance badge.
- Passed backpack organize shop guidance, backpack organize reward, backpack item detail, shop yarn trap, shop buyable design, reward shop feedback exit animation, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 124 tests`.

**Image2 Result Energy Refill Guidance**
- Added project-bound Image2-derived assets `/Users/zhaok/cat/assets/generated/ui/result_energy_refill_guidance_design_reference.png`, `/Users/zhaok/cat/assets/generated/ui/result_energy_refill_guidance_badge_source.png`, and `/Users/zhaok/cat/assets/generated/ui/result_energy_refill_guidance_badge.png`, assembled from existing Image2 result, energy refill, shop, and fish art after the fresh Image2 output was not exposed as a project-copyable file by the local Codex image tool.
- Tapping `下一关` from a victory result with the next level unlocked but zero energy now keeps the result screen visible and shows `ResultEnergyRefillGuidance` instead of hard-cutting to the generic `EnergyEmptyOverlay`.
- Pressing `ResultEnergyRefillButton` preserves the shared Image2 result-screen exit animation, disables the route button during transition, then opens `ShopOverlay` and highlights the energy refill target.
- Normal next-level actions with energy still start the next battle.
- Zero-fish victory results now show `已领取` in the result reward row and no longer create a `+0` fish chip/count-up celebration; star celebration remains.
- Added `/Users/zhaok/cat/tests/run_result_energy_refill_guidance_tests.gd` and `/Users/zhaok/cat/tests/capture_result_energy_refill_guidance.gd`.
- Captured `/Users/zhaok/cat/artifacts/result_energy_refill_guidance.png`; GUI capture was used for visual evidence.
- Passed result energy refill guidance, result screen, result reward shop guidance, energy empty refill guidance, result screen exit animation, shop energy refill, shop energy refill return, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 125 tests`.

**Image2 Result Energy Refill Target Level**
- Result-screen empty-energy routes now remember the actual requested next level before opening the shop, instead of falling back to a generic level-one return target.
- After purchasing energy from that result route, `ShopEnergyRefillReturnButton` opens the Image2 level-select screen and places the existing `LevelSelectEnergyReadyBadge` on the requested unlocked level, such as `Level2EnergyReadyGuidance` after clearing level one.
- Direct shop energy refills still use the original level-one ready guidance, so the new target behavior is contextual and does not disturb normal shop entry.
- Added `/Users/zhaok/cat/tests/run_result_energy_refill_target_level_tests.gd` and `/Users/zhaok/cat/tests/capture_result_energy_refill_target_level.gd`.
- Captured `/Users/zhaok/cat/artifacts/result_energy_refill_target_level.png`; GUI capture was used for visual evidence.
- Passed result energy refill target level, result energy refill guidance, shop energy refill return, level-select energy ready guidance, energy empty refill guidance, shop energy refill, playthrough, and the full `/Users/zhaok/cat/tests/run_*.gd` regression suite with `FULL_REGRESSION_PASS_CLEAN 126 tests`.
