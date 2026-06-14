extends Node2D
class_name CatDefenseBattleScene

signal battle_finished(won: bool, stars: int, fish_reward: int)
signal exit_to_levels_requested

const LevelDataScript := preload("res://scripts/core/level_data.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerScript := preload("res://scripts/battle/tower.gd")
const BuildSlotScript := preload("res://scripts/battle/build_slot.gd")

@export var level_path: String = "res://data/levels/level_001.json"

var level: Resource
var coins: int = 0
var base_hp: int = 0
var elapsed: float = 0.0
var finished: bool = false

var enemies: Array[Node2D] = []
var towers: Array[Node2D] = []
var _wave_states: Array[Dictionary] = []

var _world: Node2D
var _slot_layer: Node2D
var _tower_layer: Node2D
var _enemy_layer: Node2D
var _hud: CanvasLayer
var _slot_buttons: Control
var _coins_label: Label
var _base_label: Label
var _wave_label: Label
var _tip_label: Label
var _background_sprite: Sprite2D
var _pause_overlay: Control
var _base_node: Node2D
var _base_sprite: Sprite2D
var _base_hit_timer: float = 0.0
var _base_visual_time: float = 0.0
var _selected_tower_id: String = "orange_cat"


func _ready() -> void:
	if level == null:
		start_level(level_path)


func start_level(path: String) -> void:
	_clear_runtime()
	level_path = path
	level = LevelDataScript.new()
	level.load_from_file(level_path)
	coins = int(level.start_coins)
	base_hp = int(level.base_hp)
	elapsed = 0.0
	finished = false
	enemies.clear()
	towers.clear()
	_wave_states.clear()
	_selected_tower_id = level.allowed_towers[0] if not level.allowed_towers.is_empty() else "orange_cat"

	_build_world_nodes()
	_build_level_visuals()
	_build_slots()
	_build_hud()
	_prepare_waves()
	_update_hud()
	queue_redraw()


func _process(delta: float) -> void:
	if finished or level == null:
		return
	simulate_step(delta)


func _unhandled_input(event: InputEvent) -> void:
	if finished or level == null or get_tree().paused:
		return
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			if _try_build_at_screen_position(mouse.position):
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			if _try_build_at_screen_position(touch.position):
				get_viewport().set_input_as_handled()


func simulate_step(delta: float) -> void:
	if finished or level == null:
		return
	elapsed += delta
	_spawn_due_enemies()
	for enemy: Node2D in enemies.duplicate():
		if enemy != null and is_instance_valid(enemy) and enemy.has_method("advance_along_path"):
			enemy.advance_along_path(delta)
	_tick_towers(delta)
	_update_base_animation(delta)
	_check_victory()
	_update_hud()


func _clear_runtime() -> void:
	get_tree().paused = false
	_pause_overlay = null
	_base_node = null
	_base_sprite = null
	_base_hit_timer = 0.0
	_base_visual_time = 0.0
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	enemies.clear()
	towers.clear()


func _build_world_nodes() -> void:
	_world = Node2D.new()
	_world.name = "World"
	add_child(_world)

	_slot_layer = Node2D.new()
	_slot_layer.name = "BuildSlots"
	_tower_layer = Node2D.new()
	_tower_layer.name = "Towers"
	_enemy_layer = Node2D.new()
	_enemy_layer.name = "Enemies"
	_world.add_child(_slot_layer)
	_world.add_child(_tower_layer)
	_world.add_child(_enemy_layer)


func _build_level_visuals() -> void:
	if not str(level.background).is_empty() and ResourceLoader.exists(str(level.background)):
		_background_sprite = Sprite2D.new()
		_background_sprite.texture = load(str(level.background))
		_background_sprite.centered = false
		_background_sprite.position = Vector2.ZERO
		var texture_size: Vector2 = _background_sprite.texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			_background_sprite.scale = Vector2(1280.0 / texture_size.x, 720.0 / texture_size.y)
		_background_sprite.z_index = -20
		_world.add_child(_background_sprite)

	_base_node = Node2D.new()
	_base_node.name = "FishBase"
	_base_node.position = level.path_points[level.path_points.size() - 1]
	_base_node.z_index = 5
	_world.add_child(_base_node)
	_base_sprite = Sprite2D.new()
	_base_sprite.name = "AnimatedBaseSprite"
	if not str(level.base_texture).is_empty() and ResourceLoader.exists(str(level.base_texture)):
		_base_sprite.texture = load(str(level.base_texture))
		_base_sprite.scale = Vector2(0.08, 0.08)
	_base_node.add_child(_base_sprite)


func _build_slots() -> void:
	for position: Vector2 in level.build_slots:
		var slot: Node2D = BuildSlotScript.new()
		slot.position = position
		slot.z_index = 4
		slot.clicked.connect(_on_slot_clicked)
		_slot_layer.add_child(slot)


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_hud.name = "HUD"
	_hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_hud)

	_slot_buttons = Control.new()
	_slot_buttons.name = "BuildSlotButtons"
	_slot_buttons.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_slot_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_slot_buttons)

	var top_bar: PanelContainer = PanelContainer.new()
	top_bar.name = "BattleTopBar"
	top_bar.position = Vector2(18, 16)
	top_bar.size = Vector2(800, 64)
	top_bar.add_theme_stylebox_override("panel", _panel_style(Color(1.0, 0.94, 0.70, 0.94), Color(0.50, 0.28, 0.10), 18, 3))
	_hud.add_child(top_bar)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	top_bar.add_child(row)

	_coins_label = _hud_label("小鱼干 0")
	_coins_label.name = "CoinsLabel"
	_base_label = _hud_label("猫粮罐 0")
	_base_label.name = "BaseLabel"
	_wave_label = _hud_label("波次 0/0")
	_wave_label.name = "WaveLabel"
	row.add_child(_coins_label)
	row.add_child(_base_label)
	row.add_child(_wave_label)

	var build_panel: PanelContainer = PanelContainer.new()
	build_panel.name = "BuildPanel"
	build_panel.position = Vector2(18, 612)
	build_panel.size = Vector2(540, 84)
	build_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.27, 0.18, 0.12, 0.88), Color(1.0, 0.78, 0.33), 18, 3))
	_hud.add_child(build_panel)

	_tip_label = Label.new()
	_tip_label.name = "BuildTipLabel"
	_tip_label.text = "点击地图上的 + 猫爪建造：橘猫鱼骨炮 60"
	_tip_label.add_theme_font_size_override("font_size", 23)
	_tip_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78))
	_tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	build_panel.add_child(_tip_label)

	var tower_selector: HBoxContainer = HBoxContainer.new()
	tower_selector.name = "TowerSelector"
	tower_selector.position = Vector2(578, 618)
	tower_selector.size = Vector2(430, 72)
	tower_selector.add_theme_constant_override("separation", 12)
	_hud.add_child(tower_selector)
	for tower_id: String in level.allowed_towers:
		tower_selector.add_child(_tower_select_button(tower_id))

	var pause_button: Button = Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = "暂停"
	pause_button.position = Vector2(1132, 18)
	pause_button.size = Vector2(120, 58)
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(_on_pause_pressed)
	pause_button.add_theme_stylebox_override("normal", _panel_style(Color(0.34, 0.67, 0.86, 0.96), Color(0.12, 0.34, 0.45), 18, 3))
	pause_button.add_theme_stylebox_override("hover", _panel_style(Color(0.44, 0.75, 0.92, 0.98), Color(0.12, 0.34, 0.45), 18, 3))
	pause_button.add_theme_stylebox_override("pressed", _panel_style(Color(0.24, 0.55, 0.74, 0.98), Color(0.10, 0.26, 0.36), 18, 3))
	pause_button.add_theme_font_size_override("font_size", 24)
	_hud.add_child(pause_button)
	_build_slot_buttons()


func _hud_label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_color", Color(0.28, 0.14, 0.08))
	label.custom_minimum_size = Vector2(230, 44)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _panel_style(fill: Color, border: Color, radius: int = 8, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18
	style.content_margin_top = 10
	style.content_margin_right = 18
	style.content_margin_bottom = 10
	style.shadow_color = Color(0.18, 0.10, 0.04, 0.22)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 3)
	return style


func _prepare_waves() -> void:
	for wave: Dictionary in level.waves:
		_wave_states.append({
			"enemy": str(wave.get("enemy", "mouse_basic")),
			"remaining": int(wave.get("count", 1)),
			"interval": float(wave.get("interval", 1.0)),
			"next_time": float(wave.get("time", 0.0))
		})


func _spawn_due_enemies() -> void:
	for state: Dictionary in _wave_states:
		if int(state["remaining"]) <= 0:
			continue
		if elapsed < float(state["next_time"]):
			continue
		_spawn_enemy(str(state["enemy"]))
		state["remaining"] = int(state["remaining"]) - 1
		state["next_time"] = float(state["next_time"]) + float(state["interval"])


func _spawn_enemy(enemy_id: String) -> void:
	var enemy_data: Dictionary = TowerStatsScript.get_enemy(enemy_id)
	var enemy: Node2D = EnemyScript.new()
	enemy.configure(enemy_data, level.path_points)
	enemy.defeated.connect(_on_enemy_defeated)
	enemy.reached_goal.connect(_on_enemy_reached_goal)
	enemies.append(enemy)
	_enemy_layer.add_child(enemy)


func _tick_towers(delta: float) -> void:
	for tower: Node2D in towers:
		tower.tick(delta, enemies)


func _on_slot_clicked(slot: Node2D) -> void:
	if finished or slot.occupied:
		return
	var tower_id: String = _selected_tower_id
	if not level.allowed_towers.has(tower_id):
		tower_id = level.allowed_towers[0] if not level.allowed_towers.is_empty() else "orange_cat"
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var cost: int = int(stats.get("cost", 60))
	if coins < cost:
		_tip_label.text = "小鱼干不够，先挡住下一波小老鼠。"
		return
	coins -= cost
	slot.set_occupied(true)
	_mark_slot_button_occupied(slot)
	var tower: Node2D = TowerScript.new()
	tower.configure(tower_id, stats)
	tower.position = slot.position
	towers.append(tower)
	_tower_layer.add_child(tower)
	_tip_label.text = "%s 上岗！继续点击空猫爪位补防。" % str(stats.get("name", "猫塔"))
	_update_hud()


func _build_slot_buttons() -> void:
	if _slot_buttons == null or _slot_layer == null:
		return
	for child: Node in _slot_buttons.get_children():
		child.queue_free()
	var index: int = 1
	for child: Node in _slot_layer.get_children():
		var slot: Node2D = child as Node2D
		if slot == null:
			continue
		var button: Button = Button.new()
		button.name = "BuildSlot%dButton" % index
		button.text = "+"
		button.position = slot.position - Vector2(32, 32)
		button.size = Vector2(64, 64)
		button.tooltip_text = "建造猫塔"
		button.add_theme_font_size_override("font_size", 30)
		button.add_theme_color_override("font_color", Color(0.27, 0.13, 0.07))
		button.add_theme_stylebox_override("normal", _panel_style(Color(1.0, 0.88, 0.42, 0.78), Color(0.55, 0.31, 0.12), 32, 3))
		button.add_theme_stylebox_override("hover", _panel_style(Color(1.0, 0.94, 0.60, 0.92), Color(0.55, 0.31, 0.12), 32, 3))
		button.add_theme_stylebox_override("pressed", _panel_style(Color(0.95, 0.68, 0.24, 0.96), Color(0.43, 0.22, 0.08), 32, 3))
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.52, 0.42, 0.32, 0.45), Color(0.34, 0.24, 0.18), 32, 3))
		button.pressed.connect(func() -> void: _on_slot_clicked(slot))
		_slot_buttons.add_child(button)
		index += 1


func _mark_slot_button_occupied(slot: Node2D) -> void:
	if _slot_buttons == null:
		return
	for child: Node in _slot_buttons.get_children():
		var button: Button = child as Button
		if button == null:
			continue
		var center: Vector2 = button.position + button.size * 0.5
		if center.distance_to(slot.position) <= 1.0:
			button.disabled = true
			button.text = "✓"
			return


func _try_build_at_screen_position(screen_position: Vector2) -> bool:
	if _slot_layer == null:
		return false
	var closest_slot: Node2D = null
	var closest_distance: float = INF
	for child: Node in _slot_layer.get_children():
		var slot: Node2D = child as Node2D
		if slot == null or bool(slot.get("occupied")):
			continue
		var radius: float = float(slot.get("slot_radius"))
		var distance: float = slot.global_position.distance_to(screen_position)
		if distance <= radius and distance < closest_distance:
			closest_slot = slot
			closest_distance = distance
	if closest_slot == null:
		return false
	_on_slot_clicked(closest_slot)
	return true


func _tower_select_button(tower_id: String) -> Button:
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var button: Button = Button.new()
	button.name = _tower_button_name(tower_id)
	button.text = "%s  %d" % [str(stats.get("name", tower_id)), int(stats.get("cost", 0))]
	button.custom_minimum_size = Vector2(190, 58)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", Color(0.27, 0.13, 0.07))
	var fill: Color = Color(1.0, 0.76, 0.25) if tower_id == _selected_tower_id else Color(0.34, 0.67, 0.86)
	button.add_theme_stylebox_override("normal", _panel_style(fill, fill.darkened(0.45), 16, 3))
	button.add_theme_stylebox_override("hover", _panel_style(fill.lightened(0.08), fill.darkened(0.45), 16, 3))
	button.add_theme_stylebox_override("pressed", _panel_style(fill.darkened(0.10), fill.darkened(0.55), 16, 3))
	button.pressed.connect(func() -> void: _select_tower(tower_id))
	return button


func _select_tower(tower_id: String) -> void:
	if not level.allowed_towers.has(tower_id):
		return
	_selected_tower_id = tower_id
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	_tip_label.text = "已选择：%s，点击猫爪位建造。" % str(stats.get("name", tower_id))


func _tower_button_name(tower_id: String) -> String:
	if tower_id == "orange_cat":
		return "SelectTowerOrangeCatButton"
	if tower_id == "tabby_slow_cat":
		return "SelectTowerTabbySlowCatButton"
	return "SelectTower%sButton" % tower_id.capitalize().replace("_", "")


func _on_enemy_defeated(enemy: Node2D) -> void:
	if enemies.has(enemy):
		enemies.erase(enemy)
	coins += int(enemy.reward)
	enemy.queue_free()


func _on_enemy_reached_goal(enemy: Node2D) -> void:
	if enemies.has(enemy):
		enemies.erase(enemy)
	base_hp = max(0, base_hp - int(enemy.base_damage))
	_base_hit_timer = 0.22
	enemy.queue_free()
	if base_hp <= 0:
		_finish(false)


func _check_victory() -> void:
	if finished:
		return
	for state: Dictionary in _wave_states:
		if int(state["remaining"]) > 0:
			return
	if not enemies.is_empty():
		return
	_finish(true)


func _finish(won: bool) -> void:
	finished = true
	var stars: int = _calculate_stars() if won else 0
	var fish_reward: int = int(level.reward_fish) * max(1, stars)
	battle_finished.emit(won, stars, fish_reward)


func _calculate_stars() -> int:
	var hp_ratio: float = float(base_hp) / max(1.0, float(level.base_hp))
	if hp_ratio >= 0.8:
		return 3
	if hp_ratio >= 0.45:
		return 2
	return 1


func _on_pause_pressed() -> void:
	if finished:
		return
	_show_pause_menu()


func _show_pause_menu() -> void:
	if _pause_overlay != null and is_instance_valid(_pause_overlay):
		return
	get_tree().paused = true
	_pause_overlay = Control.new()
	_pause_overlay.name = "PauseMenuOverlay"
	_pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud.add_child(_pause_overlay)

	var dim: ColorRect = ColorRect.new()
	dim.name = "PauseDim"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.12, 0.07, 0.04, 0.50)
	_pause_overlay.add_child(dim)

	var panel: Panel = Panel.new()
	panel.name = "PausePanel"
	panel.position = Vector2(406, 104)
	panel.size = Vector2(468, 500)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(1.0, 0.94, 0.72, 0.98), Color(0.50, 0.28, 0.11), 22, 3))
	_pause_overlay.add_child(panel)

	var title: Label = _pause_label("暂停中", Vector2(34, 30), Vector2(400, 56), 42, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "PauseTitle"
	panel.add_child(title)

	var status: Label = _pause_label("猫粮罐 %d/%d    小鱼干 %d" % [base_hp, int(level.base_hp), coins], Vector2(44, 96), Vector2(380, 38), 22, Color(0.40, 0.20, 0.09), HORIZONTAL_ALIGNMENT_CENTER)
	status.name = "PauseStatus"
	panel.add_child(status)

	var resume: Button = _pause_button("ResumeButton", "继续守卫", Vector2(108, 158), Color(0.46, 0.76, 0.34))
	resume.pressed.connect(_resume_from_pause)
	panel.add_child(resume)

	var restart: Button = _pause_button("RestartBattleButton", "重新开始", Vector2(108, 234), Color(0.98, 0.48, 0.20))
	restart.pressed.connect(_restart_from_pause)
	panel.add_child(restart)

	var settings: Button = _pause_button("PauseSettingsButton", "音量设置", Vector2(108, 310), Color(0.34, 0.67, 0.86))
	settings.pressed.connect(_show_pause_settings)
	panel.add_child(settings)

	var quit: Button = _pause_button("QuitToLevelsButton", "退出关卡", Vector2(108, 386), Color(0.94, 0.30, 0.22))
	quit.pressed.connect(_quit_to_levels_from_pause)
	panel.add_child(quit)


func _resume_from_pause() -> void:
	get_tree().paused = false
	if _pause_overlay != null and is_instance_valid(_pause_overlay):
		_pause_overlay.queue_free()
	_pause_overlay = null


func _restart_from_pause() -> void:
	get_tree().paused = false
	_pause_overlay = null
	start_level(level_path)


func _quit_to_levels_from_pause() -> void:
	get_tree().paused = false
	exit_to_levels_requested.emit()


func _show_pause_settings() -> void:
	if _pause_overlay == null or not is_instance_valid(_pause_overlay):
		return
	var existing: Node = _pause_overlay.find_child("PauseSettingsOverlay", true, false)
	if existing != null:
		existing.queue_free()

	var panel: Panel = Panel.new()
	panel.name = "PauseSettingsOverlay"
	panel.position = Vector2(360, 160)
	panel.size = Vector2(560, 360)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(1.0, 0.95, 0.76, 0.99), Color(0.50, 0.28, 0.11), 22, 3))
	_pause_overlay.add_child(panel)
	panel.add_child(_pause_label("音量设置", Vector2(42, 26), Vector2(476, 50), 36, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER))
	panel.add_child(_pause_label("背景音乐", Vector2(90, 108), Vector2(150, 38), 24, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_LEFT))
	panel.add_child(_pause_label("按钮音效", Vector2(90, 168), Vector2(150, 38), 24, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_LEFT))
	panel.add_child(_pause_label("总音量", Vector2(90, 228), Vector2(150, 38), 24, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_LEFT))

	var music: CheckButton = CheckButton.new()
	music.name = "PauseMusicToggle"
	music.position = Vector2(372, 104)
	music.size = Vector2(104, 42)
	music.button_pressed = true
	panel.add_child(music)

	var effects: CheckButton = CheckButton.new()
	effects.name = "PauseEffectsToggle"
	effects.position = Vector2(372, 164)
	effects.size = Vector2(104, 42)
	effects.button_pressed = true
	panel.add_child(effects)

	var slider: HSlider = HSlider.new()
	slider.name = "PauseVolumeSlider"
	slider.position = Vector2(244, 230)
	slider.size = Vector2(234, 36)
	slider.min_value = 0
	slider.max_value = 100
	slider.value = 82
	panel.add_child(slider)

	var close: Button = _pause_button("ClosePauseSettingsButton", "完成", Vector2(184, 288), Color(0.46, 0.76, 0.34))
	close.size = Vector2(192, 52)
	close.pressed.connect(func() -> void: panel.queue_free())
	panel.add_child(close)


func _pause_button(button_name: String, text: String, position: Vector2, color: Color) -> Button:
	var button: Button = Button.new()
	button.name = button_name
	button.text = text
	button.position = position
	button.size = Vector2(252, 58)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.add_theme_font_size_override("font_size", 25)
	button.add_theme_color_override("font_color", Color(0.27, 0.13, 0.07))
	button.add_theme_stylebox_override("normal", _panel_style(color, color.darkened(0.45), 18, 4))
	button.add_theme_stylebox_override("hover", _panel_style(color.lightened(0.08), color.darkened(0.45), 18, 4))
	button.add_theme_stylebox_override("pressed", _panel_style(color.darkened(0.10), color.darkened(0.55), 18, 4))
	return button


func _pause_label(label_text: String, position: Vector2, size: Vector2, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.text = label_text
	label.position = position
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _update_hud() -> void:
	if _coins_label == null:
		return
	var spawned_waves: int = 0
	for state: Dictionary in _wave_states:
		if elapsed >= float(state["next_time"]) or int(state["remaining"]) <= 0:
			spawned_waves += 1
	_coins_label.text = "小鱼干 %d" % coins
	_base_label.text = "猫粮罐 %d/%d" % [base_hp, int(level.base_hp)]
	_wave_label.text = "波次 %d/%d" % [min(spawned_waves, _wave_states.size()), _wave_states.size()]


func has_base_animation_support() -> bool:
	return _base_node != null and _base_sprite != null


func _update_base_animation(delta: float) -> void:
	if _base_node == null:
		return
	_base_visual_time += delta
	if _base_hit_timer > 0.0:
		_base_hit_timer = max(0.0, _base_hit_timer - delta)
	var low_hp: bool = base_hp > 0 and float(base_hp) / max(1.0, float(level.base_hp)) <= 0.35
	var pulse: float = 1.0 + (sin(_base_visual_time * 8.0) * 0.05 if low_hp else 0.0)
	var shake: float = sin(_base_visual_time * 48.0) * 5.0 * (_base_hit_timer / 0.22) if _base_hit_timer > 0.0 else 0.0
	_base_node.position = level.path_points[level.path_points.size() - 1] + Vector2(shake, 0)
	_base_node.scale = Vector2(pulse, pulse)
	if _base_sprite != null:
		_base_sprite.modulate = Color(1.0, 0.65, 0.60) if _base_hit_timer > 0.0 or low_hp else Color.WHITE


func _draw() -> void:
	if level == null:
		return
	if _background_sprite == null or _background_sprite.texture == null:
		draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.66, 0.86, 0.52))
	if level.path_points.size() >= 2:
		for i: int in range(level.path_points.size() - 1):
			var a: Vector2 = level.path_points[i]
			var b: Vector2 = level.path_points[i + 1]
			draw_line(a, b, Color(0.44, 0.25, 0.10, 0.20), 42.0, true)
			draw_line(a, b, Color(1.0, 0.86, 0.52, 0.20), 26.0, true)
		var goal: Vector2 = level.path_points[level.path_points.size() - 1]
		draw_circle(goal, 42.0, Color(0.96, 0.62, 0.34))
		draw_circle(goal, 28.0, Color(1.0, 0.86, 0.48))
