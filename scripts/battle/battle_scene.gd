extends Node2D
class_name CatDefenseBattleScene

signal battle_finished(won: bool, stars: int, fish_reward: int)
signal exit_to_levels_requested
signal yarn_traps_changed(count: int)

const LevelDataScript := preload("res://scripts/core/level_data.gd")
const TowerStatsScript := preload("res://scripts/core/tower_stats.gd")
const EnemyScript := preload("res://scripts/battle/enemy.gd")
const TowerScript := preload("res://scripts/battle/tower.gd")
const BuildSlotScript := preload("res://scripts/battle/build_slot.gd")
const BattleHudTopBarTexture := preload("res://assets/generated/ui/battle_hud_top_bar.png")
const BattleHudBottomDockTexture := preload("res://assets/generated/ui/battle_hud_bottom_dock.png")
const BattlePauseButtonTexture := preload("res://assets/generated/ui/battle_pause_button.png")
const BattleBuildSlotMarkerTexture := preload("res://assets/generated/ui/battle_build_slot_marker.png")
const BattleWavePreviewChipTexture := preload("res://assets/generated/ui/battle_wave_preview_chip.png")
const BattleSpeedButtonTexture := preload("res://assets/generated/ui/battle_speed_button.png")
const BattlePauseMenuPanelTexture := preload("res://assets/generated/ui/battle_pause_menu_panel.png")
const BattlePauseMenuGreenButtonTexture := preload("res://assets/generated/ui/battle_pause_button_green.png")
const BattlePauseMenuOrangeButtonTexture := preload("res://assets/generated/ui/battle_pause_button_orange.png")
const BattlePauseMenuBlueButtonTexture := preload("res://assets/generated/ui/battle_pause_button_blue.png")
const BattlePauseMenuRedButtonTexture := preload("res://assets/generated/ui/battle_pause_button_red.png")
const TowerActionPanelTexture := preload("res://assets/generated/ui/tower_action_panel.png")
const SettingsOverlayPanelTexture := preload("res://assets/generated/ui/settings_overlay_panel.png")
const SettingsToggleOnTexture := preload("res://assets/generated/ui/settings_toggle_on.png")
const SettingsToggleOffTexture := preload("res://assets/generated/ui/settings_toggle_off.png")
const SettingsSliderTrackTexture := preload("res://assets/generated/ui/settings_slider_track.png")
const SettingsSliderKnobTexture := preload("res://assets/generated/ui/settings_slider_knob.png")
const SettingsCloseButtonTexture := preload("res://assets/generated/ui/settings_close_button.png")
const YarnTrapItemIconTexture := preload("res://assets/generated/ui/yarn_trap_item_icon.png")
const YarnTrapFieldEffectTexture := preload("res://assets/generated/ui/yarn_trap_field_effect.png")

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
var _wave_preview_label: Label
var _tip_label: Label
var _speed_multiplier_label: Label
var _speed_control_frame: TextureRect
var _background_sprite: Sprite2D
var _pause_overlay: Control
var _base_node: Node2D
var _base_sprite: Sprite2D
var _base_hit_timer: float = 0.0
var _base_visual_time: float = 0.0
var _selected_tower_id: String = "orange_cat"
var _tower_by_slot: Dictionary = {}
var _pause_music_enabled: bool = true
var _pause_effects_enabled: bool = true
var _pause_volume: float = 82.0
var _battle_speed_multiplier: float = 1.0
var yarn_traps_available: int = 0
var _yarn_trap_count_label: Label
var _yarn_trap_hud_icon: TextureRect
var _yarn_trap_effect_index: int = 0


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
	_tower_by_slot.clear()
	_wave_states.clear()
	_selected_tower_id = level.allowed_towers[0] if not level.allowed_towers.is_empty() else "orange_cat"
	_battle_speed_multiplier = 1.0
	_yarn_trap_effect_index = 0

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
	simulate_step(delta * _battle_speed_multiplier)


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

	var top_frame: TextureRect = _hud_texture_rect("BattleHudTopFrame", BattleHudTopBarTexture, Vector2(12, 8), Vector2(920, 112))
	_hud.add_child(top_frame)

	_coins_label = _hud_label("小鱼干 0")
	_coins_label.name = "CoinsLabel"
	_coins_label.position = Vector2(150, 45)
	_coins_label.size = Vector2(180, 34)
	_hud.add_child(_coins_label)

	_base_label = _hud_label("猫粮罐 0")
	_base_label.name = "BaseLabel"
	_base_label.position = Vector2(456, 45)
	_base_label.size = Vector2(206, 34)
	_hud.add_child(_base_label)

	_wave_label = _hud_label("波次 0/0")
	_wave_label.name = "WaveLabel"
	_wave_label.position = Vector2(760, 45)
	_wave_label.size = Vector2(150, 34)
	_hud.add_child(_wave_label)

	var wave_preview_frame: TextureRect = _hud_texture_rect("WavePreviewFrame", BattleWavePreviewChipTexture, Vector2(310, 114), Vector2(582, 92))
	_hud.add_child(wave_preview_frame)

	_wave_preview_label = _hud_label("下一波")
	_wave_preview_label.name = "WavePreviewLabel"
	_wave_preview_label.position = Vector2(448, 140)
	_wave_preview_label.size = Vector2(350, 34)
	_wave_preview_label.add_theme_font_size_override("font_size", 20)
	_hud.add_child(_wave_preview_label)

	var bottom_frame: TextureRect = _hud_texture_rect("BattleHudBottomFrame", BattleHudBottomDockTexture, Vector2(14, 528), Vector2(920, 210))
	_hud.add_child(bottom_frame)

	_tip_label = Label.new()
	_tip_label.name = "BuildTipLabel"
	_tip_label.text = "点击地图上的 + 猫爪建造：橘猫鱼骨炮 60"
	_tip_label.position = Vector2(58, 610)
	_tip_label.size = Vector2(456, 58)
	_tip_label.add_theme_font_size_override("font_size", 22)
	_tip_label.add_theme_color_override("font_color", Color(0.30, 0.15, 0.07))
	_tip_label.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.66, 0.86))
	_tip_label.add_theme_constant_override("outline_size", 3)
	_tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hud.add_child(_tip_label)

	var tower_selector: HBoxContainer = HBoxContainer.new()
	tower_selector.name = "TowerSelector"
	tower_selector.position = Vector2(552, 572)
	tower_selector.size = Vector2(352, 128)
	tower_selector.add_theme_constant_override("separation", 18)
	_hud.add_child(tower_selector)
	for tower_id: String in level.allowed_towers:
		tower_selector.add_child(_tower_select_button(tower_id))

	var pause_frame: TextureRect = _hud_texture_rect("BattlePauseFrame", BattlePauseButtonTexture, Vector2(1150, 14), Vector2(104, 104))
	_hud.add_child(pause_frame)

	var pause_button: Button = Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = ""
	pause_button.position = pause_frame.position
	pause_button.size = pause_frame.size
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(_on_pause_pressed)
	_make_button_transparent(pause_button)
	_attach_press_feedback(pause_button, pause_frame)
	_hud.add_child(pause_button)

	_speed_control_frame = _hud_texture_rect("SpeedControlFrame", BattleSpeedButtonTexture, Vector2(1030, 20), Vector2(96, 96))
	_hud.add_child(_speed_control_frame)

	_speed_multiplier_label = _hud_label("1x")
	_speed_multiplier_label.name = "SpeedMultiplierLabel"
	_speed_multiplier_label.position = Vector2(1054, 51)
	_speed_multiplier_label.size = Vector2(48, 32)
	_speed_multiplier_label.add_theme_font_size_override("font_size", 23)
	_hud.add_child(_speed_multiplier_label)

	var speed_button: Button = Button.new()
	speed_button.name = "SpeedToggleButton"
	speed_button.text = ""
	speed_button.position = _speed_control_frame.position
	speed_button.size = _speed_control_frame.size
	speed_button.tooltip_text = "切换战斗速度"
	speed_button.process_mode = Node.PROCESS_MODE_ALWAYS
	speed_button.pressed.connect(_toggle_battle_speed)
	_make_button_transparent(speed_button)
	_attach_press_feedback(speed_button, _speed_control_frame)
	_hud.add_child(speed_button)
	_build_yarn_trap_hud()
	_build_slot_buttons()


func _hud_texture_rect(node_name: String, texture: Texture2D, position: Vector2, size: Vector2) -> TextureRect:
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


func _hud_label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.28, 0.14, 0.08))
	label.add_theme_color_override("font_outline_color", Color(1.0, 0.91, 0.62, 0.84))
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _make_button_transparent(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())


func _attach_press_feedback(button: Button, target: Control) -> void:
	target.pivot_offset = target.size * 0.5
	button.mouse_entered.connect(func() -> void: _animate_control_scale(target, 1.05, 0.08))
	button.mouse_exited.connect(func() -> void: _animate_control_scale(target, 1.0, 0.10))
	button.button_down.connect(func() -> void: _animate_control_scale(target, 0.94, 0.05))
	button.button_up.connect(func() -> void: _animate_control_scale(target, 1.0, 0.08))


func _animate_control_scale(target: Control, scale_value: float, duration: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	target.pivot_offset = target.size * 0.5
	var tween: Tween = create_tween()
	tween.tween_property(target, "scale", Vector2(scale_value, scale_value), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
	var wave_index: int = 1
	for wave: Dictionary in level.waves:
		_wave_states.append({
			"index": wave_index,
			"enemy": str(wave.get("enemy", "mouse_basic")),
			"remaining": int(wave.get("count", 1)),
			"total_count": int(wave.get("count", 1)),
			"interval": float(wave.get("interval", 1.0)),
			"start_time": float(wave.get("time", 0.0)),
			"next_time": float(wave.get("time", 0.0))
		})
		wave_index += 1


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
	if finished:
		return
	if slot.occupied:
		_show_tower_action_overlay(slot)
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
	_tower_by_slot[slot] = tower
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
		var visual: TextureRect = _hud_texture_rect("BuildSlot%dVisual" % index, BattleBuildSlotMarkerTexture, slot.position - Vector2(42, 42), Vector2(84, 84))
		_slot_buttons.add_child(visual)

		var button: Button = Button.new()
		button.name = "BuildSlot%dButton" % index
		button.text = ""
		button.position = visual.position
		button.size = visual.size
		button.tooltip_text = "建造猫塔"
		_make_button_transparent(button)
		_attach_press_feedback(button, visual)
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
			button.disabled = false
			button.tooltip_text = "管理猫塔"
			var visual: TextureRect = _slot_buttons.get_node_or_null(NodePath(button.name.replace("Button", "Visual"))) as TextureRect
			if visual != null:
				visual.modulate = Color(0.55, 0.47, 0.36, 0.55)
				visual.scale = Vector2(0.82, 0.82)
			return


func _mark_slot_button_empty(slot: Node2D) -> void:
	if _slot_buttons == null:
		return
	for child: Node in _slot_buttons.get_children():
		var button: Button = child as Button
		if button == null:
			continue
		var center: Vector2 = button.position + button.size * 0.5
		if center.distance_to(slot.position) <= 1.0:
			button.disabled = false
			button.tooltip_text = "建造猫塔"
			var visual: TextureRect = _slot_buttons.get_node_or_null(NodePath(button.name.replace("Button", "Visual"))) as TextureRect
			if visual != null:
				visual.modulate = Color.WHITE
				visual.scale = Vector2.ONE
			return


func _show_tower_action_overlay(slot: Node2D) -> void:
	if _hud == null:
		return
	var tower: Node2D = _tower_by_slot.get(slot, null) as Node2D
	if tower == null or not is_instance_valid(tower):
		return
	var existing: Node = _hud.get_node_or_null("TowerActionOverlay")
	if existing != null:
		existing.queue_free()

	var overlay: Control = Control.new()
	overlay.name = "TowerActionOverlay"
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_hud.add_child(overlay)

	var panel: TextureRect = _hud_texture_rect("TowerActionDesignPanel", TowerActionPanelTexture, Vector2(290, 168), Vector2(700, 360))
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(panel)

	var tower_name: String = str(tower.get("display_name"))
	var upgrade_cost: int = int(tower.get("upgrade_cost"))
	var sell_refund: int = _tower_sell_refund(tower)
	overlay.add_child(_pause_label("管理 %s" % tower_name, Vector2(398, 226), Vector2(484, 42), 27, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER))
	var stats_label: Label = _pause_label(_tower_action_stats_text(tower), Vector2(382, 330), Vector2(516, 36), 21, Color(0.38, 0.18, 0.08), HORIZONTAL_ALIGNMENT_CENTER)
	overlay.add_child(stats_label)
	overlay.add_child(_pause_label("升级消耗 %d" % upgrade_cost, Vector2(384, 456), Vector2(236, 58), 24, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER))
	var sell_label: Label = _pause_label("出售返还 %d" % sell_refund, Vector2(660, 456), Vector2(236, 58), 24, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER)
	overlay.add_child(sell_label)

	var upgrade_button: Button = _pause_transparent_text_button("UpgradeTowerButton", "", Rect2(Vector2(384, 442), Vector2(244, 82)), 24)
	_attach_press_feedback(upgrade_button, panel)
	upgrade_button.pressed.connect(func() -> void:
		var previous_level: int = int(tower.get("level"))
		_upgrade_tower_from_overlay(tower, panel)
		if tower != null and is_instance_valid(tower) and int(tower.get("level")) != previous_level:
			stats_label.text = _tower_action_stats_text(tower)
			sell_label.text = "出售返还 %d" % _tower_sell_refund(tower)
	)
	overlay.add_child(upgrade_button)

	var sell_button: Button = _pause_transparent_text_button("SellTowerButton", "", Rect2(Vector2(652, 442), Vector2(244, 82)), 24)
	_attach_press_feedback(sell_button, panel)
	sell_button.pressed.connect(func() -> void:
		_sell_tower_from_overlay(tower, slot, overlay)
	)
	overlay.add_child(sell_button)

	var close_button: Button = _pause_transparent_text_button("CloseTowerActionButton", "", Rect2(Vector2(842, 206), Vector2(106, 92)), 22)
	_attach_press_feedback(close_button, panel)
	close_button.pressed.connect(func() -> void: overlay.queue_free())
	overlay.add_child(close_button)
	_pop_in_control(panel)


func _upgrade_tower_from_overlay(tower: Node2D, feedback_target: Control) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	var upgrade_cost: int = int(tower.get("upgrade_cost"))
	if coins < upgrade_cost:
		_tip_label.text = "小鱼干不够，先守住下一波。"
		_animate_control_scale(feedback_target, 0.98, 0.06)
		return
	coins -= upgrade_cost
	tower.call("upgrade")
	_tip_label.text = "%s 升到 %d 级！" % [str(tower.get("display_name")), int(tower.get("level"))]
	_animate_control_scale(feedback_target, 1.05, 0.08)
	_update_hud()


func _sell_tower_from_overlay(tower: Node2D, slot: Node2D, overlay: Control) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	var refund: int = _tower_sell_refund(tower)
	coins += refund
	towers.erase(tower)
	_tower_by_slot.erase(slot)
	slot.set_occupied(false)
	_mark_slot_button_empty(slot)
	tower.queue_free()
	if overlay != null and is_instance_valid(overlay):
		overlay.queue_free()
	_tip_label.text = "已收回猫塔，返还小鱼干 %d。" % refund
	_update_hud()


func _tower_sell_refund(tower: Node2D) -> int:
	if tower == null:
		return 0
	var base_refund: int = int(round(float(tower.get("cost")) * 0.5))
	var upgrade_refund: int = int(round(float(max(0, int(tower.get("level")) - 1) * int(tower.get("upgrade_cost"))) * 0.35))
	return max(1, base_refund + upgrade_refund)


func _tower_action_stats_text(tower: Node2D) -> String:
	return "等级 %d    伤害 %.1f    范围 %d" % [int(tower.get("level")), float(tower.get("damage")), int(float(tower.get("attack_range")))]


func _pop_in_control(target: Control) -> void:
	if target == null or not is_instance_valid(target):
		return
	target.pivot_offset = target.size * 0.5
	target.scale = Vector2(0.92, 0.92)
	target.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


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
	button.text = "%s\n%d" % [str(stats.get("name", tower_id)), int(stats.get("cost", 0))]
	button.custom_minimum_size = Vector2(156, 122)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.28, 0.13, 0.06))
	button.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.66, 0.86))
	button.add_theme_constant_override("outline_size", 3)
	_make_button_transparent(button)
	_attach_press_feedback(button, button)
	button.pressed.connect(func() -> void: _select_tower(tower_id))
	return button


func _select_tower(tower_id: String) -> void:
	if not level.allowed_towers.has(tower_id):
		return
	_selected_tower_id = tower_id
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	_tip_label.text = "已选择：%s，点击猫爪位建造。" % str(stats.get("name", tower_id))


func _toggle_battle_speed() -> void:
	_battle_speed_multiplier = 2.0 if _battle_speed_multiplier < 2.0 else 1.0
	if _speed_multiplier_label != null:
		_speed_multiplier_label.text = "%dx" % int(_battle_speed_multiplier)
	if _speed_control_frame != null:
		_speed_control_frame.modulate = Color(1.0, 0.90, 0.66) if _battle_speed_multiplier > 1.0 else Color.WHITE
		_animate_control_scale(_speed_control_frame, 1.08, 0.08)
	if _tip_label != null:
		_tip_label.text = "战斗速度已切换为 %dx。" % int(_battle_speed_multiplier)


func _build_yarn_trap_hud() -> void:
	_yarn_trap_hud_icon = _hud_texture_rect("YarnTrapHudIcon", YarnTrapItemIconTexture, Vector2(936, 536), Vector2(96, 96))
	_yarn_trap_hud_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hud.add_child(_yarn_trap_hud_icon)

	_yarn_trap_count_label = _hud_label("x%d" % yarn_traps_available)
	_yarn_trap_count_label.name = "YarnTrapCountLabel"
	_yarn_trap_count_label.position = Vector2(980, 614)
	_yarn_trap_count_label.size = Vector2(72, 34)
	_yarn_trap_count_label.add_theme_font_size_override("font_size", 20)
	_hud.add_child(_yarn_trap_count_label)

	var trap_button: Button = Button.new()
	trap_button.name = "UseYarnTrapButton"
	trap_button.text = ""
	trap_button.position = _yarn_trap_hud_icon.position
	trap_button.size = Vector2(116, 116)
	trap_button.tooltip_text = "使用毛线陷阱"
	trap_button.process_mode = Node.PROCESS_MODE_ALWAYS
	_make_button_transparent(trap_button)
	_attach_press_feedback(trap_button, _yarn_trap_hud_icon)
	trap_button.pressed.connect(_use_yarn_trap)
	_hud.add_child(trap_button)
	_update_yarn_trap_hud()


func _use_yarn_trap() -> void:
	if yarn_traps_available <= 0:
		if _tip_label != null:
			_tip_label.text = "背包里没有毛线陷阱。"
		_update_yarn_trap_hud()
		return
	var target: Node2D = _first_active_enemy()
	if target == null:
		if _tip_label != null:
			_tip_label.text = "等小老鼠出现后再放毛线陷阱。"
		return
	yarn_traps_available = max(0, yarn_traps_available - 1)
	_apply_yarn_trap_at(target.global_position)
	_update_yarn_trap_hud()
	yarn_traps_changed.emit(yarn_traps_available)
	if _tip_label != null:
		_tip_label.text = "毛线陷阱缠住了小老鼠！"


func _first_active_enemy() -> Node2D:
	for enemy: Node2D in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if bool(enemy.get("reached_base")):
			continue
		if enemy.has_method("is_defeated") and bool(enemy.call("is_defeated")):
			continue
		return enemy
	return null


func _apply_yarn_trap_at(center: Vector2) -> void:
	for enemy: Node2D in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if bool(enemy.get("reached_base")):
			continue
		if enemy.has_method("is_defeated") and bool(enemy.call("is_defeated")):
			continue
		if enemy.global_position.distance_to(center) <= 190.0 and enemy.has_method("apply_slow"):
			enemy.call("apply_slow", 0.35, 4.0)

	_yarn_trap_effect_index += 1
	var effect: Sprite2D = Sprite2D.new()
	effect.name = "YarnTrapFieldEffect%d" % _yarn_trap_effect_index
	effect.texture = YarnTrapFieldEffectTexture
	effect.centered = true
	effect.position = center
	effect.scale = Vector2(0.13, 0.13)
	effect.z_index = 3
	_world.add_child(effect)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "scale", Vector2(0.16, 0.16), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.78, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _update_yarn_trap_hud() -> void:
	if _yarn_trap_count_label != null:
		_yarn_trap_count_label.text = "x%d" % yarn_traps_available
	if _yarn_trap_hud_icon != null:
		_yarn_trap_hud_icon.modulate = Color.WHITE if yarn_traps_available > 0 else Color(0.70, 0.70, 0.70, 0.62)
	var trap_button: Button = null
	if _hud != null:
		trap_button = _hud.find_child("UseYarnTrapButton", true, false) as Button
	if trap_button != null:
		trap_button.disabled = false


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

	var panel: TextureRect = _hud_texture_rect("PauseMenuDesignPanel", BattlePauseMenuPanelTexture, Vector2(346, 42), Vector2(588, 640))
	_pause_overlay.add_child(panel)

	var title: Label = _pause_label("暂停中", Vector2(426, 142), Vector2(428, 58), 42, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "PauseTitle"
	_pause_overlay.add_child(title)

	var status: Label = _pause_label("猫粮罐 %d/%d    小鱼干 %d" % [base_hp, int(level.base_hp), coins], Vector2(428, 260), Vector2(424, 38), 22, Color(0.40, 0.20, 0.09), HORIZONTAL_ALIGNMENT_CENTER)
	status.name = "PauseStatus"
	_pause_overlay.add_child(status)

	var resume: Button = _pause_menu_button("ResumeButton", "PauseResumeFrame", BattlePauseMenuGreenButtonTexture, "继续守卫", Vector2(438, 322), Vector2(404, 78))
	resume.pressed.connect(_resume_from_pause)

	var restart: Button = _pause_menu_button("RestartBattleButton", "PauseRestartFrame", BattlePauseMenuOrangeButtonTexture, "重新开始", Vector2(438, 406), Vector2(404, 78))
	restart.pressed.connect(_restart_from_pause)

	var settings: Button = _pause_menu_button("PauseSettingsButton", "PauseSettingsFrame", BattlePauseMenuBlueButtonTexture, "音量设置", Vector2(438, 490), Vector2(404, 78))
	settings.pressed.connect(_show_pause_settings)

	var quit: Button = _pause_menu_button("QuitToLevelsButton", "PauseQuitFrame", BattlePauseMenuRedButtonTexture, "退出关卡", Vector2(438, 574), Vector2(404, 78))
	quit.pressed.connect(_quit_to_levels_from_pause)


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


func _pause_menu_button(button_name: String, frame_name: String, texture: Texture2D, text: String, position: Vector2, size: Vector2) -> Button:
	var frame: TextureRect = _hud_texture_rect(frame_name, texture, position, size)
	frame.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_overlay.add_child(frame)

	var button: Button = Button.new()
	button.name = button_name
	button.text = text
	button.position = position
	button.size = size
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.add_theme_font_size_override("font_size", 25)
	button.add_theme_color_override("font_color", Color(0.27, 0.13, 0.07))
	button.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.66, 0.88))
	button.add_theme_constant_override("outline_size", 3)
	_make_button_transparent(button)
	_attach_press_feedback(button, frame)
	_pause_overlay.add_child(button)
	return button


func _show_pause_settings() -> void:
	if _pause_overlay == null or not is_instance_valid(_pause_overlay):
		return
	var existing: Node = _pause_overlay.find_child("PauseSettingsOverlay", true, false)
	if existing != null:
		existing.queue_free()
	_set_pause_menu_content_visible(false)

	var overlay: Control = Control.new()
	overlay.name = "PauseSettingsOverlay"
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 40
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.add_child(overlay)

	var panel: TextureRect = _hud_texture_rect("PauseSettingsDesignPanel", SettingsOverlayPanelTexture, Vector2(390, 76), Vector2(500, 570))
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(panel)
	overlay.add_child(_pause_label("音量设置", Vector2(456, 154), Vector2(368, 48), 35, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER))
	overlay.add_child(_pause_label("背景音乐", Vector2(486, 266), Vector2(132, 38), 23, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_LEFT))
	overlay.add_child(_pause_label("按钮音效", Vector2(486, 344), Vector2(132, 38), 23, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_LEFT))
	overlay.add_child(_pause_label("总音量", Vector2(486, 398), Vector2(112, 32), 20, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_LEFT))

	var music_frame: TextureRect = _hud_texture_rect("PauseSettingsMusicToggleFrame", SettingsToggleOnTexture if _pause_music_enabled else SettingsToggleOffTexture, Vector2(622, 256), Vector2(180, 62))
	music_frame.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(music_frame)
	var music: CheckButton = _pause_invisible_toggle("PauseMusicToggle", Rect2(music_frame.position, music_frame.size), _pause_music_enabled)
	music.toggled.connect(func(enabled: bool) -> void:
		_pause_music_enabled = enabled
		music_frame.texture = SettingsToggleOnTexture if enabled else SettingsToggleOffTexture
		_animate_control_scale(music_frame, 1.06, 0.06)
	)
	overlay.add_child(music)

	var effects_frame: TextureRect = _hud_texture_rect("PauseSettingsEffectsToggleFrame", SettingsToggleOnTexture if _pause_effects_enabled else SettingsToggleOffTexture, Vector2(622, 334), Vector2(180, 62))
	effects_frame.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(effects_frame)
	var effects: CheckButton = _pause_invisible_toggle("PauseEffectsToggle", Rect2(effects_frame.position, effects_frame.size), _pause_effects_enabled)
	effects.toggled.connect(func(enabled: bool) -> void:
		_pause_effects_enabled = enabled
		effects_frame.texture = SettingsToggleOnTexture if enabled else SettingsToggleOffTexture
		_animate_control_scale(effects_frame, 1.06, 0.06)
	)
	overlay.add_child(effects)

	var slider_frame: TextureRect = _hud_texture_rect("PauseSettingsVolumeSliderFrame", SettingsSliderTrackTexture, Vector2(514, 430), Vector2(256, 54))
	slider_frame.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(slider_frame)
	var slider_knob: TextureRect = _hud_texture_rect("PauseSettingsVolumeKnobFrame", SettingsSliderKnobTexture, Vector2.ZERO, Vector2(58, 44))
	slider_knob.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(slider_knob)
	var slider: HSlider = HSlider.new()
	slider.name = "PauseVolumeSlider"
	slider.process_mode = Node.PROCESS_MODE_ALWAYS
	slider.position = Vector2(532, 426)
	slider.size = Vector2(220, 62)
	slider.min_value = 0
	slider.max_value = 100
	slider.value = _pause_volume
	slider.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_position_pause_settings_knob(slider_knob, slider)
	slider.value_changed.connect(func(value: float) -> void:
		_pause_volume = value
		_position_pause_settings_knob(slider_knob, slider)
	)
	overlay.add_child(slider)

	var close_frame: TextureRect = _hud_texture_rect("PauseSettingsCloseFrame", SettingsCloseButtonTexture, Vector2(482, 498), Vector2(316, 80))
	close_frame.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.add_child(close_frame)
	var close: Button = _pause_transparent_text_button("ClosePauseSettingsButton", "完成", Rect2(close_frame.position, close_frame.size), 25)
	_attach_press_feedback(close, close_frame)
	close.pressed.connect(func() -> void:
		_set_pause_menu_content_visible(true)
		overlay.queue_free()
	)
	overlay.add_child(close)


func _set_pause_menu_content_visible(visible: bool) -> void:
	if _pause_overlay == null or not is_instance_valid(_pause_overlay):
		return
	for child: Node in _pause_overlay.get_children():
		if child.name == "PauseDim" or child.name == "PauseSettingsOverlay":
			continue
		if child is CanvasItem:
			(child as CanvasItem).visible = visible


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


func _pause_transparent_text_button(button_name: String, text: String, rect: Rect2, font_size: int) -> Button:
	var button: Button = Button.new()
	button.name = button_name
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.clip_text = true
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color(0.27, 0.13, 0.07))
	button.add_theme_color_override("font_hover_color", Color(0.27, 0.13, 0.07))
	button.add_theme_color_override("font_pressed_color", Color(0.18, 0.08, 0.04))
	button.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.66, 0.88))
	button.add_theme_constant_override("outline_size", 3)
	_make_button_transparent(button)
	return button


func _pause_invisible_toggle(toggle_name: String, rect: Rect2, enabled: bool) -> CheckButton:
	var toggle: CheckButton = CheckButton.new()
	toggle.name = toggle_name
	toggle.text = ""
	toggle.process_mode = Node.PROCESS_MODE_ALWAYS
	toggle.button_pressed = enabled
	toggle.position = rect.position
	toggle.size = rect.size
	toggle.focus_mode = Control.FOCUS_NONE
	toggle.modulate = Color(1.0, 1.0, 1.0, 0.0)
	return toggle


func _position_pause_settings_knob(knob: TextureRect, slider: HSlider) -> void:
	var ratio: float = float(slider.value - slider.min_value) / max(1.0, float(slider.max_value - slider.min_value))
	var x: float = slider.position.x + ratio * slider.size.x - knob.size.x * 0.5
	var y: float = slider.position.y + (slider.size.y - knob.size.y) * 0.5
	knob.position = Vector2(x, y)


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
	if _wave_preview_label != null:
		_wave_preview_label.text = _wave_preview_text()
	_update_yarn_trap_hud()


func _wave_preview_text() -> String:
	for state: Dictionary in _wave_states:
		var enemy_name: String = _enemy_display_name(str(state.get("enemy", "mouse_basic")))
		var wave_index: int = int(state.get("index", 1))
		var start_time: float = float(state.get("start_time", 0.0))
		var next_time: float = float(state.get("next_time", start_time))
		if int(state.get("remaining", 0)) > 0:
			if elapsed < start_time:
				return "下一波 %d/%d：%s %.1f秒" % [wave_index, _wave_states.size(), enemy_name, max(0.0, start_time - elapsed)]
			return "第 %d/%d 波：%s x%d  %.1f秒" % [wave_index, _wave_states.size(), enemy_name, int(state.get("remaining", 0)), max(0.0, next_time - elapsed)]
		if elapsed < float(state.get("start_time", 0.0)):
			return "下一波 %d/%d：%s %.1f秒" % [wave_index, _wave_states.size(), enemy_name, max(0.0, next_time - elapsed)]
	return "最后一波清场中"


func _enemy_display_name(enemy_id: String) -> String:
	var enemy_data: Dictionary = TowerStatsScript.get_enemy(enemy_id)
	return str(enemy_data.get("name", enemy_id))


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
