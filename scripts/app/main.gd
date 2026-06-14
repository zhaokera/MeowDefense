extends Control

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const LEVEL_BACKGROUND := preload("res://assets/generated/backgrounds/level_001_meadow.png")
const MAIN_MENU_DESIGN := preload("res://assets/generated/ui/main_menu_design_reference.png")
const LEVEL_SELECT_DESIGN := preload("res://assets/generated/ui/level_select_design_reference.png")
const SETTINGS_OVERLAY_PANEL := preload("res://assets/generated/ui/settings_overlay_panel.png")
const SETTINGS_TOGGLE_ON := preload("res://assets/generated/ui/settings_toggle_on.png")
const SETTINGS_TOGGLE_OFF := preload("res://assets/generated/ui/settings_toggle_off.png")
const SETTINGS_SLIDER_TRACK := preload("res://assets/generated/ui/settings_slider_track.png")
const SETTINGS_SLIDER_KNOB := preload("res://assets/generated/ui/settings_slider_knob.png")
const SETTINGS_CLOSE_BUTTON := preload("res://assets/generated/ui/settings_close_button.png")
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

const VIEW_SIZE := Vector2(1280, 720)
const INK := Color(0.27, 0.13, 0.07)
const CREAM := Color(1.0, 0.94, 0.72)
const HONEY := Color(1.0, 0.76, 0.25)
const ORANGE := Color(0.98, 0.48, 0.20)
const GREEN := Color(0.46, 0.76, 0.34)
const BLUE := Color(0.34, 0.67, 0.86)
const CORAL := Color(0.94, 0.30, 0.22)

var _current: Node
var _best_stars: int = 0
var _best_stars_by_level: Dictionary = {}
var _total_fish: int = 0
var _current_level_id: int = 1
var _current_level_path: String = "res://data/levels/level_001.json"
var _music_enabled: bool = true
var _effects_enabled: bool = true
var _volume: float = 82.0


func _ready() -> void:
	get_tree().paused = false
	_show_main_menu()


func _clear_current() -> void:
	get_tree().paused = false
	if _current != null:
		_current.queue_free()
		_current = null


func _show_main_menu() -> void:
	_clear_current()
	var screen: Control = _image_design_screen("MainMenuScreen", MAIN_MENU_DESIGN)
	_current = screen
	add_child(screen)

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
	daily_task_button.pressed.connect(_show_level_select)
	screen.add_child(daily_task_button)

	var bottom_home: Button = _hotspot_button("BottomHomeButton", Vector2(326, 633), Vector2(150, 82), "主城")
	bottom_home.pressed.connect(_show_main_menu)
	screen.add_child(bottom_home)
	var bottom_bag: Button = _hotspot_button("BottomBagButton", Vector2(508, 620), Vector2(140, 94), "背包")
	bottom_bag.pressed.connect(func() -> void: _show_reward_overlay(screen))
	screen.add_child(bottom_bag)
	var bottom_album: Button = _hotspot_button("BottomAlbumButton", Vector2(683, 620), Vector2(150, 94), "成就")
	bottom_album.pressed.connect(func() -> void: _show_album_overlay(screen))
	screen.add_child(bottom_album)
	var bottom_shop: Button = _hotspot_button("BottomShopButton", Vector2(870, 620), Vector2(150, 94), "商店")
	bottom_shop.pressed.connect(func() -> void: _show_reward_overlay(screen))
	screen.add_child(bottom_shop)
	var settings_gear: Button = _hotspot_button("SettingsGearButton", Vector2(1205, 12), Vector2(66, 66), "设置")
	settings_gear.pressed.connect(func() -> void: _show_settings_overlay(screen))
	screen.add_child(settings_gear)


func _show_level_select() -> void:
	_clear_current()
	var screen: Control = _image_design_screen("LevelSelectScreen", LEVEL_SELECT_DESIGN, "LevelSelectDesignBackground")
	_current = screen
	add_child(screen)

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
		var button: Button = _hotspot_button(str(hotspot["button"]), rect.position, rect.size, "出发")
		var copied_info: Dictionary = (hotspot["level"] as Dictionary).duplicate(true)
		button.pressed.connect(func() -> void: _start_level(copied_info))
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
	bottom_shop.pressed.connect(func() -> void: _show_reward_overlay(screen))
	screen.add_child(bottom_shop)


func _start_level_one() -> void:
	_start_level(LEVELS[0])


func _start_level(level_info: Dictionary) -> void:
	_clear_current()
	_current_level_id = int(level_info.get("id", 1))
	_current_level_path = str(level_info.get("path", "res://data/levels/level_001.json"))
	var battle: Node2D = BattleSceneScript.new()
	battle.name = "BattleScene"
	battle.battle_finished.connect(_show_result)
	if battle.has_signal("exit_to_levels_requested"):
		battle.exit_to_levels_requested.connect(_show_level_select)
	_current = battle
	add_child(battle)
	battle.start_level(_current_level_path)


func _show_result(won: bool, stars: int, fish_reward: int) -> void:
	get_tree().paused = false
	_best_stars_by_level[_current_level_id] = max(_level_stars(_current_level_id), stars)
	_best_stars = max(_best_stars, stars)
	_total_fish += fish_reward
	_clear_current()

	var screen: Control = _menu_screen("ResultScreen")
	_current = screen
	add_child(screen)
	_add_resource_strip(screen)

	var panel: Panel = _panel("ResultPanel", Vector2(312, 86), Vector2(656, 502), Color(1.0, 0.94, 0.72, 0.97), Color(0.52, 0.29, 0.12), 24)
	screen.add_child(panel)

	var title_text: String = "守住啦！" if won else "猫粮罐被偷空了"
	panel.add_child(_label("ResultTitle", title_text, Vector2(44, 34), Vector2(568, 76), 54, INK, HORIZONTAL_ALIGNMENT_CENTER))
	panel.add_child(_sprite("ResultCatTower", CAT_TOWER_TEXTURE, Vector2(163, 223), Vector2(210, 210)))

	var summary_text: String = "星级：%s\n获得小鱼干：%d\n最高记录：%s" % [_star_text(stars), fish_reward, _star_text(_best_stars)]
	var summary: Label = _label("ResultSummary", summary_text, Vector2(304, 142), Vector2(282, 138), 29, Color(0.38, 0.18, 0.08), HORIZONTAL_ALIGNMENT_LEFT)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(summary)

	var retry_button: Button = _button("RetryButton", "再来一次", Vector2(78, 378), Vector2(210, 64), ORANGE, 27)
	retry_button.pressed.connect(func() -> void: _start_level(_level_info_by_id(_current_level_id)))
	panel.add_child(retry_button)

	var levels_button: Button = _button("ResultLevelsButton", "关卡地图", Vector2(326, 378), Vector2(210, 64), BLUE, 27)
	levels_button.pressed.connect(_show_level_select)
	panel.add_child(levels_button)

	var next_button: Button = _button("NextLevelButton", "下一关", Vector2(450, 298), Vector2(140, 52), HONEY, 21)
	if _current_level_id >= LEVELS.size():
		next_button.disabled = true
		next_button.text = "已通关"
	else:
		next_button.pressed.connect(func() -> void: _start_level(_level_info_by_id(_current_level_id + 1)))
	panel.add_child(next_button)


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
	)
	overlay.add_child(music_toggle)

	var effects_frame: TextureRect = _ui_texture_rect("SettingsEffectsToggleFrame", SETTINGS_TOGGLE_ON if _effects_enabled else SETTINGS_TOGGLE_OFF, Vector2(680, 344), Vector2(216, 74))
	overlay.add_child(effects_frame)
	var effects_toggle: CheckButton = _invisible_toggle("EffectsToggle", Rect2(effects_frame.position, effects_frame.size), _effects_enabled)
	effects_toggle.toggled.connect(func(enabled: bool) -> void:
		_effects_enabled = enabled
		effects_frame.texture = SETTINGS_TOGGLE_ON if enabled else SETTINGS_TOGGLE_OFF
		_pulse_control(effects_frame)
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
	)
	overlay.add_child(slider)

	var close_frame: TextureRect = _ui_texture_rect("SettingsCloseFrame", SETTINGS_CLOSE_BUTTON, Vector2(474, 570), Vector2(332, 92))
	overlay.add_child(close_frame)
	var close_button: Button = _transparent_text_button("CloseSettingsButton", "完成", Rect2(close_frame.position, close_frame.size), 28)
	_attach_button_feedback(close_button, close_frame)
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	overlay.add_child(close_button)


func _show_album_overlay(parent: Node) -> void:
	_remove_named_child(parent, "AlbumOverlay")
	var overlay: Control = _overlay("AlbumOverlay")
	parent.add_child(overlay)

	var panel: Panel = _panel("AlbumPanel", Vector2(176, 82), Vector2(928, 552), Color(1.0, 0.95, 0.76, 0.98), Color(0.50, 0.28, 0.11), 22)
	overlay.add_child(panel)
	panel.add_child(_label("AlbumTitle", "守卫图鉴", Vector2(42, 28), Vector2(842, 54), 42, INK, HORIZONTAL_ALIGNMENT_CENTER))

	_add_album_card(panel, "AlbumTowerCard", CAT_TOWER_TEXTURE, "橘猫鱼骨炮", "花费 60 小鱼干\n擅长守住弯道")
	_add_album_card(panel, "AlbumMouseCard", MOUSE_TEXTURE, "偷鱼干小鼠", "速度普通\n击败奖励小鱼干")
	_add_album_card(panel, "AlbumBaseCard", FISH_BASE_TEXTURE, "猫粮罐", "守护目标\n剩余血量决定星级")

	var close_button: Button = _button("CloseAlbumButton", "收起图鉴", Vector2(360, 454), Vector2(208, 60), BLUE, 25)
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	panel.add_child(close_button)


func _show_reward_overlay(parent: Node) -> void:
	_remove_named_child(parent, "RewardOverlay")
	var overlay: Control = _overlay("RewardOverlay")
	parent.add_child(overlay)
	var panel: Panel = _panel("RewardPanel", Vector2(402, 170), Vector2(476, 332), Color(1.0, 0.94, 0.72, 0.98), Color(0.50, 0.28, 0.11), 20)
	overlay.add_child(panel)
	panel.add_child(_label("RewardTitle", "每日奖励", Vector2(36, 34), Vector2(404, 52), 38, INK, HORIZONTAL_ALIGNMENT_CENTER))
	panel.add_child(_label("RewardCopy", "今日登录奖励已放入背包：\n小鱼干 +20\n明天继续守卫还有加成。", Vector2(56, 110), Vector2(364, 108), 25, Color(0.37, 0.18, 0.08), HORIZONTAL_ALIGNMENT_CENTER))
	var claim: Button = _button("ClaimRewardButton", "知道了", Vector2(142, 240), Vector2(192, 58), ORANGE, 25)
	claim.pressed.connect(func() -> void: overlay.queue_free())
	panel.add_child(claim)


func _add_album_card(parent: Control, card_name: String, texture: Texture2D, title: String, copy: String) -> void:
	var index: int = parent.get_child_count()
	var card_x: float = 54.0 + float(index - 1) * 286.0
	var card: Panel = _panel(card_name, Vector2(card_x, 116), Vector2(248, 286), Color(1.0, 0.83, 0.45, 0.88), Color(0.52, 0.29, 0.12), 18)
	parent.add_child(card)
	card.add_child(_sprite("%sImage" % card_name, texture, Vector2(124, 84), Vector2(144, 144)))
	card.add_child(_label("%sTitle" % card_name, title, Vector2(18, 162), Vector2(212, 40), 25, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var body: Label = _label("%sCopy" % card_name, copy, Vector2(26, 210), Vector2(196, 54), 18, Color(0.37, 0.18, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(body)


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
