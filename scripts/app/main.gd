extends Control

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const LEVEL_BACKGROUND := preload("res://assets/generated/backgrounds/level_001_meadow.png")
const MAIN_MENU_DESIGN := preload("res://assets/generated/ui/main_menu_design_reference.png")
const LEVEL_SELECT_DESIGN := preload("res://assets/generated/ui/level_select_design_reference.png")
const LEVEL_LOCK_BADGE := preload("res://assets/generated/ui/level_lock_badge.png")
const RESULT_SCREEN_DESIGN := preload("res://assets/generated/ui/result_screen_design_reference.png")
const RESULT_SCREEN_DEFEAT_DESIGN := preload("res://assets/generated/ui/result_screen_defeat_design_reference.png")
const SETTINGS_OVERLAY_PANEL := preload("res://assets/generated/ui/settings_overlay_panel.png")
const SETTINGS_TOGGLE_ON := preload("res://assets/generated/ui/settings_toggle_on.png")
const SETTINGS_TOGGLE_OFF := preload("res://assets/generated/ui/settings_toggle_off.png")
const SETTINGS_SLIDER_TRACK := preload("res://assets/generated/ui/settings_slider_track.png")
const SETTINGS_SLIDER_KNOB := preload("res://assets/generated/ui/settings_slider_knob.png")
const SETTINGS_CLOSE_BUTTON := preload("res://assets/generated/ui/settings_close_button.png")
const ALBUM_OVERLAY_PANEL := preload("res://assets/generated/ui/album_overlay_panel.png")
const ALBUM_CARD_FRAME := preload("res://assets/generated/ui/album_card_frame.png")
const ALBUM_CLOSE_BUTTON := preload("res://assets/generated/ui/album_close_button.png")
const ALBUM_ENTRY_DETAIL_DESIGN := preload("res://assets/generated/ui/album_entry_detail_design_reference.png")
const REWARD_OVERLAY_PANEL := preload("res://assets/generated/ui/reward_overlay_panel.png")
const REWARD_CHEST := preload("res://assets/generated/ui/reward_chest.png")
const REWARD_CLAIM_BUTTON := preload("res://assets/generated/ui/reward_claim_button.png")
const REWARD_FISH_CHIP := preload("res://assets/generated/ui/reward_fish_chip.png")
const DAILY_TASK_OVERLAY_DESIGN := preload("res://assets/generated/ui/daily_task_overlay_design_reference.png")
const DAILY_TASK_CLAIM_REWARD_DESIGN := preload("res://assets/generated/ui/daily_task_claim_reward_design_reference.png")
const DAILY_TASK_CLAIM_REWARD_BURST := preload("res://assets/generated/ui/daily_task_claim_reward_burst.png")
const ENERGY_EMPTY_DESIGN := preload("res://assets/generated/ui/energy_empty_overlay_design_reference.png")
const BACKPACK_OVERLAY_DESIGN := preload("res://assets/generated/ui/backpack_overlay_design_reference.png")
const BACKPACK_ITEM_DETAIL_DESIGN := preload("res://assets/generated/ui/backpack_item_detail_design_reference.png")
const BACKPACK_ORGANIZE_REWARD_DESIGN := preload("res://assets/generated/ui/backpack_organize_reward_design_reference.png")
const ACHIEVEMENTS_OVERLAY_DESIGN := preload("res://assets/generated/ui/achievements_overlay_design_reference.png")
const ACHIEVEMENT_CLAIMED_STAMP := preload("res://assets/generated/ui/achievement_claimed_stamp.png")
const ACHIEVEMENT_CLAIM_REWARD_DESIGN := preload("res://assets/generated/ui/achievement_claim_reward_design_reference.png")
const ACHIEVEMENT_CLAIM_REWARD_BURST := preload("res://assets/generated/ui/achievement_claim_reward_burst.png")
const SHOP_PAW_BUNDLE_ICON := preload("res://assets/generated/ui/album_paw_badge.png")
const SHOP_OVERLAY_DESIGN := preload("res://assets/generated/ui/shop_overlay_design_reference.png")
const SHOP_PURCHASE_FEEDBACK_DESIGN := preload("res://assets/generated/ui/shop_purchase_feedback_design_reference.png")
const SHOP_PURCHASE_REWARD_BURST := preload("res://assets/generated/ui/shop_purchase_reward_burst.png")
const YARN_TRAP_ITEM_ICON := preload("res://assets/generated/ui/yarn_trap_item_icon.png")
const RESULT_BUTTON_ORANGE := preload("res://assets/generated/ui/result_button_orange.png")
const RESULT_BUTTON_BLUE := preload("res://assets/generated/ui/result_button_blue.png")
const RESULT_BUTTON_GREEN := preload("res://assets/generated/ui/result_button_green.png")
const RESULT_STAR_BADGE := preload("res://assets/generated/ui/result_star_badge.png")
const RESULT_REWARD_FISH_CHIP := preload("res://assets/generated/ui/result_fish_chip.png")
const CAT_TOWER_TEXTURE := preload("res://assets/generated/towers/orange_cat_tower.png")
const MOUSE_TEXTURE := preload("res://assets/generated/enemies/mouse_basic.png")
const FISH_BASE_TEXTURE := preload("res://assets/generated/bases/fish_base.png")

const LEVELS: Array[Dictionary] = [
	{"id": 1, "name": "鱼干小路", "path": "res://data/levels/level_001.json", "thumb": "res://assets/generated/ui/level_001_thumb.png"},
	{"id": 2, "name": "奶酪森林", "path": "res://data/levels/level_002.json", "thumb": "res://assets/generated/ui/level_002_thumb.png"},
	{"id": 3, "name": "月光粮仓", "path": "res://data/levels/level_003.json", "thumb": "res://assets/generated/ui/level_003_thumb.png"},
	{"id": 4, "name": "溪边栈桥", "path": "res://data/levels/level_004.json", "thumb": "res://assets/generated/ui/level_004_thumb.png"},
	{"id": 5, "name": "终点守卫战", "path": "res://data/levels/level_005.json", "thumb": "res://assets/generated/ui/level_005_thumb.png"}
]
const ACHIEVEMENTS: Array[Dictionary] = [
	{"id": "first_clear", "node": "AchievementFirstClear", "title": "首次守卫", "detail": "通关任意关卡", "target": 1, "reward_fish": 10, "reward_paws": 1, "position": Vector2(410, 250)},
	{"id": "star_collector", "node": "AchievementStars", "title": "星级收藏", "detail": "累计获得 15 颗星", "target": 15, "reward_fish": 30, "reward_paws": 2, "position": Vector2(410, 367)},
	{"id": "campaign_clear", "node": "AchievementCampaign", "title": "连续推进", "detail": "完成 5 个关卡", "target": 5, "reward_fish": 50, "reward_paws": 3, "position": Vector2(410, 484)}
]
const DAILY_TASKS: Array[Dictionary] = [
	{"id": "first_clear", "node": "DailyTaskFirstClear", "title": "今日守卫", "detail": "通关任意关卡", "target": 1, "reward_fish": 30, "position": Vector2(388, 220)},
	{"id": "star_three", "node": "DailyTaskStars", "title": "三星练习", "detail": "累计获得 3 颗星", "target": 3, "reward_fish": 20, "position": Vector2(388, 354)},
	{"id": "yarn_ready", "node": "DailyTaskYarn", "title": "准备毛线", "detail": "拥有 1 个毛线陷阱", "target": 1, "reward_fish": 15, "position": Vector2(388, 488)}
]

const VIEW_SIZE := Vector2(1280, 720)
const INK := Color(0.27, 0.13, 0.07)
const CREAM := Color(1.0, 0.94, 0.72)
const HONEY := Color(1.0, 0.76, 0.25)
const ORANGE := Color(0.98, 0.48, 0.20)
const GREEN := Color(0.46, 0.76, 0.34)
const BLUE := Color(0.34, 0.67, 0.86)
const CORAL := Color(0.94, 0.30, 0.22)
const SAVE_PATH := "user://meow_defense_save.json"
const DEFAULT_MAX_ENERGY := 15
const ENERGY_REFILL_COST := 10
const ENERGY_REFILL_AMOUNT := 5

var _current: Node
var _best_stars: int = 0
var _best_stars_by_level: Dictionary = {}
var _total_fish: int = 0
var _unlocked_level: int = 1
var _save_path: String = SAVE_PATH
var _current_level_id: int = 1
var _current_level_path: String = "res://data/levels/level_001.json"
var _music_enabled: bool = true
var _effects_enabled: bool = true
var _volume: float = 82.0
var _daily_reward_claimed: bool = false
var _daily_reward_claimed_on: String = ""
var _daily_reward_streak: int = 0
var _reward_date_override: String = ""
var _shop_starter_claimed: bool = false
var _paw_tokens: int = 0
var _claimed_achievements: Dictionary = {}
var _claimed_daily_tasks: Dictionary = {}
var _claimed_daily_tasks_by_date: Dictionary = {}
var _yarn_traps: int = 0
var _backpack_organized: bool = false
var _max_energy: int = DEFAULT_MAX_ENERGY
var _energy: int = DEFAULT_MAX_ENERGY
var _energy_refilled_on: String = ""


func _ready() -> void:
	get_tree().paused = false
	_load_progress()
	_sync_energy_for_today()
	_show_main_menu()


func _clear_current() -> void:
	get_tree().paused = false
	if _current != null:
		_current.queue_free()
		_current = null


func _show_main_menu() -> void:
	_clear_current()
	_sync_energy_for_today()
	var screen: Control = _image_design_screen("MainMenuScreen", MAIN_MENU_DESIGN)
	_current = screen
	add_child(screen)
	screen.add_child(_label("MainEnergyCounter", _energy_text(), Vector2(1044, 28), Vector2(112, 42), 25, INK, HORIZONTAL_ALIGNMENT_CENTER))

	var start_button: Button = _hotspot_button("StartLevelSelectButton", Vector2(115, 263), Vector2(408, 100), "开始闯关")
	start_button.pressed.connect(_show_level_select)
	screen.add_child(start_button)

	var level_button: Button = _hotspot_button("LevelShortcutButton", Vector2(138, 373), Vector2(318, 78), "关卡")
	level_button.pressed.connect(_show_level_select)
	screen.add_child(level_button)

	var settings_button: Button = _hotspot_button("SettingsButton", Vector2(138, 463), Vector2(318, 78), "设置")
	settings_button.pressed.connect(func() -> void: _show_settings_overlay(screen))
	screen.add_child(settings_button)

	var album_button: Button = _hotspot_button("AlbumButton", Vector2(138, 553), Vector2(318, 78), "图鉴")
	album_button.pressed.connect(func() -> void: _show_album_overlay(screen))
	screen.add_child(album_button)

	var gift_button: Button = _hotspot_button("DailyRewardButton", Vector2(1100, 170), Vector2(160, 150), "限时活动")
	gift_button.pressed.connect(func() -> void: _show_reward_overlay(screen))
	screen.add_child(gift_button)

	var daily_task_button: Button = _hotspot_button("DailyTaskButton", Vector2(1005, 426), Vector2(195, 130), "今日任务")
	daily_task_button.pressed.connect(func() -> void: _show_daily_task_overlay(screen))
	screen.add_child(daily_task_button)

	var bottom_home: Button = _hotspot_button("BottomHomeButton", Vector2(326, 633), Vector2(150, 82), "主城")
	bottom_home.pressed.connect(_show_main_menu)
	screen.add_child(bottom_home)
	var bottom_bag: Button = _hotspot_button("BottomBagButton", Vector2(508, 620), Vector2(140, 94), "背包")
	bottom_bag.pressed.connect(func() -> void: _show_backpack_overlay(screen))
	screen.add_child(bottom_bag)
	var bottom_achievements: Button = _hotspot_button("BottomAchievementsButton", Vector2(683, 620), Vector2(150, 94), "成就")
	bottom_achievements.pressed.connect(func() -> void: _show_achievements_overlay(screen))
	screen.add_child(bottom_achievements)
	var bottom_shop: Button = _hotspot_button("BottomShopButton", Vector2(870, 620), Vector2(150, 94), "商店")
	bottom_shop.pressed.connect(func() -> void: _show_shop_overlay(screen))
	screen.add_child(bottom_shop)
	var settings_gear: Button = _hotspot_button("SettingsGearButton", Vector2(1205, 12), Vector2(66, 66), "设置")
	settings_gear.pressed.connect(func() -> void: _show_settings_overlay(screen))
	screen.add_child(settings_gear)


func _show_level_select() -> void:
	_clear_current()
	_sync_energy_for_today()
	var screen: Control = _image_design_screen("LevelSelectScreen", LEVEL_SELECT_DESIGN, "LevelSelectDesignBackground")
	_current = screen
	add_child(screen)
	screen.add_child(_label("LevelEnergyCounter", _energy_text(), Vector2(1044, 28), Vector2(112, 42), 25, INK, HORIZONTAL_ALIGNMENT_CENTER))

	var back_button: Button = _hotspot_button("BackToMainButton", Vector2(330, 580), Vector2(118, 120), "返回主城")
	back_button.pressed.connect(_show_main_menu)
	screen.add_child(back_button)

	var settings_button: Button = _hotspot_button("LevelSettingsButton", Vector2(1178, 10), Vector2(74, 72), "设置")
	settings_button.pressed.connect(func() -> void: _show_settings_overlay(screen))
	screen.add_child(settings_button)

	var level_hotspots: Array[Dictionary] = [
		{"button": "StartLevel1Button", "rect": Rect2(Vector2(178, 166), Vector2(210, 176)), "level": LEVELS[0]},
		{"button": "StartLevel2Button", "rect": Rect2(Vector2(526, 166), Vector2(210, 176)), "level": LEVELS[1]},
		{"button": "StartLevel3Button", "rect": Rect2(Vector2(858, 176), Vector2(212, 178)), "level": LEVELS[2]},
		{"button": "StartLevel4Button", "rect": Rect2(Vector2(368, 368), Vector2(210, 180)), "level": LEVELS[3]},
		{"button": "StartLevel5Button", "rect": Rect2(Vector2(714, 376), Vector2(222, 178)), "level": LEVELS[4]}
	]
	for hotspot: Dictionary in level_hotspots:
		var rect: Rect2 = hotspot["rect"] as Rect2
		var level_info: Dictionary = (hotspot["level"] as Dictionary).duplicate(true)
		var level_id: int = int(level_info.get("id", 1))
		var unlocked: bool = _is_level_unlocked(level_id)
		var button: Button = _hotspot_button(str(hotspot["button"]), rect.position, rect.size, "出发")
		button.disabled = not unlocked
		if unlocked:
			button.pressed.connect(func() -> void: _start_level(level_info))
		else:
			button.tooltip_text = "通关前一关解锁"
			_add_level_lock_badge(screen, level_id, rect)
		screen.add_child(button)

	var bottom_home: Button = _hotspot_button("BottomHomeButton", Vector2(330, 580), Vector2(118, 120), "主城")
	bottom_home.pressed.connect(_show_main_menu)
	screen.add_child(bottom_home)
	var bottom_levels: Button = _hotspot_button("BottomLevelsButton", Vector2(500, 576), Vector2(128, 126), "关卡")
	bottom_levels.pressed.connect(_show_level_select)
	screen.add_child(bottom_levels)
	var bottom_album: Button = _hotspot_button("BottomAlbumButton", Vector2(680, 584), Vector2(118, 118), "图鉴")
	bottom_album.pressed.connect(func() -> void: _show_album_overlay(screen))
	screen.add_child(bottom_album)
	var bottom_shop: Button = _hotspot_button("BottomShopButton", Vector2(840, 584), Vector2(122, 118), "商店")
	bottom_shop.pressed.connect(func() -> void: _show_shop_overlay(screen))
	screen.add_child(bottom_shop)


func _start_level_one() -> void:
	_start_level(LEVELS[0])


func _start_level(level_info: Dictionary) -> void:
	var requested_level_id: int = int(level_info.get("id", 1))
	if not _is_level_unlocked(requested_level_id):
		_show_level_select()
		return
	_sync_energy_for_today()
	if _energy <= 0:
		if _current != null:
			_show_energy_empty_overlay(_current)
		return
	_energy = max(0, _energy - 1)
	_save_progress()
	_clear_current()
	_current_level_id = requested_level_id
	_current_level_path = str(level_info.get("path", "res://data/levels/level_001.json"))
	var battle: Node2D = BattleSceneScript.new()
	battle.name = "BattleScene"
	battle.set("yarn_traps_available", _yarn_traps)
	battle.battle_finished.connect(_show_result)
	if battle.has_signal("exit_to_levels_requested"):
		battle.exit_to_levels_requested.connect(_show_level_select)
	if battle.has_signal("yarn_traps_changed"):
		battle.yarn_traps_changed.connect(_on_battle_yarn_traps_changed)
	_current = battle
	add_child(battle)
	battle.start_level(_current_level_path)


func _on_battle_yarn_traps_changed(count: int) -> void:
	_yarn_traps = max(0, count)
	_save_progress()


func _show_result(won: bool, stars: int, fish_reward: int) -> void:
	get_tree().paused = false
	var earned_stars: int = max(0, min(3, stars))
	if earned_stars > _level_stars(_current_level_id):
		_best_stars_by_level[_current_level_id] = earned_stars
	if won:
		_unlocked_level = max(_unlocked_level, min(LEVELS.size(), _current_level_id + 1))
	_total_fish += fish_reward
	_recalculate_best_stars()
	_save_progress()
	_clear_current()

	var result_design: Texture2D = RESULT_SCREEN_DESIGN if won else RESULT_SCREEN_DEFEAT_DESIGN
	var screen: Control = _image_design_screen("ResultScreen", result_design, "ResultDesignBackground")
	_current = screen
	add_child(screen)
	_add_result_resource_strip(screen)

	var title_text: String = "守住啦！" if won else "猫粮罐被偷空了"
	screen.add_child(_label("ResultTitle", title_text, Vector2(486, 152), Vector2(316, 58), 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	screen.add_child(_label("ResultFishReward", "+%d" % fish_reward, Vector2(496, 452), Vector2(108, 48), 28, INK, HORIZONTAL_ALIGNMENT_CENTER))
	screen.add_child(_label("ResultBestRecord", _star_text(_level_stars(_current_level_id)), Vector2(736, 452), Vector2(128, 48), 26, INK, HORIZONTAL_ALIGNMENT_CENTER))
	if won:
		_add_result_reward_celebration(screen, earned_stars, fish_reward)

	var retry_button: Button = _result_action_button(screen, "RetryButton", "ResultRetryFrame", RESULT_BUTTON_ORANGE, "再来一次", Vector2(272, 562), Vector2(242, 92), 25)
	retry_button.pressed.connect(func() -> void: _start_level(_level_info_by_id(_current_level_id)))

	var levels_button: Button = _result_action_button(screen, "ResultLevelsButton", "ResultLevelsFrame", RESULT_BUTTON_BLUE, "关卡地图", Vector2(512, 560), Vector2(258, 96), 25)
	levels_button.pressed.connect(_show_level_select)

	var next_level_id: int = _current_level_id + 1
	var next_disabled: bool = _current_level_id >= LEVELS.size() or not _is_level_unlocked(next_level_id)
	var next_button: Button
	if not won:
		screen.add_child(_label("NextLevelButtonLabel", "未解锁", Vector2(862, 560), Vector2(154, 98), 25, INK, HORIZONTAL_ALIGNMENT_CENTER))
		next_button = _hotspot_button("NextLevelButton", Vector2(774, 560), Vector2(258, 98), "未解锁")
		next_button.disabled = true
		screen.add_child(next_button)
	elif next_disabled:
		next_button = _result_action_button(screen, "NextLevelButton", "ResultNextFrame", RESULT_BUTTON_GREEN, "下一关", Vector2(774, 560), Vector2(258, 98), 25)
		next_button.disabled = true
		var next_label: Label = screen.find_child("NextLevelButtonLabel", true, false) as Label
		if next_label != null:
			next_label.text = "已通关" if _current_level_id >= LEVELS.size() else "未解锁"
	else:
		next_button = _result_action_button(screen, "NextLevelButton", "ResultNextFrame", RESULT_BUTTON_GREEN, "下一关", Vector2(774, 560), Vector2(258, 98), 25)
		next_button.pressed.connect(func() -> void: _start_level(_level_info_by_id(next_level_id)))


func _show_settings_overlay(parent: Node) -> void:
	_remove_named_child(parent, "SettingsOverlay")
	var overlay: Control = _overlay("SettingsOverlay")
	parent.add_child(overlay)

	var panel: TextureRect = _ui_texture_rect("SettingsDesignPanel", SETTINGS_OVERLAY_PANEL, Vector2(340, 34), Vector2(600, 660))
	overlay.add_child(panel)
	overlay.add_child(_label("SettingsTitle", "设置", Vector2(426, 126), Vector2(428, 58), 44, INK, HORIZONTAL_ALIGNMENT_CENTER))
	overlay.add_child(_label("MusicLabel", "背景音乐", Vector2(532, 260), Vector2(142, 46), 25, INK, HORIZONTAL_ALIGNMENT_LEFT))
	overlay.add_child(_label("EffectsLabel", "按钮音效", Vector2(532, 356), Vector2(142, 46), 25, INK, HORIZONTAL_ALIGNMENT_LEFT))
	overlay.add_child(_label("VolumeLabel", "总音量", Vector2(532, 406), Vector2(118, 34), 22, INK, HORIZONTAL_ALIGNMENT_LEFT))

	var music_frame: TextureRect = _ui_texture_rect("SettingsMusicToggleFrame", SETTINGS_TOGGLE_ON if _music_enabled else SETTINGS_TOGGLE_OFF, Vector2(680, 248), Vector2(216, 74))
	overlay.add_child(music_frame)
	var music_toggle: CheckButton = _invisible_toggle("MusicToggle", Rect2(music_frame.position, music_frame.size), _music_enabled)
	music_toggle.toggled.connect(func(enabled: bool) -> void:
		_music_enabled = enabled
		music_frame.texture = SETTINGS_TOGGLE_ON if enabled else SETTINGS_TOGGLE_OFF
		_pulse_control(music_frame)
		_save_progress()
	)
	overlay.add_child(music_toggle)

	var effects_frame: TextureRect = _ui_texture_rect("SettingsEffectsToggleFrame", SETTINGS_TOGGLE_ON if _effects_enabled else SETTINGS_TOGGLE_OFF, Vector2(680, 344), Vector2(216, 74))
	overlay.add_child(effects_frame)
	var effects_toggle: CheckButton = _invisible_toggle("EffectsToggle", Rect2(effects_frame.position, effects_frame.size), _effects_enabled)
	effects_toggle.toggled.connect(func(enabled: bool) -> void:
		_effects_enabled = enabled
		effects_frame.texture = SETTINGS_TOGGLE_ON if enabled else SETTINGS_TOGGLE_OFF
		_pulse_control(effects_frame)
		_save_progress()
	)
	overlay.add_child(effects_toggle)

	var slider_frame: TextureRect = _ui_texture_rect("SettingsVolumeSliderFrame", SETTINGS_SLIDER_TRACK, Vector2(558, 448), Vector2(310, 64))
	overlay.add_child(slider_frame)
	var slider_knob: TextureRect = _ui_texture_rect("SettingsVolumeKnobFrame", SETTINGS_SLIDER_KNOB, Vector2.ZERO, Vector2(70, 54))
	overlay.add_child(slider_knob)
	var slider: HSlider = HSlider.new()
	slider.name = "VolumeSlider"
	slider.position = Vector2(580, 446)
	slider.size = Vector2(268, 68)
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.value = _volume
	slider.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_position_settings_slider_knob(slider_knob, slider)
	slider.value_changed.connect(func(value: float) -> void:
		_volume = value
		_position_settings_slider_knob(slider_knob, slider)
		_save_progress()
	)
	overlay.add_child(slider)

	var close_frame: TextureRect = _ui_texture_rect("SettingsCloseFrame", SETTINGS_CLOSE_BUTTON, Vector2(474, 570), Vector2(332, 92))
	overlay.add_child(close_frame)
	var close_button: Button = _transparent_text_button("CloseSettingsButton", "完成", Rect2(close_frame.position, close_frame.size), 28)
	_attach_button_feedback(close_button, close_frame)
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	overlay.add_child(close_button)


func _add_result_resource_strip(parent: Control) -> void:
	parent.add_child(_label("FishCounter", "%d" % _total_fish, Vector2(850, 38), Vector2(92, 44), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	parent.add_child(_label("BestStarsCounter", "%d" % _best_stars, Vector2(1036, 38), Vector2(70, 44), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	parent.add_child(_label("ProgressCounter", "%d" % _current_level_id, Vector2(1202, 38), Vector2(54, 44), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))


func _add_result_reward_celebration(parent: Control, earned_stars: int, fish_reward: int) -> void:
	var layer: Control = Control.new()
	layer.name = "ResultRewardCelebrationLayer"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = 8
	parent.add_child(layer)

	var star_count: int = max(1, min(3, earned_stars))
	for index: int in range(star_count):
		var star_position := Vector2(510 + index * 74, 272 - abs(index - 1) * 12)
		var star: TextureRect = _ui_texture_rect("ResultRewardStar%d" % (index + 1), RESULT_STAR_BADGE, star_position, Vector2(76, 76))
		star.pivot_offset = star.size * 0.5
		star.scale = Vector2(0.62, 0.62)
		star.modulate = Color(1.0, 1.0, 1.0, 0.0)
		layer.add_child(star)
		_animate_result_reward_piece(star, 0.08 + index * 0.08, Vector2(1.0, 1.0))

	var fish_chip: TextureRect = _ui_texture_rect("ResultRewardFishChip", RESULT_REWARD_FISH_CHIP, Vector2(814, 96), Vector2(92, 92))
	fish_chip.pivot_offset = fish_chip.size * 0.5
	fish_chip.scale = Vector2(0.72, 0.72)
	fish_chip.modulate = Color(1.0, 1.0, 1.0, 0.0)
	layer.add_child(fish_chip)
	_animate_result_reward_piece(fish_chip, 0.24, Vector2(0.88, 0.88))

	var count_label: Label = _label("ResultRewardCountUpLabel", "+%d" % fish_reward, Vector2(892, 120), Vector2(112, 40), 24, INK, HORIZONTAL_ALIGNMENT_LEFT)
	count_label.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.66, 0.90))
	count_label.add_theme_constant_override("outline_size", 3)
	count_label.pivot_offset = count_label.size * 0.5
	count_label.scale = Vector2(0.86, 0.86)
	count_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	layer.add_child(count_label)
	_animate_result_reward_piece(count_label, 0.30, Vector2.ONE)
	_pulse_result_reward_label(count_label)


func _animate_result_reward_piece(target: Control, delay: float, final_scale: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", final_scale, 0.20).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate:a", 1.0, 0.12).set_delay(delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _pulse_result_reward_label(label: Label) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.08, 1.08), 0.12).set_delay(0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _result_action_button(parent: Control, button_name: String, frame_name: String, texture: Texture2D, text: String, position: Vector2, size: Vector2, font_size: int) -> Button:
	var frame: TextureRect = _ui_texture_rect(frame_name, texture, position, size)
	parent.add_child(frame)
	var label: Label = _label("%sLabel" % button_name, text, position + Vector2(size.x * 0.34, 0.0), Vector2(size.x * 0.60, size.y), font_size, INK, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.66, 0.88))
	label.add_theme_constant_override("outline_size", 3)
	parent.add_child(label)
	var button: Button = _hotspot_button(button_name, position, size, text)
	_attach_button_feedback(button, frame)
	parent.add_child(button)
	return button


func _show_album_overlay(parent: Node) -> void:
	_remove_named_child(parent, "AlbumOverlay")
	var overlay: Control = _overlay("AlbumOverlay")
	parent.add_child(overlay)

	var content: Control = Control.new()
	content.name = "AlbumContent"
	content.size = VIEW_SIZE
	overlay.add_child(content)

	var panel: TextureRect = _ui_texture_rect("AlbumDesignPanel", ALBUM_OVERLAY_PANEL, Vector2(142, -4), Vector2(996, 720))
	content.add_child(panel)
	content.add_child(_label("AlbumTitle", "守卫图鉴", Vector2(418, 92), Vector2(444, 56), 40, INK, HORIZONTAL_ALIGNMENT_CENTER))

	var card_size := Vector2(248, 368)
	_album_entry_card(content, "AlbumTower", CAT_TOWER_TEXTURE, "橘猫鱼骨炮", "费用 60", "单体输出", "鱼骨炮锁定最近目标，适合守住弯道。", Vector2(250, 204), card_size)
	_album_entry_card(content, "AlbumMouse", MOUSE_TEXTURE, "偷鱼干小鼠", "速度 普通", "奖励 +5", "常见入侵者，会沿着小路偷走鱼干。", Vector2(516, 204), card_size)
	_album_entry_card(content, "AlbumBase", FISH_BASE_TEXTURE, "猫粮罐", "生命 10", "守护目标", "剩余生命决定结算星级，别让它被搬空。", Vector2(782, 204), card_size)

	var close_frame: TextureRect = _ui_texture_rect("AlbumCloseFrame", ALBUM_CLOSE_BUTTON, Vector2(456, 604), Vector2(368, 88))
	content.add_child(close_frame)
	var close_button: Button = _transparent_text_button("CloseAlbumButton", "收起图鉴", Rect2(close_frame.position, close_frame.size), 27)
	_attach_button_feedback(close_button, close_frame)
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	content.add_child(close_button)
	_animate_overlay_entry(content)


func _show_reward_overlay(parent: Node) -> void:
	_remove_named_child(parent, "RewardOverlay")
	var overlay: Control = _overlay("RewardOverlay")
	parent.add_child(overlay)
	var claimed_today: bool = _is_daily_reward_claimed_today()
	_daily_reward_claimed = claimed_today

	var content: Control = Control.new()
	content.name = "RewardContent"
	content.size = VIEW_SIZE
	overlay.add_child(content)

	var panel: TextureRect = _ui_texture_rect("RewardDesignPanel", REWARD_OVERLAY_PANEL, Vector2(340, 68), Vector2(600, 458))
	content.add_child(panel)
	content.add_child(_label("RewardTitle", "每日奖励", Vector2(458, 156), Vector2(364, 54), 39, INK, HORIZONTAL_ALIGNMENT_CENTER))

	var chest: TextureRect = _ui_texture_rect("RewardChestFrame", REWARD_CHEST, Vector2(472, 206), Vector2(336, 276))
	content.add_child(chest)
	var reward_chip: TextureRect = _ui_texture_rect("RewardFishChipFrame", REWARD_FISH_CHIP, Vector2(478, 426), Vector2(324, 84))
	content.add_child(reward_chip)
	var reward_text: String = "小鱼干 +20" if not claimed_today else "今日已领取"
	content.add_child(_label("RewardFishAmount", reward_text, Vector2(570, 442), Vector2(210, 48), 26, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var streak_text: String = "连续 %d 天" % max(0, _daily_reward_streak)
	if _daily_reward_streak <= 0:
		streak_text = "连续奖励"
	content.add_child(_label("RewardStreakLabel", streak_text, Vector2(800, 384), Vector2(118, 28), 17, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER))

	var claim_frame: TextureRect = _ui_texture_rect("RewardClaimFrame", REWARD_CLAIM_BUTTON, Vector2(468, 560), Vector2(344, 78))
	content.add_child(claim_frame)
	var claim_text: String = "领取奖励" if not claimed_today else "今日已领取"
	var claim: Button = _transparent_text_button("ClaimRewardButton", claim_text, Rect2(claim_frame.position, claim_frame.size), 26)
	claim.disabled = claimed_today
	_attach_button_feedback(claim, claim_frame)
	claim.pressed.connect(func() -> void:
		if _claim_daily_reward():
			_pulse_control(chest)
		overlay.queue_free()
	)
	content.add_child(claim)
	var close_button: Button = _hotspot_button("CloseRewardButton", Vector2(846, 92), Vector2(88, 88), "关闭")
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	content.add_child(close_button)
	_animate_overlay_entry(content)


func _claim_daily_reward() -> bool:
	if _is_daily_reward_claimed_today():
		_daily_reward_claimed = true
		return false
	var today: String = _today_key()
	var previous_claimed_on: String = _daily_reward_claimed_on
	var day_gap: int = _days_between(previous_claimed_on, today)
	_daily_reward_streak = _daily_reward_streak + 1 if day_gap == 1 else 1
	_daily_reward_claimed_on = today
	_daily_reward_claimed = true
	_total_fish += 20
	_save_progress()
	return true


func _is_daily_reward_claimed_today() -> bool:
	return not _daily_reward_claimed_on.is_empty() and _daily_reward_claimed_on == _today_key()


func _today_key() -> String:
	if not _reward_date_override.is_empty():
		return _reward_date_override
	var date_parts: Dictionary = Time.get_date_dict_from_system(false)
	return "%04d-%02d-%02d" % [int(date_parts.get("year", 0)), int(date_parts.get("month", 0)), int(date_parts.get("day", 0))]


func _days_between(from_date: String, to_date: String) -> int:
	var from_index: int = _date_key_to_day_index(from_date)
	var to_index: int = _date_key_to_day_index(to_date)
	if from_index < 0 or to_index < 0:
		return 0
	return to_index - from_index


func _date_key_to_day_index(date_key: String) -> int:
	var parts: PackedStringArray = date_key.split("-")
	if parts.size() != 3:
		return -1
	var unix_time: int = int(Time.get_unix_time_from_datetime_dict({
		"year": int(parts[0]),
		"month": int(parts[1]),
		"day": int(parts[2]),
		"hour": 0,
		"minute": 0,
		"second": 0
	}))
	return int(floor(float(unix_time) / 86400.0))


func _sync_energy_for_today() -> void:
	var today: String = _today_key()
	_max_energy = max(1, _max_energy)
	if _energy_refilled_on != today:
		_energy = _max_energy
		_energy_refilled_on = today
	else:
		_energy = max(0, min(_max_energy, _energy))


func _energy_text() -> String:
	return "%d/%d" % [max(0, min(_max_energy, _energy)), max(1, _max_energy)]


func _show_energy_empty_overlay(parent: Node) -> void:
	_remove_named_child(parent, "EnergyEmptyOverlay")
	var overlay: Control = Control.new()
	overlay.name = "EnergyEmptyOverlay"
	overlay.size = VIEW_SIZE
	overlay.z_index = 30
	parent.add_child(overlay)

	var design: TextureRect = _ui_texture_rect("EnergyEmptyDesignBackground", ENERGY_EMPTY_DESIGN, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	overlay.add_child(design)
	overlay.add_child(_label("EnergyEmptyTitle", "体力不足", Vector2(450, 118), Vector2(380, 60), 40, INK, HORIZONTAL_ALIGNMENT_CENTER))
	overlay.add_child(_label("EnergyEmptyStatus", "当前体力 %s" % _energy_text(), Vector2(482, 446), Vector2(316, 42), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var close_button: Button = _transparent_text_button("CloseEnergyEmptyButton", "知道了", Rect2(Vector2(420, 505), Vector2(440, 92)), 30)
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	overlay.add_child(close_button)
	_animate_overlay_entry(overlay)


func _show_daily_task_overlay(parent: Node) -> void:
	_sync_claimed_daily_tasks_for_today()
	var content: Control = _image_overlay(parent, "DailyTaskOverlay", "DailyTaskDesignBackground", DAILY_TASK_OVERLAY_DESIGN)
	content.add_child(_label("DailyTaskTitle", "今日任务", Vector2(444, 100), Vector2(392, 58), 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	for task: Dictionary in DAILY_TASKS:
		_daily_task_row(content, task)
	var close_button: Button = _hotspot_button("CloseDailyTaskButton", Vector2(958, 84), Vector2(92, 92), "关闭")
	close_button.pressed.connect(func() -> void: content.get_parent().queue_free())
	content.add_child(close_button)
	_animate_overlay_entry(content)


func _daily_task_row(parent: Control, task: Dictionary) -> void:
	var task_id: String = str(task.get("id", ""))
	var row_name: String = str(task.get("node", "DailyTask"))
	var position: Vector2 = task.get("position", Vector2.ZERO) as Vector2
	var target: int = max(1, int(task.get("target", 1)))
	var progress_value: int = min(target, _daily_task_progress(task_id))
	var ready: bool = progress_value >= target
	var claimed: bool = _is_daily_task_claimed(task_id)
	var reward_fish: int = max(0, int(task.get("reward_fish", 0)))
	var title: String = str(task.get("title", "任务"))
	var detail: String = str(task.get("detail", "完成目标"))

	parent.add_child(_label("%sTitle" % row_name, title, position, Vector2(300, 32), 23, INK, HORIZONTAL_ALIGNMENT_LEFT))
	parent.add_child(_label("%sDetail" % row_name, detail, position + Vector2(0, 34), Vector2(330, 30), 17, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_LEFT))
	var reward_label: Label = _label("%sReward" % row_name, "奖励 +%d" % reward_fish, position + Vector2(0, 56), Vector2(250, 26), 15, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_LEFT)
	parent.add_child(reward_label)
	var progress_label: Label = _label("%sProgress" % row_name, "%d/%d" % [progress_value, target], position + Vector2(330, 30), Vector2(104, 42), 21, INK, HORIZONTAL_ALIGNMENT_CENTER)
	parent.add_child(progress_label)
	var claim_label_text: String = "已领取" if claimed else ("领取" if ready else "未完成")
	var claim_label: Label = _label("%sClaimLabel" % row_name, claim_label_text, position + Vector2(430, 26), Vector2(154, 50), 23, INK, HORIZONTAL_ALIGNMENT_CENTER)
	parent.add_child(claim_label)
	var claim_button: Button = _hotspot_button("Claim%sButton" % row_name, position + Vector2(410, 14), Vector2(178, 70), claim_label_text)
	claim_button.disabled = claimed or not ready
	claim_button.pressed.connect(func() -> void:
		_claim_daily_task(task, parent, claim_label, claim_button)
	)
	parent.add_child(claim_button)


func _daily_task_progress(task_id: String) -> int:
	match task_id:
		"first_clear":
			return min(_completed_level_count(), 1)
		"star_three":
			return min(_best_stars, 3)
		"yarn_ready":
			return min(_yarn_traps, 1)
	return 0


func _is_daily_task_claimed(task_id: String) -> bool:
	_sync_claimed_daily_tasks_for_today()
	return bool(_claimed_daily_tasks.get(task_id, false))


func _claim_daily_task(task: Dictionary, parent: Control, claim_label: Label, claim_button: Button) -> void:
	var task_id: String = str(task.get("id", ""))
	if task_id.is_empty() or _is_daily_task_claimed(task_id):
		return
	var target: int = max(1, int(task.get("target", 1)))
	if _daily_task_progress(task_id) < target:
		return
	var today: String = _today_key()
	var today_claims: Dictionary = _daily_task_claim_bucket(today)
	today_claims[task_id] = true
	_claimed_daily_tasks_by_date[today] = today_claims
	_claimed_daily_tasks[task_id] = true
	_total_fish += max(0, int(task.get("reward_fish", 0)))
	_save_progress()
	claim_label.text = "已领取"
	claim_button.disabled = true
	_pulse_control(parent)
	_show_daily_task_claim_reward_overlay(parent, task)


func _show_daily_task_claim_reward_overlay(parent: Control, task: Dictionary) -> void:
	_remove_named_child(parent, "DailyTaskClaimRewardOverlay")
	var reward: Control = Control.new()
	reward.name = "DailyTaskClaimRewardOverlay"
	reward.size = VIEW_SIZE
	reward.z_index = 18
	parent.add_child(reward)

	var design: TextureRect = _ui_texture_rect("DailyTaskClaimRewardDesignBackground", DAILY_TASK_CLAIM_REWARD_DESIGN, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	reward.add_child(design)

	var burst: TextureRect = _ui_texture_rect("DailyTaskClaimRewardBurst", DAILY_TASK_CLAIM_REWARD_BURST, Vector2(366, 294), Vector2(174, 174))
	burst.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	burst.modulate = Color(1.0, 1.0, 1.0, 0.88)
	burst.z_index = 1
	reward.add_child(burst)

	var title: String = str(task.get("title", "今日任务"))
	var detail: String = str(task.get("detail", "任务奖励已领取"))
	var reward_fish: int = max(0, int(task.get("reward_fish", 0)))
	var title_label: Label = _label("DailyTaskClaimRewardTitle", "任务完成：%s" % title, Vector2(404, 98), Vector2(470, 58), 32, INK, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.z_index = 2
	reward.add_child(title_label)
	var copy: Label = _label("DailyTaskClaimRewardCopy", detail, Vector2(694, 306), Vector2(180, 44), 20, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.z_index = 2
	reward.add_child(copy)
	var amount: Label = _label("DailyTaskClaimRewardAmount", "小鱼干 +%d" % reward_fish, Vector2(352, 466), Vector2(236, 44), 25, INK, HORIZONTAL_ALIGNMENT_CENTER)
	amount.z_index = 2
	reward.add_child(amount)
	var done_button: Button = _transparent_text_button("CloseDailyTaskClaimRewardButton", "收好奖励", Rect2(Vector2(522, 552), Vector2(486, 82)), 27)
	done_button.z_index = 3
	done_button.pressed.connect(func() -> void: reward.queue_free())
	_attach_button_feedback(done_button, burst)
	reward.add_child(done_button)
	var dismiss_button: Button = _hotspot_button("DismissDailyTaskClaimRewardButton", Vector2(1014, 82), Vector2(92, 92), "关闭")
	dismiss_button.z_index = 3
	dismiss_button.pressed.connect(func() -> void: reward.queue_free())
	reward.add_child(dismiss_button)
	_animate_overlay_entry(reward)
	_pulse_control(burst)


func _sync_claimed_daily_tasks_for_today() -> void:
	_claimed_daily_tasks.clear()
	var today_claims: Dictionary = _daily_task_claim_bucket(_today_key())
	for task: Dictionary in DAILY_TASKS:
		var task_id: String = str(task.get("id", ""))
		if not task_id.is_empty() and bool(today_claims.get(task_id, false)):
			_claimed_daily_tasks[task_id] = true


func _daily_task_claim_bucket(date_key: String) -> Dictionary:
	var raw_claims: Variant = _claimed_daily_tasks_by_date.get(date_key, {})
	return _normalized_daily_task_claims(raw_claims)


func _normalized_daily_task_claims(raw_claims: Variant) -> Dictionary:
	var normalized: Dictionary = {}
	if raw_claims is Dictionary:
		var claims: Dictionary = raw_claims as Dictionary
		for task: Dictionary in DAILY_TASKS:
			var task_id: String = str(task.get("id", ""))
			if not task_id.is_empty() and bool(claims.get(task_id, false)):
				normalized[task_id] = true
	return normalized


func _show_backpack_overlay(parent: Node) -> void:
	_sync_energy_for_today()
	var content: Control = _image_overlay(parent, "BackpackOverlay", "BackpackDesignBackground", BACKPACK_OVERLAY_DESIGN)
	content.add_child(_label("BackpackTitle", "背包", Vector2(462, 148), Vector2(356, 58), 39, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label("BackpackFishCounter", "%d" % _total_fish, Vector2(496, 31), Vector2(104, 42), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label("BackpackStarsCounter", "%d" % _best_stars, Vector2(735, 31), Vector2(104, 42), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label("BackpackEnergyCounter", _energy_text(), Vector2(910, 31), Vector2(92, 42), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))

	_backpack_item(
		content,
		parent,
		"BackpackFishItem",
		"小鱼干",
		"当前持有 %d" % _total_fish,
		Vector2(306, 424),
		Vector2(214, 156),
		RESULT_REWARD_FISH_CHIP,
		"关卡胜利、每日任务、成就和商店补给都会增加小鱼干。",
		"去商店",
		"shop"
	)
	_backpack_item(
		content,
		parent,
		"BackpackPawTokenItem",
		"猫爪徽章",
		"当前持有 %d" % _paw_tokens,
		Vector2(532, 424),
		Vector2(214, 156),
		SHOP_PAW_BUNDLE_ICON,
		"完成成就或购买徽章包可以获得猫爪徽章。",
		"看成就",
		"achievements"
	)
	_backpack_item(
		content,
		parent,
		"BackpackYarnTrapItem",
		"毛线陷阱",
		"当前持有 %d" % _yarn_traps,
		Vector2(762, 424),
		Vector2(214, 156),
		YARN_TRAP_ITEM_ICON,
		"战斗中使用毛线陷阱可以减速小鼠，适合守住弯道。",
		"去战斗",
		"levels"
	)

	var organize_text: String = "已整理" if _backpack_organized else "整理背包"
	var organize: Button = _transparent_text_button("OrganizeBackpackButton", organize_text, Rect2(Vector2(466, 574), Vector2(348, 76)), 27)
	organize.disabled = _backpack_organized
	var fish_counter: Label = content.find_child("BackpackFishCounter", true, false) as Label
	organize.pressed.connect(func() -> void:
		_claim_backpack_organize_reward(content, fish_counter, organize)
	)
	content.add_child(organize)
	var close_button: Button = _hotspot_button("CloseBackpackButton", Vector2(948, 130), Vector2(122, 114), "关闭")
	close_button.pressed.connect(func() -> void: content.get_parent().queue_free())
	content.add_child(close_button)
	_animate_overlay_entry(content)


func _show_achievements_overlay(parent: Node) -> void:
	var content: Control = _image_overlay(parent, "AchievementsOverlay", "AchievementsDesignBackground", ACHIEVEMENTS_OVERLAY_DESIGN)
	content.add_child(_label("AchievementsTitle", "成就", Vector2(438, 132), Vector2(404, 62), 39, INK, HORIZONTAL_ALIGNMENT_CENTER))
	for achievement: Dictionary in ACHIEVEMENTS:
		_achievement_row(content, achievement)
	var action: Button = _transparent_text_button("AchievementsActionButton", "继续挑战", Rect2(Vector2(468, 575), Vector2(344, 78)), 27)
	action.pressed.connect(_show_level_select)
	content.add_child(action)
	var close_button: Button = _hotspot_button("CloseAchievementsButton", Vector2(970, 122), Vector2(118, 112), "关闭")
	close_button.pressed.connect(func() -> void: content.get_parent().queue_free())
	content.add_child(close_button)
	_animate_overlay_entry(content)


func _show_shop_overlay(parent: Node) -> void:
	_sync_energy_for_today()
	var content: Control = _image_overlay(parent, "ShopOverlay", "ShopDesignBackground", SHOP_OVERLAY_DESIGN)
	content.add_child(_label("ShopTitle", "猫猫商店", Vector2(460, 128), Vector2(360, 62), 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var fish_counter: Label = _label("ShopFishCounter", "%d" % _total_fish, Vector2(584, 29), Vector2(92, 40), 24, INK, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(fish_counter)
	content.add_child(_label("ShopStarsCounter", "%d" % _best_stars, Vector2(804, 29), Vector2(92, 40), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var energy_counter: Label = _label("ShopEnergyCounter", _energy_text(), Vector2(966, 29), Vector2(92, 40), 24, INK, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(energy_counter)
	_add_shop_energy_refill(content, fish_counter, energy_counter)

	content.add_child(_label("ShopFishPackTitle", "小鱼干补给", Vector2(270, 294), Vector2(214, 36), 21, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var claim_status: Label = _label("ShopClaimStatus", "已领取" if _shop_starter_claimed else "免费领取", Vector2(324, 482), Vector2(136, 36), 20, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(claim_status)
	var claim_text: String = "已领取" if _shop_starter_claimed else "领取 +15"
	var claim_button: Button = _transparent_text_button("ClaimShopFishPackButton", claim_text, Rect2(Vector2(278, 548), Vector2(202, 62)), 22)
	claim_button.disabled = _shop_starter_claimed
	claim_button.pressed.connect(func() -> void:
		if _shop_starter_claimed:
			return
		_shop_starter_claimed = true
		_total_fish += 15
		_save_progress()
		fish_counter.text = "%d" % _total_fish
		claim_status.text = "已领取"
		claim_button.text = "已领取"
		claim_button.disabled = true
		_pulse_control(content)
		_show_shop_purchase_reward_overlay(content, "小鱼干补给", "小鱼干 +15")
	)
	content.add_child(claim_button)

	_shop_paw_bundle_product(content, fish_counter, Vector2(507, 294), Vector2(214, 316))
	_shop_yarn_trap_product(content, fish_counter, Vector2(744, 294), Vector2(214, 316))

	var close_button: Button = _hotspot_button("CloseShopButton", Vector2(960, 112), Vector2(128, 116), "关闭")
	close_button.pressed.connect(func() -> void: content.get_parent().queue_free())
	content.add_child(close_button)
	_animate_overlay_entry(content)


func _add_shop_energy_refill(parent: Control, fish_counter: Label, energy_counter: Label) -> void:
	var status: Label = _label("ShopEnergyRefillStatus", _energy_refill_status_text(), Vector2(900, 70), Vector2(210, 28), 16, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	parent.add_child(status)
	var buy_button: Button = _hotspot_button("BuyShopEnergyRefillButton", Vector2(1042, 20), Vector2(72, 62), "补充体力")
	buy_button.disabled = not _can_buy_energy_refill()
	buy_button.pressed.connect(func() -> void:
		if not _can_buy_energy_refill():
			return
		var restored_energy: int = min(ENERGY_REFILL_AMOUNT, _max_energy - _energy)
		_total_fish -= ENERGY_REFILL_COST
		_energy = min(_max_energy, _energy + ENERGY_REFILL_AMOUNT)
		_energy_refilled_on = _today_key()
		_save_progress()
		fish_counter.text = "%d" % _total_fish
		energy_counter.text = _energy_text()
		status.text = _energy_refill_status_text()
		buy_button.disabled = not _can_buy_energy_refill()
		_pulse_control(energy_counter)
		_show_shop_purchase_reward_overlay(parent, "体力补充", "体力 +%d" % restored_energy)
	)
	parent.add_child(buy_button)


func _can_buy_energy_refill() -> bool:
	_sync_energy_for_today()
	return _energy < _max_energy and _total_fish >= ENERGY_REFILL_COST


func _energy_refill_status_text() -> String:
	_sync_energy_for_today()
	if _energy >= _max_energy:
		return "体力已满 %s" % _energy_text()
	if _total_fish < ENERGY_REFILL_COST:
		return "体力%s  需%d鱼干" % [_energy_text(), ENERGY_REFILL_COST]
	return "体力%s  +%d/%d鱼干" % [_energy_text(), min(ENERGY_REFILL_AMOUNT, _max_energy - _energy), ENERGY_REFILL_COST]


func _album_entry_card(parent: Control, entry_name: String, texture: Texture2D, title: String, stat_one: String, stat_two: String, copy: String, position: Vector2, size: Vector2) -> void:
	var portrait: Control = Control.new()
	portrait.name = "%sPortrait" % entry_name
	portrait.position = position + Vector2(22, 18)
	portrait.size = Vector2(size.x - 44, 146)
	portrait.clip_contents = true
	parent.add_child(portrait)
	portrait.add_child(_sprite("%sSprite" % entry_name, texture, portrait.size * 0.5, Vector2(160, 136)))

	var frame: TextureRect = _ui_texture_rect("%sCardFrame" % entry_name, ALBUM_CARD_FRAME, position, size)
	parent.add_child(frame)

	parent.add_child(_label("%sTitle" % entry_name, title, position + Vector2(40, 172), Vector2(size.x - 80, 34), 19, INK, HORIZONTAL_ALIGNMENT_CENTER))
	parent.add_child(_label("%sStatOne" % entry_name, stat_one, position + Vector2(72, 222), Vector2(size.x - 98, 30), 17, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_LEFT))
	parent.add_child(_label("%sStatTwo" % entry_name, stat_two, position + Vector2(72, 263), Vector2(size.x - 98, 30), 17, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_LEFT))
	var body: Label = _label("%sCopy" % entry_name, copy, position + Vector2(30, 302), Vector2(size.x - 60, 50), 14, Color(0.38, 0.18, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(body)

	var inspect: Button = _hotspot_button("%sInspectButton" % entry_name, position, size, title)
	_attach_button_feedback(inspect, frame)
	inspect.pressed.connect(func() -> void:
		_show_album_entry_detail(parent, texture, title, stat_one, stat_two, copy)
	)
	parent.add_child(inspect)


func _show_album_entry_detail(parent: Control, texture: Texture2D, title: String, stat_one: String, stat_two: String, copy_text: String) -> void:
	_remove_named_child(parent, "AlbumEntryDetailOverlay")
	var detail: Control = Control.new()
	detail.name = "AlbumEntryDetailOverlay"
	detail.size = VIEW_SIZE
	detail.z_index = 10
	parent.add_child(detail)

	var design: TextureRect = _ui_texture_rect("AlbumEntryDetailDesignBackground", ALBUM_ENTRY_DETAIL_DESIGN, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	detail.add_child(design)
	detail.add_child(_label("AlbumEntryDetailTitle", title, Vector2(398, 126), Vector2(486, 62), 38, INK, HORIZONTAL_ALIGNMENT_CENTER))

	var portrait: Control = Control.new()
	portrait.name = "AlbumEntryDetailPortrait"
	portrait.position = Vector2(314, 258)
	portrait.size = Vector2(226, 226)
	portrait.clip_contents = true
	detail.add_child(portrait)
	portrait.add_child(_sprite("AlbumEntryDetailPortraitSprite", texture, portrait.size * 0.5, Vector2(214, 206)))

	detail.add_child(_label("AlbumEntryDetailStatOne", stat_one, Vector2(596, 268), Vector2(352, 44), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	detail.add_child(_label("AlbumEntryDetailRole", stat_two, Vector2(596, 350), Vector2(352, 44), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var copy: Label = _label("AlbumEntryDetailCopy", copy_text, Vector2(586, 446), Vector2(386, 88), 21, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(copy)

	var action: Button = _transparent_text_button("AlbumEntryDetailActionButton", "去关卡", Rect2(Vector2(464, 590), Vector2(352, 78)), 27)
	action.pressed.connect(_show_level_select)
	detail.add_child(action)
	var close_button: Button = _hotspot_button("CloseAlbumEntryDetailButton", Vector2(952, 132), Vector2(88, 88), "关闭")
	close_button.pressed.connect(func() -> void: detail.queue_free())
	detail.add_child(close_button)
	_animate_overlay_entry(detail)
	_pulse_control(portrait)


func _image_overlay(parent: Node, overlay_name: String, background_name: String, texture: Texture2D) -> Control:
	for existing_name: String in ["BackpackOverlay", "AchievementsOverlay", "ShopOverlay", "RewardOverlay", "DailyTaskOverlay", "AlbumOverlay", "SettingsOverlay", "EnergyEmptyOverlay"]:
		_remove_named_child(parent, existing_name)
	var overlay: Control = Control.new()
	overlay.name = overlay_name
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(overlay)

	var content: Control = Control.new()
	content.name = "%sContent" % overlay_name
	content.size = VIEW_SIZE
	overlay.add_child(content)

	var design: TextureRect = _ui_texture_rect(background_name, texture, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	content.add_child(design)
	return content


func _backpack_item(
	parent: Control,
	host: Node,
	node_prefix: String,
	title: String,
	detail: String,
	position: Vector2,
	size: Vector2,
	icon_texture: Texture2D,
	item_copy: String,
	action_text: String,
	action_name: String
) -> void:
	parent.add_child(_label("%sTitle" % node_prefix, title, position, Vector2(size.x, 34), 20, INK, HORIZONTAL_ALIGNMENT_CENTER))
	parent.add_child(_label("%sDetail" % node_prefix, detail, position + Vector2(62, 70), Vector2(size.x - 76, 34), 15, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER))
	var button: Button = _hotspot_button("%sButton" % node_prefix, position - Vector2(4, 128), Vector2(size.x + 8, 286), title)
	button.pressed.connect(func() -> void:
		_show_backpack_item_detail(parent, host, title, detail, icon_texture, item_copy, action_text, action_name)
	)
	parent.add_child(button)


func _show_backpack_item_detail(
	parent: Control,
	host: Node,
	title: String,
	count_text: String,
	icon_texture: Texture2D,
	item_copy: String,
	action_text: String,
	action_name: String
) -> void:
	_remove_named_child(parent, "BackpackItemDetailOverlay")
	var detail: Control = Control.new()
	detail.name = "BackpackItemDetailOverlay"
	detail.size = VIEW_SIZE
	detail.z_index = 10
	parent.add_child(detail)

	var design: TextureRect = _ui_texture_rect("BackpackItemDetailDesignBackground", BACKPACK_ITEM_DETAIL_DESIGN, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	detail.add_child(design)
	detail.add_child(_label("BackpackItemDetailTitle", title, Vector2(398, 122), Vector2(486, 62), 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var icon: TextureRect = _ui_texture_rect("BackpackItemDetailIcon", icon_texture, Vector2(322, 276), Vector2(204, 204))
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail.add_child(icon)
	detail.add_child(_label("BackpackItemDetailCount", count_text, Vector2(592, 286), Vector2(356, 44), 24, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var copy: Label = _label("BackpackItemDetailCopy", item_copy, Vector2(588, 368), Vector2(374, 92), 21, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(copy)

	var action_button: Button = _transparent_text_button("BackpackItemDetailActionButton", action_text, Rect2(Vector2(464, 544), Vector2(352, 82)), 27)
	action_button.pressed.connect(func() -> void:
		_run_backpack_item_action(parent, host, action_name)
	)
	detail.add_child(action_button)
	var close_button: Button = _hotspot_button("CloseBackpackItemDetailButton", Vector2(952, 132), Vector2(88, 88), "关闭")
	close_button.pressed.connect(func() -> void: detail.queue_free())
	detail.add_child(close_button)
	_animate_overlay_entry(detail)
	_pulse_control(icon)


func _run_backpack_item_action(backpack_content: Control, host: Node, action_name: String) -> void:
	var backpack_overlay: Node = backpack_content.get_parent()
	match action_name:
		"shop":
			if backpack_overlay != null:
				backpack_overlay.queue_free()
			_show_shop_overlay(host)
		"achievements":
			if backpack_overlay != null:
				backpack_overlay.queue_free()
			_show_achievements_overlay(host)
		"levels":
			_show_level_select()
		_:
			_remove_named_child(backpack_content, "BackpackItemDetailOverlay")


func _claim_backpack_organize_reward(parent: Control, fish_counter: Label, organize_button: Button) -> void:
	if _backpack_organized:
		return
	_backpack_organized = true
	_total_fish += 5
	_save_progress()
	if fish_counter != null:
		fish_counter.text = "%d" % _total_fish
	organize_button.text = "已整理"
	organize_button.disabled = true
	_show_backpack_organize_reward(parent)


func _show_backpack_organize_reward(parent: Control) -> void:
	_remove_named_child(parent, "BackpackOrganizeRewardOverlay")
	var reward: Control = Control.new()
	reward.name = "BackpackOrganizeRewardOverlay"
	reward.size = VIEW_SIZE
	reward.z_index = 10
	parent.add_child(reward)

	var design: TextureRect = _ui_texture_rect("BackpackOrganizeRewardDesignBackground", BACKPACK_ORGANIZE_REWARD_DESIGN, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	reward.add_child(design)
	reward.add_child(_label("BackpackOrganizeRewardTitle", "整理完成", Vector2(448, 132), Vector2(384, 58), 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var fish_icon: TextureRect = _ui_texture_rect("BackpackOrganizeRewardIcon", RESULT_REWARD_FISH_CHIP, Vector2(536, 258), Vector2(208, 172))
	fish_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reward.add_child(fish_icon)
	reward.add_child(_label("BackpackOrganizeRewardAmount", "小鱼干 +5", Vector2(484, 444), Vector2(312, 44), 25, INK, HORIZONTAL_ALIGNMENT_CENTER))
	reward.add_child(_label("BackpackOrganizeRewardCopy", "猫爪仓库变清爽了，顺手找到了小鱼干。", Vector2(426, 518), Vector2(428, 44), 19, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER))
	var done_button: Button = _transparent_text_button("CloseBackpackOrganizeRewardButton", "收好奖励", Rect2(Vector2(470, 594), Vector2(340, 78)), 26)
	done_button.pressed.connect(func() -> void: reward.queue_free())
	reward.add_child(done_button)
	var close_button: Button = _hotspot_button("DismissBackpackOrganizeRewardButton", Vector2(904, 132), Vector2(96, 96), "关闭")
	close_button.pressed.connect(func() -> void: reward.queue_free())
	reward.add_child(close_button)
	_animate_overlay_entry(reward)
	_pulse_control(fish_icon)


func _achievement_row(parent: Control, achievement: Dictionary) -> void:
	var achievement_id: String = str(achievement.get("id", ""))
	var row_name: String = str(achievement.get("node", "Achievement"))
	var title: String = str(achievement.get("title", "成就"))
	var detail: String = str(achievement.get("detail", "完成目标"))
	var target: int = max(1, int(achievement.get("target", 1)))
	var reward_fish: int = max(0, int(achievement.get("reward_fish", 0)))
	var reward_paws: int = max(0, int(achievement.get("reward_paws", 0)))
	var position: Vector2 = achievement.get("position", Vector2.ZERO) as Vector2
	var progress_value: int = min(target, _achievement_progress(achievement_id))
	var is_ready: bool = progress_value >= target
	var is_claimed: bool = _is_achievement_claimed(achievement_id)
	var claim_text: String = "已领取" if is_claimed else ("领取 +%d" % reward_fish if is_ready else "未完成")

	parent.add_child(_label("%sTitle" % row_name, title, position, Vector2(260, 34), 22, INK, HORIZONTAL_ALIGNMENT_LEFT))
	parent.add_child(_label("%sDetail" % row_name, detail, position + Vector2(0, 34), Vector2(300, 30), 17, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_LEFT))
	parent.add_child(_label("%sProgress" % row_name, "%d/%d" % [progress_value, target], position + Vector2(404, 20), Vector2(142, 36), 22, INK, HORIZONTAL_ALIGNMENT_CENTER))
	parent.add_child(_label("%sReward" % row_name, "奖励：鱼干%d  徽章%d" % [reward_fish, reward_paws], position + Vector2(0, 58), Vector2(330, 26), 14, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_LEFT))
	if is_claimed:
		_add_achievement_claimed_stamp(parent, row_name, position)
	var claim_label: Label = _label("%sClaimLabel" % row_name, claim_text, position + Vector2(494, 48), Vector2(122, 32), 18, INK, HORIZONTAL_ALIGNMENT_CENTER)
	claim_label.z_index = 3
	parent.add_child(claim_label)
	var claim_button: Button = _hotspot_button("%sClaimButton" % row_name, position + Vector2(466, 18), Vector2(174, 66), claim_text)
	claim_button.z_index = 4
	claim_button.disabled = not is_ready or is_claimed
	claim_button.pressed.connect(func() -> void:
		_claim_achievement(achievement, parent, claim_label, claim_button)
	)
	parent.add_child(claim_button)
	var row_button: Button = _hotspot_button("%sButton" % row_name, position - Vector2(118, 18), Vector2(562, 94), title)
	row_button.pressed.connect(func() -> void: _pulse_control(parent))
	parent.add_child(row_button)


func _achievement_progress(achievement_id: String) -> int:
	match achievement_id:
		"first_clear":
			return min(_completed_level_count(), 1)
		"star_collector":
			return min(_best_stars, 15)
		"campaign_clear":
			return min(_completed_level_count(), 5)
	return 0


func _is_achievement_claimed(achievement_id: String) -> bool:
	return bool(_claimed_achievements.get(achievement_id, false))


func _claim_achievement(achievement: Dictionary, parent: Control, claim_label: Label, claim_button: Button) -> void:
	var achievement_id: String = str(achievement.get("id", ""))
	if achievement_id.is_empty() or _is_achievement_claimed(achievement_id):
		return
	var target: int = max(1, int(achievement.get("target", 1)))
	if _achievement_progress(achievement_id) < target:
		return
	_claimed_achievements[achievement_id] = true
	_total_fish += max(0, int(achievement.get("reward_fish", 0)))
	_paw_tokens += max(0, int(achievement.get("reward_paws", 0)))
	_save_progress()
	claim_label.text = "已领取"
	claim_button.disabled = true
	_add_achievement_claimed_stamp(parent, str(achievement.get("node", "Achievement")), achievement.get("position", Vector2.ZERO) as Vector2)
	_pulse_control(parent)
	_show_achievement_claim_reward_overlay(parent, achievement)


func _show_achievement_claim_reward_overlay(parent: Control, achievement: Dictionary) -> void:
	_remove_named_child(parent, "AchievementClaimRewardOverlay")
	var reward: Control = Control.new()
	reward.name = "AchievementClaimRewardOverlay"
	reward.size = VIEW_SIZE
	reward.z_index = 18
	parent.add_child(reward)

	var design: TextureRect = _ui_texture_rect("AchievementClaimRewardDesignBackground", ACHIEVEMENT_CLAIM_REWARD_DESIGN, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	reward.add_child(design)

	var burst: TextureRect = _ui_texture_rect("AchievementClaimRewardBurst", ACHIEVEMENT_CLAIM_REWARD_BURST, Vector2(388, 412), Vector2(126, 126))
	burst.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	burst.modulate = Color(1.0, 1.0, 1.0, 0.95)
	burst.z_index = 1
	reward.add_child(burst)

	var title: String = str(achievement.get("title", "成就"))
	var reward_fish: int = max(0, int(achievement.get("reward_fish", 0)))
	var reward_paws: int = max(0, int(achievement.get("reward_paws", 0)))
	var title_label: Label = _label("AchievementClaimRewardTitle", "成就达成：%s" % title, Vector2(410, 302), Vector2(460, 52), 31, INK, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.z_index = 2
	reward.add_child(title_label)
	var copy: Label = _label("AchievementClaimRewardCopy", str(achievement.get("detail", "奖励已领取")), Vector2(420, 366), Vector2(440, 42), 21, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	copy.z_index = 2
	reward.add_child(copy)
	var amount: Label = _label("AchievementClaimRewardAmount", "小鱼干 +%d    徽章 +%d" % [reward_fish, reward_paws], Vector2(510, 450), Vector2(350, 42), 24, INK, HORIZONTAL_ALIGNMENT_CENTER)
	amount.z_index = 2
	reward.add_child(amount)
	var done_button: Button = _transparent_text_button("CloseAchievementClaimRewardButton", "收好奖励", Rect2(Vector2(470, 594), Vector2(340, 78)), 26)
	done_button.z_index = 3
	done_button.pressed.connect(func() -> void: reward.queue_free())
	_attach_button_feedback(done_button, burst)
	reward.add_child(done_button)
	var dismiss_button: Button = _hotspot_button("DismissAchievementClaimRewardButton", Vector2(888, 138), Vector2(96, 96), "关闭")
	dismiss_button.z_index = 3
	dismiss_button.pressed.connect(func() -> void: reward.queue_free())
	reward.add_child(dismiss_button)
	_animate_overlay_entry(reward)
	_pulse_control(burst)


func _add_achievement_claimed_stamp(parent: Control, row_name: String, position: Vector2) -> void:
	if parent.find_child("%sClaimedStamp" % row_name, true, false) != null:
		return
	var stamp: TextureRect = _ui_texture_rect("%sClaimedStamp" % row_name, ACHIEVEMENT_CLAIMED_STAMP, position + Vector2(486, 22), Vector2(136, 76))
	stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stamp.modulate = Color(1.0, 1.0, 1.0, 0.92)
	stamp.z_index = 2
	parent.add_child(stamp)
	stamp.pivot_offset = stamp.size * 0.5
	stamp.scale = Vector2(0.76, 0.76)
	var tween: Tween = create_tween()
	tween.tween_property(stamp, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _show_shop_purchase_reward_overlay(parent: Control, title: String, amount_text: String) -> void:
	_remove_named_child(parent, "ShopPurchaseRewardOverlay")
	var reward: Control = Control.new()
	reward.name = "ShopPurchaseRewardOverlay"
	reward.size = VIEW_SIZE
	reward.z_index = 18
	parent.add_child(reward)

	var design: TextureRect = _ui_texture_rect("ShopPurchaseRewardDesignBackground", SHOP_PURCHASE_FEEDBACK_DESIGN, Vector2.ZERO, VIEW_SIZE)
	design.stretch_mode = TextureRect.STRETCH_SCALE
	reward.add_child(design)

	var burst: TextureRect = _ui_texture_rect("ShopPurchaseRewardBurst", SHOP_PURCHASE_REWARD_BURST, Vector2(392, 410), Vector2(128, 128))
	burst.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	burst.modulate = Color(1.0, 1.0, 1.0, 0.95)
	burst.z_index = 1
	reward.add_child(burst)

	var title_label: Label = _label("ShopPurchaseRewardTitle", "购买成功：%s" % title, Vector2(410, 302), Vector2(460, 52), 31, INK, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.z_index = 2
	reward.add_child(title_label)
	var copy: Label = _label("ShopPurchaseRewardCopy", "已放入猫猫补给箱", Vector2(420, 366), Vector2(440, 42), 21, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	copy.z_index = 2
	reward.add_child(copy)
	var amount: Label = _label("ShopPurchaseRewardAmount", amount_text, Vector2(520, 450), Vector2(330, 42), 24, INK, HORIZONTAL_ALIGNMENT_CENTER)
	amount.z_index = 2
	reward.add_child(amount)
	var done_button: Button = _transparent_text_button("CloseShopPurchaseRewardButton", "收好补给", Rect2(Vector2(470, 594), Vector2(340, 78)), 26)
	done_button.z_index = 3
	done_button.pressed.connect(func() -> void: reward.queue_free())
	_attach_button_feedback(done_button, burst)
	reward.add_child(done_button)
	var dismiss_button: Button = _hotspot_button("DismissShopPurchaseRewardButton", Vector2(888, 138), Vector2(96, 96), "关闭")
	dismiss_button.z_index = 3
	dismiss_button.pressed.connect(func() -> void: reward.queue_free())
	reward.add_child(dismiss_button)
	_animate_overlay_entry(reward)
	_pulse_control(burst)


func _shop_locked_product(parent: Control, node_prefix: String, title: String, detail: String, position: Vector2, size: Vector2) -> void:
	parent.add_child(_label("%sTitle" % node_prefix, title, position, Vector2(size.x, 36), 20, INK, HORIZONTAL_ALIGNMENT_CENTER))
	parent.add_child(_label("%sDetail" % node_prefix, detail, position + Vector2(58, 188), Vector2(size.x - 70, 40), 15, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER))
	var button: Button = _transparent_text_button("%sButton" % node_prefix, "未开放", Rect2(position + Vector2(8, 254), Vector2(size.x - 16, 62)), 22)
	button.disabled = true
	parent.add_child(button)


func _shop_paw_bundle_product(parent: Control, fish_counter: Label, position: Vector2, size: Vector2) -> void:
	var price := 45
	var token_count := 2
	var icon: TextureRect = _ui_texture_rect("ShopPawBundleIcon", SHOP_PAW_BUNDLE_ICON, position + Vector2(145, 150), Vector2(46, 46))
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(icon)
	parent.add_child(_label("ShopPawBundleTitle", "猫爪徽章包", position, Vector2(size.x, 36), 20, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var status: Label = _label("ShopPawBundleStatus", "%d鱼干  持有%d" % [price, _paw_tokens], position + Vector2(58, 188), Vector2(size.x - 70, 40), 15, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	parent.add_child(status)
	var buy_text: String = "购买 %d" % price if _total_fish >= price else "鱼干不足"
	var buy_button: Button = _transparent_text_button("BuyShopPawBundleButton", buy_text, Rect2(position + Vector2(8, 254), Vector2(size.x - 16, 62)), 22)
	buy_button.disabled = _total_fish < price
	buy_button.pressed.connect(func() -> void:
		if _total_fish < price:
			return
		_total_fish -= price
		_paw_tokens += token_count
		_save_progress()
		fish_counter.text = "%d" % _total_fish
		status.text = "已购买  持有%d" % _paw_tokens
		buy_button.text = "再买 %d" % price if _total_fish >= price else "鱼干不足"
		buy_button.disabled = _total_fish < price
		_pulse_control(icon)
		_show_shop_purchase_reward_overlay(parent, "猫爪徽章包", "徽章 +%d" % token_count)
	)
	parent.add_child(buy_button)


func _shop_yarn_trap_product(parent: Control, fish_counter: Label, position: Vector2, size: Vector2) -> void:
	var price := 25
	var icon: TextureRect = _ui_texture_rect("ShopYarnTrapIcon", YARN_TRAP_ITEM_ICON, position + Vector2(146, 150), Vector2(44, 44))
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(icon)
	parent.add_child(_label("ShopYarnTrapKitTitle", "毛线陷阱包", position, Vector2(size.x, 36), 20, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var status_text: String = "25鱼干  持有%d" % _yarn_traps
	var status: Label = _label("ShopYarnTrapKitStatus", status_text, position + Vector2(62, 188), Vector2(size.x - 76, 40), 15, Color(0.42, 0.20, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	parent.add_child(status)
	var buy_text: String = "购买 25" if _total_fish >= price else "鱼干不足"
	var buy_button: Button = _transparent_text_button("BuyShopYarnTrapKitButton", buy_text, Rect2(position + Vector2(8, 254), Vector2(size.x - 16, 62)), 22)
	buy_button.disabled = _total_fish < price
	buy_button.pressed.connect(func() -> void:
		if _total_fish < price:
			return
		_total_fish -= price
		_yarn_traps += 1
		_save_progress()
		fish_counter.text = "%d" % _total_fish
		status.text = "已购买  持有%d" % _yarn_traps
		buy_button.text = "再买 25" if _total_fish >= price else "鱼干不足"
		buy_button.disabled = _total_fish < price
		_pulse_control(icon)
		_show_shop_purchase_reward_overlay(parent, "毛线陷阱", "毛线陷阱 +1")
	)
	parent.add_child(buy_button)


func _is_level_unlocked(level_id: int) -> bool:
	return level_id >= 1 and level_id <= max(1, min(LEVELS.size(), _unlocked_level))


func _add_level_lock_badge(parent: Control, level_id: int, rect: Rect2) -> void:
	var badge_size := Vector2(82, 82)
	var badge_position: Vector2 = rect.position + Vector2(rect.size.x - badge_size.x - 8, 10)
	var badge: TextureRect = _ui_texture_rect("Level%dLockedBadge" % level_id, LEVEL_LOCK_BADGE, badge_position, badge_size)
	parent.add_child(badge)
	badge.pivot_offset = badge.size * 0.5
	badge.scale = Vector2(0.86, 0.86)
	badge.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(badge, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(badge, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _save_progress() -> void:
	_sync_energy_for_today()
	_sync_claimed_daily_tasks_for_today()
	var data: Dictionary = {
		"best_stars_by_level": _best_stars_by_level,
		"total_fish": _total_fish,
		"unlocked_level": _unlocked_level,
		"energy": _energy,
		"max_energy": _max_energy,
		"energy_refilled_on": _energy_refilled_on,
		"daily_reward_claimed": _daily_reward_claimed,
		"daily_reward_claimed_on": _daily_reward_claimed_on,
		"daily_reward_streak": _daily_reward_streak,
		"shop_starter_claimed": _shop_starter_claimed,
		"paw_tokens": _paw_tokens,
		"claimed_achievements": _claimed_achievements,
		"claimed_daily_tasks": _claimed_daily_tasks,
		"claimed_daily_tasks_by_date": _claimed_daily_tasks_by_date,
		"yarn_traps": _yarn_traps,
		"backpack_organized": _backpack_organized,
		"music_enabled": _music_enabled,
		"effects_enabled": _effects_enabled,
		"volume": _volume
	}
	var file: FileAccess = FileAccess.open(_save_path, FileAccess.WRITE)
	if file == null:
		push_warning("Unable to write save file at %s" % _save_path)
		return
	file.store_string(JSON.stringify(data))


func _load_progress() -> void:
	if not FileAccess.file_exists(_save_path):
		return
	var file: FileAccess = FileAccess.open(_save_path, FileAccess.READ)
	if file == null:
		push_warning("Unable to read save file at %s" % _save_path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed as Dictionary
	_total_fish = max(0, int(data.get("total_fish", 0)))
	_unlocked_level = max(1, min(LEVELS.size(), int(data.get("unlocked_level", 1))))
	_max_energy = max(1, int(data.get("max_energy", DEFAULT_MAX_ENERGY)))
	_energy = max(0, min(_max_energy, int(data.get("energy", _max_energy))))
	_energy_refilled_on = str(data.get("energy_refilled_on", ""))
	_sync_energy_for_today()
	_daily_reward_claimed_on = str(data.get("daily_reward_claimed_on", ""))
	_daily_reward_streak = max(0, int(data.get("daily_reward_streak", 0)))
	if _daily_reward_claimed_on.is_empty() and bool(data.get("daily_reward_claimed", false)):
		_daily_reward_claimed_on = _today_key()
		_daily_reward_streak = max(1, _daily_reward_streak)
	_daily_reward_claimed = _is_daily_reward_claimed_today()
	_shop_starter_claimed = bool(data.get("shop_starter_claimed", false))
	_paw_tokens = max(0, int(data.get("paw_tokens", 0)))
	_yarn_traps = max(0, int(data.get("yarn_traps", 0)))
	_backpack_organized = bool(data.get("backpack_organized", false))
	_music_enabled = bool(data.get("music_enabled", _music_enabled))
	_effects_enabled = bool(data.get("effects_enabled", _effects_enabled))
	_volume = max(0.0, min(100.0, float(data.get("volume", _volume))))

	_best_stars_by_level.clear()
	var raw_stars: Variant = data.get("best_stars_by_level", {})
	if raw_stars is Dictionary:
		var stars_by_level: Dictionary = raw_stars as Dictionary
		for raw_level_id: Variant in stars_by_level.keys():
			var level_id: int = int(str(raw_level_id))
			if level_id >= 1 and level_id <= LEVELS.size():
				_best_stars_by_level[level_id] = max(0, min(3, int(stars_by_level[raw_level_id])))
				if _level_stars(level_id) > 0:
					_unlocked_level = max(_unlocked_level, min(LEVELS.size(), level_id + 1))
	_claimed_achievements.clear()
	var raw_claimed: Variant = data.get("claimed_achievements", {})
	if raw_claimed is Dictionary:
		var claimed: Dictionary = raw_claimed as Dictionary
		for achievement: Dictionary in ACHIEVEMENTS:
			var achievement_id: String = str(achievement.get("id", ""))
			if bool(claimed.get(achievement_id, false)):
				_claimed_achievements[achievement_id] = true
	_claimed_daily_tasks_by_date.clear()
	var loaded_daily_task_dates: bool = false
	var raw_daily_tasks_by_date: Variant = data.get("claimed_daily_tasks_by_date", {})
	if raw_daily_tasks_by_date is Dictionary:
		var daily_tasks_by_date: Dictionary = raw_daily_tasks_by_date as Dictionary
		for raw_date_key: Variant in daily_tasks_by_date.keys():
			var date_key: String = str(raw_date_key)
			if _date_key_to_day_index(date_key) < 0:
				continue
			var bucket: Dictionary = _normalized_daily_task_claims(daily_tasks_by_date[raw_date_key])
			if not bucket.is_empty():
				_claimed_daily_tasks_by_date[date_key] = bucket
				loaded_daily_task_dates = true
	if not loaded_daily_task_dates:
		var migrated_bucket: Dictionary = _normalized_daily_task_claims(data.get("claimed_daily_tasks", {}))
		if not migrated_bucket.is_empty():
			_claimed_daily_tasks_by_date[_today_key()] = migrated_bucket
	_sync_claimed_daily_tasks_for_today()
	_recalculate_best_stars()


func _recalculate_best_stars() -> void:
	var total: int = 0
	for raw_level_id: Variant in _best_stars_by_level.keys():
		total += max(0, min(3, int(_best_stars_by_level[raw_level_id])))
	_best_stars = total


func _completed_level_count() -> int:
	var count: int = 0
	for level_id: int in _best_stars_by_level.keys():
		if _level_stars(level_id) > 0:
			count += 1
	return count


func _level_card(level_info: Dictionary, position: Vector2) -> Panel:
	var level_id: int = int(level_info.get("id", 1))
	var card: Panel = _panel("LevelCard%d" % level_id, position, Vector2(326, 170), Color(1.0, 0.93, 0.67, 0.95), Color(0.50, 0.28, 0.10), 18)
	card.clip_contents = true
	var thumb_path: String = str(level_info.get("thumb", ""))
	var thumb_texture: Texture2D = load(thumb_path) if ResourceLoader.exists(thumb_path) else LEVEL_BACKGROUND
	card.add_child(_texture("Level%dThumb" % level_id, thumb_texture, Vector2(10, 10), Vector2(306, 92)))
	var shade: ColorRect = ColorRect.new()
	shade.name = "Level%dTextWash" % level_id
	shade.position = Vector2(10, 10)
	shade.size = Vector2(306, 92)
	shade.color = Color(1.0, 0.92, 0.60, 0.36)
	card.add_child(shade)
	card.add_child(_label("Level%dName" % level_id, "第 %d 关  %s" % [level_id, str(level_info.get("name", ""))], Vector2(18, 18), Vector2(290, 34), 22, INK, HORIZONTAL_ALIGNMENT_CENTER))
	card.add_child(_label("Level%dStars" % level_id, "评级：%s" % _star_text(_level_stars(level_id)), Vector2(54, 54), Vector2(218, 28), 18, Color(0.45, 0.23, 0.08), HORIZONTAL_ALIGNMENT_CENTER))
	var button: Button = _button("StartLevel%dButton" % level_id, "出发", Vector2(62, 112), Vector2(200, 44), ORANGE, 22)
	var copied_info: Dictionary = level_info.duplicate(true)
	button.pressed.connect(func() -> void: _start_level(copied_info))
	card.add_child(button)
	return card


func _level_preview_card(card_name: String, title: String, subtitle: String, position: Vector2, locked: bool) -> Panel:
	var card: Panel = _panel(card_name, position, Vector2(226, 246), Color(0.95, 0.89, 0.68, 0.86), Color(0.45, 0.29, 0.16), 18)
	card.add_child(_label("%sTitle" % card_name, title, Vector2(22, 30), Vector2(182, 38), 28, INK, HORIZONTAL_ALIGNMENT_CENTER))
	card.add_child(_label("%sSubtitle" % card_name, subtitle, Vector2(22, 76), Vector2(182, 34), 22, Color(0.39, 0.21, 0.10), HORIZONTAL_ALIGNMENT_CENTER))
	var status: String = "待开放" if locked else "可挑战"
	card.add_child(_label("%sStatus" % card_name, status, Vector2(38, 150), Vector2(150, 44), 24, Color(0.54, 0.26, 0.10), HORIZONTAL_ALIGNMENT_CENTER))
	return card


func _level_info_by_id(level_id: int) -> Dictionary:
	for level_info: Dictionary in LEVELS:
		if int(level_info.get("id", 0)) == level_id:
			return level_info
	return LEVELS[0]


func _level_stars(level_id: int) -> int:
	return int(_best_stars_by_level.get(level_id, 0))


func _add_resource_strip(parent: Control) -> void:
	var strip: Panel = _panel("ResourceStrip", Vector2(760, 20), Vector2(430, 58), Color(1.0, 0.95, 0.76, 0.92), Color(0.45, 0.25, 0.10), 16)
	parent.add_child(strip)
	strip.add_child(_label("FishCounter", "小鱼干 %d" % _total_fish, Vector2(22, 8), Vector2(158, 40), 22, INK, HORIZONTAL_ALIGNMENT_CENTER))
	strip.add_child(_label("BestStarsCounter", "最高 %s" % _star_text(_best_stars), Vector2(188, 8), Vector2(124, 40), 22, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var plus_button: Button = _button("ResourcePlusButton", "+", Vector2(342, 8), Vector2(56, 40), GREEN, 26)
	plus_button.pressed.connect(func() -> void: _show_reward_overlay(parent))
	strip.add_child(plus_button)


func _add_bottom_nav(parent: Control, active: String) -> void:
	var dock: Panel = _panel("BottomNav", Vector2(386, 624), Vector2(508, 66), Color(1.0, 0.94, 0.72, 0.94), Color(0.48, 0.27, 0.12), 18)
	parent.add_child(dock)
	var home: Button = _button("BottomHomeButton", "主页", Vector2(18, 10), Vector2(108, 46), HONEY if active == "主页" else BLUE, 19)
	home.pressed.connect(_show_main_menu)
	dock.add_child(home)
	var levels: Button = _button("BottomLevelsButton", "关卡", Vector2(140, 10), Vector2(108, 46), HONEY if active == "关卡" else BLUE, 19)
	levels.pressed.connect(_show_level_select)
	dock.add_child(levels)
	var album: Button = _button("BottomAlbumButton", "图鉴", Vector2(262, 10), Vector2(108, 46), HONEY if active == "图鉴" else BLUE, 19)
	album.pressed.connect(func() -> void: _show_album_overlay(parent))
	dock.add_child(album)
	var settings: Button = _button("BottomSettingsButton", "设置", Vector2(384, 10), Vector2(108, 46), HONEY if active == "设置" else BLUE, 19)
	settings.pressed.connect(func() -> void: _show_settings_overlay(parent))
	dock.add_child(settings)


func _menu_screen(screen_name: String) -> Control:
	var screen: Control = Control.new()
	screen.name = screen_name
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background: TextureRect = TextureRect.new()
	background.name = "MapBackground"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = LEVEL_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	screen.add_child(background)

	var wash: ColorRect = ColorRect.new()
	wash.name = "SunnyWash"
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.color = Color(1.0, 0.92, 0.58, 0.10)
	screen.add_child(wash)

	return screen


func _image_design_screen(screen_name: String, texture: Texture2D, background_name: String = "Image2DesignBackground") -> Control:
	var screen: Control = Control.new()
	screen.name = screen_name
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background: TextureRect = TextureRect.new()
	background.name = background_name
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	screen.add_child(background)
	return screen


func _ui_texture_rect(node_name: String, texture: Texture2D, position: Vector2, size: Vector2) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	rect.name = node_name
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.texture = texture
	rect.position = position
	rect.custom_minimum_size = size
	rect.size = size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func _hotspot_button(button_name: String, position: Vector2, size: Vector2, tooltip: String) -> Button:
	var button: Button = Button.new()
	button.name = button_name
	button.text = ""
	button.tooltip_text = tooltip
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _transparent_style())
	button.add_theme_stylebox_override("hover", _transparent_style())
	button.add_theme_stylebox_override("pressed", _transparent_style())
	button.add_theme_stylebox_override("disabled", _transparent_style())
	return button


func _invisible_toggle(toggle_name: String, rect: Rect2, enabled: bool) -> CheckButton:
	var toggle: CheckButton = CheckButton.new()
	toggle.name = toggle_name
	toggle.text = ""
	toggle.button_pressed = enabled
	toggle.position = rect.position
	toggle.size = rect.size
	toggle.focus_mode = Control.FOCUS_NONE
	toggle.modulate = Color(1.0, 1.0, 1.0, 0.0)
	return toggle


func _transparent_text_button(button_name: String, text: String, rect: Rect2, font_size: int) -> Button:
	var button: Button = _hotspot_button(button_name, rect.position, rect.size, text)
	button.text = text
	button.clip_text = true
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_disabled_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", Color(0.18, 0.08, 0.04))
	button.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.66, 0.88))
	button.add_theme_constant_override("outline_size", 3)
	return button


func _attach_button_feedback(button: Button, target: Control) -> void:
	target.pivot_offset = target.size * 0.5
	button.mouse_entered.connect(func() -> void: _scale_control(target, 1.04, 0.08))
	button.mouse_exited.connect(func() -> void: _scale_control(target, 1.0, 0.10))
	button.button_down.connect(func() -> void: _scale_control(target, 0.95, 0.05))
	button.button_up.connect(func() -> void: _scale_control(target, 1.0, 0.08))


func _pulse_control(target: Control) -> void:
	_scale_control(target, 1.06, 0.06)
	var tween: Tween = create_tween()
	tween.tween_property(target, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _animate_overlay_entry(target: Control) -> void:
	target.pivot_offset = VIEW_SIZE * 0.5
	target.scale = Vector2(0.94, 0.94)
	target.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _scale_control(target: Control, scale_value: float, duration: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	target.pivot_offset = target.size * 0.5
	var tween: Tween = create_tween()
	tween.tween_property(target, "scale", Vector2(scale_value, scale_value), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _position_settings_slider_knob(knob: TextureRect, slider: HSlider) -> void:
	var ratio: float = float(slider.value - slider.min_value) / max(1.0, float(slider.max_value - slider.min_value))
	var x: float = slider.position.x + ratio * slider.size.x - knob.size.x * 0.5
	var y: float = slider.position.y + (slider.size.y - knob.size.y) * 0.5
	knob.position = Vector2(x, y)


func _overlay(overlay_name: String) -> Control:
	var overlay: Control = Control.new()
	overlay.name = overlay_name
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim: ColorRect = ColorRect.new()
	dim.name = "OverlayDim"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.14, 0.08, 0.04, 0.42)
	overlay.add_child(dim)
	return overlay


func _panel(panel_name: String, position: Vector2, size: Vector2, fill: Color, border: Color, radius: int) -> Panel:
	var panel: Panel = Panel.new()
	panel.name = panel_name
	panel.position = position
	panel.size = size
	panel.add_theme_stylebox_override("panel", _style(fill, border, radius, 3))
	return panel


func _button(button_name: String, text: String, position: Vector2, size: Vector2, fill: Color, font_size: int) -> Button:
	var button: Button = Button.new()
	button.name = button_name
	button.text = text
	button.position = position
	button.size = size
	button.clip_text = true
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", Color(0.18, 0.08, 0.04))
	button.add_theme_stylebox_override("normal", _style(fill, fill.darkened(0.45), 18, 4))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.08), fill.darkened(0.45), 18, 4))
	button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.10), fill.darkened(0.55), 18, 4))
	button.add_theme_stylebox_override("disabled", _style(Color(0.70, 0.68, 0.58), Color(0.38, 0.32, 0.24), 18, 4))
	return button


func _toggle(toggle_name: String, text: String, position: Vector2, enabled: bool) -> CheckButton:
	var toggle: CheckButton = CheckButton.new()
	toggle.name = toggle_name
	toggle.text = text
	toggle.button_pressed = enabled
	toggle.position = position
	toggle.size = Vector2(420, 48)
	toggle.add_theme_font_size_override("font_size", 25)
	toggle.add_theme_color_override("font_color", INK)
	return toggle


func _label(label_name: String, text: String, position: Vector2, size: Vector2, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.name = label_name
	label.text = text
	label.position = position
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _texture(node_name: String, texture: Texture2D, position: Vector2, size: Vector2) -> Control:
	var frame: Control = Control.new()
	frame.name = node_name
	frame.position = position
	frame.size = size
	frame.clip_contents = true

	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "%sSprite" % node_name
	sprite.texture = texture
	sprite.centered = true
	sprite.position = size * 0.5
	var texture_size: Vector2 = texture.get_size()
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		var ratio: float = max(size.x / texture_size.x, size.y / texture_size.y)
		sprite.scale = Vector2(ratio, ratio)
	frame.add_child(sprite)
	return frame


func _sprite(node_name: String, texture: Texture2D, center: Vector2, max_size: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.centered = true
	sprite.position = center
	var texture_size: Vector2 = texture.get_size()
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		var ratio: float = min(max_size.x / texture_size.x, max_size.y / texture_size.y)
		sprite.scale = Vector2(ratio, ratio)
	return sprite


func _style(fill: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_top = 10
	style.content_margin_right = 16
	style.content_margin_bottom = 10
	style.shadow_color = Color(0.30, 0.14, 0.05, 0.22)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 4)
	return style


func _transparent_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.0)
	style.border_color = Color(1.0, 1.0, 1.0, 0.0)
	style.set_border_width_all(0)
	style.set_corner_radius_all(0)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


func _remove_named_child(parent: Node, node_name: String) -> void:
	var existing: Node = parent.find_child(node_name, true, false)
	if existing != null:
		existing.queue_free()


func _star_text(stars: int) -> String:
	if stars <= 0:
		return "未通关"
	if stars == 1:
		return "一星"
	if stars == 2:
		return "二星"
	return "三星"
