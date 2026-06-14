extends Control

const BattleSceneScript := preload("res://scripts/battle/battle_scene.gd")
const LEVEL_BACKGROUND := preload("res://assets/generated/backgrounds/level_001_meadow.png")
const MAIN_MENU_DESIGN := preload("res://assets/generated/ui/main_menu_design_reference.png")
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
	var screen: Control = _menu_screen("LevelSelectScreen")
	_current = screen
	add_child(screen)

	_add_resource_strip(screen)
	screen.add_child(_label("LevelTitle", "关卡地图", Vector2(78, 56), Vector2(420, 70), 50, INK, HORIZONTAL_ALIGNMENT_LEFT))
	screen.add_child(_label("LevelSubtitle", "选择路线，布置猫猫防线。", Vector2(82, 116), Vector2(520, 36), 24, Color(0.35, 0.18, 0.08), HORIZONTAL_ALIGNMENT_LEFT))

	var back_button: Button = _button("BackToMainButton", "返回主页", Vector2(78, 622), Vector2(176, 58), BLUE, 23)
	back_button.pressed.connect(_show_main_menu)
	screen.add_child(back_button)

	var settings_button: Button = _button("LevelSettingsButton", "设置", Vector2(1058, 622), Vector2(126, 58), BLUE, 23)
	settings_button.pressed.connect(func() -> void: _show_settings_overlay(screen))
	screen.add_child(settings_button)

	var card_positions: Array[Vector2] = [
		Vector2(78, 174),
		Vector2(448, 174),
		Vector2(818, 174),
		Vector2(262, 366),
		Vector2(632, 366)
	]
	for index: int in range(LEVELS.size()):
		var level_info: Dictionary = LEVELS[index]
		screen.add_child(_level_card(level_info, card_positions[index]))

	var mission_panel: Panel = _panel("LevelMissionPanel", Vector2(770, 88), Vector2(392, 74), Color(0.35, 0.70, 0.86, 0.92), Color(0.13, 0.34, 0.45), 16)
	screen.add_child(mission_panel)
	mission_panel.add_child(_label("LevelMissionCopy", "目标：猫粮罐血量越高，星级越高\n提示：优先守住拐弯处的猫爪位", Vector2(20, 8), Vector2(352, 56), 19, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT))

	_add_bottom_nav(screen, "关卡")


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

	var panel: Panel = _panel("SettingsPanel", Vector2(348, 108), Vector2(584, 492), Color(1.0, 0.94, 0.72, 0.98), Color(0.50, 0.28, 0.11), 22)
	overlay.add_child(panel)
	panel.add_child(_label("SettingsTitle", "设置", Vector2(42, 30), Vector2(500, 60), 44, INK, HORIZONTAL_ALIGNMENT_CENTER))

	var music_toggle: CheckButton = _toggle("MusicToggle", "背景音乐", Vector2(82, 124), _music_enabled)
	music_toggle.toggled.connect(func(enabled: bool) -> void: _music_enabled = enabled)
	panel.add_child(music_toggle)

	var effects_toggle: CheckButton = _toggle("EffectsToggle", "按钮音效", Vector2(82, 190), _effects_enabled)
	effects_toggle.toggled.connect(func(enabled: bool) -> void: _effects_enabled = enabled)
	panel.add_child(effects_toggle)

	panel.add_child(_label("VolumeLabel", "总音量", Vector2(88, 270), Vector2(132, 36), 24, INK, HORIZONTAL_ALIGNMENT_LEFT))
	var slider: HSlider = HSlider.new()
	slider.name = "VolumeSlider"
	slider.position = Vector2(218, 270)
	slider.size = Vector2(278, 36)
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.value = _volume
	slider.value_changed.connect(func(value: float) -> void: _volume = value)
	panel.add_child(slider)

	var close_button: Button = _button("CloseSettingsButton", "完成", Vector2(188, 382), Vector2(208, 64), GREEN, 27)
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	panel.add_child(close_button)


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


func _image_design_screen(screen_name: String, texture: Texture2D) -> Control:
	var screen: Control = Control.new()
	screen.name = screen_name
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background: TextureRect = TextureRect.new()
	background.name = "Image2DesignBackground"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	screen.add_child(background)
	return screen


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
