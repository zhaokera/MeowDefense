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
const ProjectileScript := preload("res://scripts/battle/projectile.gd")
const BattleHudTopBarTexture := preload("res://assets/generated/ui/battle_hud_top_bar.png")
const BattleHudBottomDockTexture := preload("res://assets/generated/ui/battle_hud_bottom_dock.png")
const BattlePauseButtonTexture := preload("res://assets/generated/ui/battle_pause_button.png")
const BattleBuildSlotMarkerTexture := preload("res://assets/generated/ui/battle_build_slot_marker.png")
const BattleWavePreviewChipTexture := preload("res://assets/generated/ui/battle_wave_preview_chip.png")
const BattleWaveRushBurstTexture := preload("res://assets/generated/ui/battle_wave_rush_burst.png")
const BattleWaveClearBurstTexture := preload("res://assets/generated/ui/battle_wave_clear_burst.png")
const BattleSpeedButtonTexture := preload("res://assets/generated/ui/battle_speed_button.png")
const BattleSpeedFeedbackBurstTexture := preload("res://assets/generated/ui/battle_speed_feedback_burst.png")
const BattlePauseMenuPanelTexture := preload("res://assets/generated/ui/battle_pause_menu_panel.png")
const BattlePauseMenuGreenButtonTexture := preload("res://assets/generated/ui/battle_pause_button_green.png")
const BattlePauseMenuOrangeButtonTexture := preload("res://assets/generated/ui/battle_pause_button_orange.png")
const BattlePauseMenuBlueButtonTexture := preload("res://assets/generated/ui/battle_pause_button_blue.png")
const BattlePauseMenuRedButtonTexture := preload("res://assets/generated/ui/battle_pause_button_red.png")
const CommonOverlayDimTexture := preload("res://assets/generated/ui/common_overlay_dim_vignette.png")
const BattleTapFeedbackTexture := preload("res://assets/generated/ui/battle_tap_feedback_starburst.png")
const TowerActionPanelTexture := preload("res://assets/generated/ui/tower_action_panel.png")
const SettingsOverlayPanelTexture := preload("res://assets/generated/ui/settings_overlay_panel.png")
const SettingsToggleOnTexture := preload("res://assets/generated/ui/settings_toggle_on.png")
const SettingsToggleOffTexture := preload("res://assets/generated/ui/settings_toggle_off.png")
const SettingsSliderTrackTexture := preload("res://assets/generated/ui/settings_slider_track.png")
const SettingsSliderKnobTexture := preload("res://assets/generated/ui/settings_slider_knob.png")
const SettingsCloseButtonTexture := preload("res://assets/generated/ui/settings_close_button.png")
const YarnTrapItemIconTexture := preload("res://assets/generated/ui/yarn_trap_item_icon.png")
const YarnTrapFieldEffectTexture := preload("res://assets/generated/ui/yarn_trap_field_effect.png")
const BattleYarnTrapEmptyBurstTexture := preload("res://assets/generated/ui/battle_yarn_trap_empty_burst.png")
const BattleYarnTrapReadyBurstTexture := preload("res://assets/generated/ui/battle_yarn_trap_ready_burst.png")
const BattleTowerCardOrangeTexture := preload("res://assets/generated/ui/battle_tower_card_orange_cat.png")
const BattleTowerCardTabbyTexture := preload("res://assets/generated/ui/battle_tower_card_tabby_slow_cat.png")
const BattleTowerCardSelectedBadgeTexture := preload("res://assets/generated/ui/battle_tower_card_selected_badge.png")
const BattleTowerCardInsufficientFishStampTexture := preload("res://assets/generated/ui/battle_tower_card_insufficient_fish_stamp.png")
const BuildSlotManageBadgeTexture := preload("res://assets/generated/ui/album_paw_badge.png")
const TowerMaxLevelStampTexture := preload("res://assets/generated/ui/tower_max_level_stamp.png")
const TowerMaxLevelBurstTexture := preload("res://assets/generated/ui/tower_max_level_burst.png")
const TowerRangeAuraTexture := preload("res://assets/generated/effects/tower_range_aura.png")
const BattleResourceShortageBurstTexture := preload("res://assets/generated/ui/battle_resource_shortage_burst.png")
const BaseDamageWarningBurstTexture := preload("res://assets/generated/ui/base_damage_warning_burst.png")
const EnemyRewardFishBurstTexture := preload("res://assets/generated/ui/enemy_reward_fish_burst.png")
const EnemyHitFishSparkTexture := preload("res://assets/generated/effects/enemy_hit_fish_spark.png")
const EnemyDefeatMousePuffTexture := preload("res://assets/generated/effects/enemy_defeat_mouse_puff.png")
const EnemySpawnMouseDustTexture := preload("res://assets/generated/effects/enemy_spawn_mouse_dust.png")
const BuildSuccessCatPawPuffTexture := preload("res://assets/generated/effects/build_success_cat_paw_puff.png")
const TowerUpgradeCatStarburstTexture := preload("res://assets/generated/effects/tower_upgrade_cat_starburst.png")
const TowerSellFishRefundBurstTexture := preload("res://assets/generated/effects/tower_sell_fish_refund_burst.png")
const TowerFireFishboneMuzzleFlashTexture := preload("res://assets/generated/effects/tower_fire_fishbone_muzzle_flash.png")
const FallbackBattleBackgroundTexture := preload("res://assets/generated/backgrounds/level_001_meadow.png")

@export var level_path: String = "res://data/levels/level_001.json"

var level: Resource
var coins: int = 0
var base_hp: int = 0
var elapsed: float = 0.0
var finished: bool = false

var enemies: Array[Node2D] = []
var towers: Array[Node2D] = []
var _wave_states: Array[Dictionary] = []
var _cleared_wave_indices: Dictionary = {}

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
var _yarn_trap_armed: bool = false
var _enemy_reward_feedback_index: int = 0
var _enemy_hit_feedback_index: int = 0
var _enemy_defeat_feedback_index: int = 0
var _enemy_spawn_feedback_index: int = 0
var _build_success_feedback_index: int = 0
var _tower_upgrade_feedback_index: int = 0
var _tower_sell_feedback_index: int = 0
var _tower_max_level_feedback_index: int = 0
var _tower_fire_feedback_index: int = 0
var _projectile_index: int = 0
var _battle_tap_feedback_index: int = 0
var _wave_rush_feedback_index: int = 0
var _wave_clear_feedback_index: int = 0
var _battle_speed_feedback_index: int = 0


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
	_cleared_wave_indices.clear()
	_selected_tower_id = level.allowed_towers[0] if not level.allowed_towers.is_empty() else "orange_cat"
	_battle_speed_multiplier = 1.0
	_yarn_trap_effect_index = 0
	_yarn_trap_armed = false
	_enemy_reward_feedback_index = 0
	_enemy_hit_feedback_index = 0
	_enemy_defeat_feedback_index = 0
	_enemy_spawn_feedback_index = 0
	_build_success_feedback_index = 0
	_tower_upgrade_feedback_index = 0
	_tower_sell_feedback_index = 0
	_tower_max_level_feedback_index = 0
	_tower_fire_feedback_index = 0
	_projectile_index = 0
	_wave_rush_feedback_index = 0
	_wave_clear_feedback_index = 0
	_battle_speed_feedback_index = 0

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
	_try_fire_armed_yarn_trap()
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
	var background_texture: Texture2D = FallbackBattleBackgroundTexture
	if not str(level.background).is_empty() and ResourceLoader.exists(str(level.background)):
		background_texture = load(str(level.background))
	_add_battle_background(background_texture)

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


func _add_battle_background(texture: Texture2D) -> void:
	_background_sprite = Sprite2D.new()
	_background_sprite.name = "BattleBackground"
	_background_sprite.texture = texture
	_background_sprite.centered = false
	_background_sprite.position = Vector2.ZERO
	if texture != null:
		var texture_size: Vector2 = texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			_background_sprite.scale = Vector2(1280.0 / texture_size.x, 720.0 / texture_size.y)
	_background_sprite.z_index = -20
	_world.add_child(_background_sprite)


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

	var rush_wave_button: Button = Button.new()
	rush_wave_button.name = "RushNextWaveButton"
	rush_wave_button.text = ""
	rush_wave_button.position = wave_preview_frame.position
	rush_wave_button.size = wave_preview_frame.size
	rush_wave_button.tooltip_text = "提前开波"
	rush_wave_button.process_mode = Node.PROCESS_MODE_ALWAYS
	_make_button_transparent(rush_wave_button)
	_attach_press_feedback(rush_wave_button, wave_preview_frame)
	rush_wave_button.pressed.connect(_rush_next_wave)
	_hud.add_child(rush_wave_button)

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
	tower_selector.position = Vector2(538, 532)
	tower_selector.size = Vector2(384, 176)
	tower_selector.add_theme_constant_override("separation", 12)
	_hud.add_child(tower_selector)
	for tower_id: String in level.allowed_towers:
		tower_selector.add_child(_tower_select_card(tower_id))
	_update_tower_selector_state()

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
	button.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mouse: InputEventMouseButton = event as InputEventMouseButton
			if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
				_show_battle_tap_feedback(button, mouse.position)
				button.set_meta("battle_pointer_feedback_msec", Time.get_ticks_msec())
		elif event is InputEventScreenTouch:
			var touch: InputEventScreenTouch = event as InputEventScreenTouch
			if touch.pressed:
				_show_battle_tap_feedback(button, touch.position)
				button.set_meta("battle_pointer_feedback_msec", Time.get_ticks_msec())
	)
	button.button_down.connect(func() -> void:
		var last_pointer_msec: int = int(button.get_meta("battle_pointer_feedback_msec", -1000))
		if Time.get_ticks_msec() - last_pointer_msec > 80:
			_show_battle_tap_feedback(button, button.size * 0.5)
	)


func _show_battle_tap_feedback(button: Button, local_position: Vector2) -> void:
	if button == null or not is_instance_valid(button) or button.get_parent() == null:
		return
	var parent: Node = button.get_parent()
	var feedback_parent: Control = parent as Control
	var feedback_parent_node: Node = feedback_parent
	var clamp_to_viewport: bool = false
	var feedback_bounds: Vector2 = Vector2.ZERO
	if feedback_parent != null:
		feedback_bounds = feedback_parent.size
	elif _hud != null:
		feedback_parent_node = _hud
		clamp_to_viewport = true
		feedback_bounds = get_viewport_rect().size
	if feedback_parent_node == null:
		return
	_battle_tap_feedback_index += 1
	var feedback: TextureRect = TextureRect.new()
	feedback.name = "BattleTapFeedback%d" % _battle_tap_feedback_index
	feedback.texture = BattleTapFeedbackTexture
	feedback.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	feedback.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var edge: float = clamp(max(button.size.x, button.size.y) * 1.75, 132.0, 220.0)
	feedback.size = Vector2(edge, edge)
	feedback.position = button.position + local_position - feedback.size * 0.5
	if clamp_to_viewport and feedback_bounds.x > 0.0 and feedback_bounds.y > 0.0:
		feedback.position = Vector2(
			clampf(feedback.position.x, 0.0, maxf(0.0, feedback_bounds.x - feedback.size.x)),
			clampf(feedback.position.y, 0.0, maxf(0.0, feedback_bounds.y - feedback.size.y))
		)
	feedback.pivot_offset = feedback.size * 0.5
	feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback.z_index = button.z_index + 260
	feedback.scale = Vector2(0.72, 0.72)
	feedback_parent_node.add_child(feedback)
	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "scale", Vector2(1.10, 1.10), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(feedback.queue_free)


func _animate_control_scale(target: Control, scale_value: float, duration: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	target.pivot_offset = target.size * 0.5
	var tween: Tween = create_tween()
	tween.tween_property(target, "scale", Vector2(scale_value, scale_value), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
		_spawn_enemy(str(state["enemy"]), int(state.get("index", 1)))
		state["remaining"] = int(state["remaining"]) - 1
		state["next_time"] = float(state["next_time"]) + float(state["interval"])


func _spawn_enemy(enemy_id: String, wave_index: int = -1) -> void:
	var enemy_data: Dictionary = TowerStatsScript.get_enemy(enemy_id)
	var enemy: Node2D = EnemyScript.new()
	enemy.configure(enemy_data, level.path_points)
	if wave_index > 0:
		enemy.set_meta("battle_wave_index", wave_index)
	enemy.defeated.connect(_on_enemy_defeated)
	enemy.reached_goal.connect(_on_enemy_reached_goal)
	enemies.append(enemy)
	_enemy_layer.add_child(enemy)
	_show_enemy_spawn_feedback(enemy.global_position)


func _tick_towers(delta: float) -> void:
	for tower: Node2D in towers:
		tower.tick(delta, enemies)


func _on_slot_clicked(slot: Node2D) -> void:
	if finished:
		return
	if slot.occupied:
		_show_build_slot_manage_badge_feedback(slot)
		_show_tower_action_overlay(slot)
		return
	var tower_id: String = _selected_tower_id
	if not level.allowed_towers.has(tower_id):
		tower_id = level.allowed_towers[0] if not level.allowed_towers.is_empty() else "orange_cat"
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var cost: int = int(stats.get("cost", 60))
	if coins < cost:
		_tip_label.text = "小鱼干不够，先挡住下一波小老鼠。"
		_update_build_slot_tower_ghosts()
		_show_build_slot_affordability_press_feedback(slot)
		_show_resource_shortage_feedback("小鱼干不够  还差 %d" % max(1, cost - coins), slot.position)
		return
	coins -= cost
	slot.set_occupied(true)
	_mark_slot_button_occupied(slot)
	var tower: Node2D = TowerScript.new()
	tower.configure(tower_id, stats)
	tower.position = slot.position
	tower.fired.connect(_on_tower_fired)
	towers.append(tower)
	_tower_by_slot[slot] = tower
	_tower_layer.add_child(tower)
	_show_build_success_feedback(slot.position)
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

		var manage_badge: TextureRect = _hud_texture_rect(_build_slot_manage_badge_name(index), BuildSlotManageBadgeTexture, visual.position + Vector2(50, -12), Vector2(44, 44))
		manage_badge.z_index = 4
		manage_badge.visible = false
		manage_badge.set_meta("image2_slot_manage_base_scale", manage_badge.scale)
		_slot_buttons.add_child(manage_badge)

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
	_update_build_slot_range_previews()
	_update_build_slot_tower_ghosts()


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
			var manage_badge: TextureRect = _slot_buttons.get_node_or_null(NodePath(button.name.replace("Button", "ManageBadge"))) as TextureRect
			if manage_badge != null:
				manage_badge.visible = true
			_update_build_slot_range_previews()
			_update_build_slot_tower_ghosts()
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
			var manage_badge: TextureRect = _slot_buttons.get_node_or_null(NodePath(button.name.replace("Button", "ManageBadge"))) as TextureRect
			if manage_badge != null:
				manage_badge.visible = false
				manage_badge.scale = manage_badge.get_meta("image2_slot_manage_base_scale", Vector2.ONE) as Vector2
				manage_badge.rotation = 0.0
				manage_badge.set_meta("image2_slot_manage_feedback", false)
			_update_build_slot_range_previews(true)
			_update_build_slot_tower_ghosts(true)
			return


func _update_build_slot_range_previews(animated: bool = false) -> void:
	if _slot_layer == null:
		return
	var target_scale: Vector2 = _build_slot_range_preview_scale(_selected_tower_id)
	var index: int = 1
	for child: Node in _slot_layer.get_children():
		var slot: Node2D = child as Node2D
		if slot == null:
			continue
		var preview: Sprite2D = slot.get_node_or_null(NodePath(_build_slot_range_preview_name(index))) as Sprite2D
		if preview == null:
			preview = _create_build_slot_range_preview(index)
			slot.add_child(preview)
		var occupied: bool = bool(slot.get("occupied"))
		preview.visible = not occupied
		preview.scale = target_scale
		if preview.visible and animated:
			_show_build_slot_range_preview_refresh(preview)
		index += 1


func _create_build_slot_range_preview(index: int) -> Sprite2D:
	var preview: Sprite2D = Sprite2D.new()
	preview.name = _build_slot_range_preview_name(index)
	preview.texture = TowerRangeAuraTexture
	preview.centered = true
	preview.z_index = -3
	preview.modulate = Color(1.0, 1.0, 1.0, 0.36)
	_start_build_slot_range_preview_breath(preview)
	return preview


func _build_slot_range_preview_name(index: int) -> String:
	return "BuildSlot%dRangePreview" % index


func _build_slot_range_preview_scale(tower_id: String) -> Vector2:
	if TowerRangeAuraTexture == null:
		return Vector2.ONE
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var attack_range: float = float(stats.get("range", 160.0))
	var texture_size: Vector2 = TowerRangeAuraTexture.get_size()
	var ratio: float = (attack_range * 2.0) / max(1.0, texture_size.x)
	return Vector2(ratio, ratio)


func _start_build_slot_range_preview_breath(preview: Sprite2D) -> void:
	var tween: Tween = preview.create_tween()
	tween.set_loops()
	tween.tween_property(preview, "modulate:a", 0.50, 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(preview, "modulate:a", 0.34, 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _show_build_slot_range_preview_refresh(preview: Sprite2D) -> void:
	preview.rotation = -0.035
	var tween: Tween = preview.create_tween()
	tween.tween_property(preview, "rotation", 0.035, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(preview, "rotation", 0.0, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_build_slot_tower_ghosts(animated: bool = false) -> void:
	if _slot_layer == null:
		return
	var index: int = 1
	for child: Node in _slot_layer.get_children():
		var slot: Node2D = child as Node2D
		if slot == null:
			continue
		var ghost: Sprite2D = slot.get_node_or_null(NodePath(_build_slot_tower_ghost_name(index))) as Sprite2D
		if ghost == null:
			ghost = _create_build_slot_tower_ghost(index)
			slot.add_child(ghost)
		_configure_build_slot_tower_ghost(ghost, _selected_tower_id)
		var occupied: bool = bool(slot.get("occupied"))
		ghost.visible = not occupied and ghost.texture != null
		_update_build_slot_affordability_state(slot, index, ghost)
		if ghost.visible and animated:
			_show_build_slot_tower_ghost_refresh(ghost)
		index += 1


func _create_build_slot_tower_ghost(index: int) -> Sprite2D:
	var ghost: Sprite2D = Sprite2D.new()
	ghost.name = _build_slot_tower_ghost_name(index)
	ghost.centered = true
	ghost.position = Vector2(0.0, -54.0)
	ghost.z_index = -1
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.44)
	_start_build_slot_tower_ghost_breath(ghost)
	return ghost


func _build_slot_tower_ghost_name(index: int) -> String:
	return "BuildSlot%dTowerGhost" % index


func _build_slot_manage_badge_name(index: int) -> String:
	return "BuildSlot%dManageBadge" % index


func _build_slot_affordability_stamp_name(index: int) -> String:
	return "BuildSlot%dAffordabilityStamp" % index


func _configure_build_slot_tower_ghost(ghost: Sprite2D, tower_id: String) -> void:
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var texture_path: String = str(stats.get("texture", ""))
	if texture_path.is_empty() or not ResourceLoader.exists(texture_path):
		ghost.texture = null
		return
	if ghost.texture == null or ghost.texture.resource_path != texture_path:
		ghost.texture = load(texture_path) as Texture2D
	if ghost.texture == null:
		return
	var texture_size: Vector2 = ghost.texture.get_size()
	var frame_size: Vector2 = texture_size
	if texture_path.ends_with("_sheet.png"):
		frame_size = texture_size / 2.0
		ghost.region_enabled = true
		ghost.region_rect = Rect2(Vector2.ZERO, frame_size)
	else:
		ghost.region_enabled = false
	var ratio: float = 72.0 / max(1.0, frame_size.y)
	ghost.scale = Vector2(ratio, ratio)
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.44)


func _update_build_slot_affordability_state(slot: Node2D, index: int, ghost: Sprite2D) -> void:
	var stamp: Sprite2D = slot.get_node_or_null(NodePath(_build_slot_affordability_stamp_name(index))) as Sprite2D
	if stamp == null:
		stamp = _create_build_slot_affordability_stamp(index)
		slot.add_child(stamp)
	var is_shortage: bool = not _selected_tower_affordable()
	var occupied: bool = bool(slot.get("occupied"))
	stamp.visible = not occupied and is_shortage
	if ghost != null:
		if is_shortage:
			ghost.modulate = Color(0.62, 0.55, 0.50, ghost.modulate.a)
		else:
			ghost.modulate = Color(1.0, 1.0, 1.0, ghost.modulate.a)


func _create_build_slot_affordability_stamp(index: int) -> Sprite2D:
	var stamp: Sprite2D = Sprite2D.new()
	stamp.name = _build_slot_affordability_stamp_name(index)
	stamp.texture = BattleTowerCardInsufficientFishStampTexture
	stamp.centered = true
	stamp.position = Vector2(44.0, -72.0)
	stamp.z_index = 1
	var texture_size: Vector2 = BattleTowerCardInsufficientFishStampTexture.get_size()
	var ratio: float = 58.0 / max(1.0, max(texture_size.x, texture_size.y))
	stamp.scale = Vector2(ratio, ratio)
	stamp.set_meta("image2_slot_affordability_base_scale", stamp.scale)
	stamp.modulate = Color(1.0, 1.0, 1.0, 0.96)
	return stamp


func _show_build_slot_affordability_press_feedback(slot: Node2D) -> void:
	var index: int = _build_slot_index(slot)
	if index <= 0:
		return
	var stamp: Sprite2D = slot.get_node_or_null(NodePath(_build_slot_affordability_stamp_name(index))) as Sprite2D
	if stamp == null:
		stamp = _create_build_slot_affordability_stamp(index)
		slot.add_child(stamp)
	stamp.visible = true
	stamp.set_meta("image2_slot_affordability_feedback", true)
	var base_scale: Vector2 = stamp.get_meta("image2_slot_affordability_base_scale", stamp.scale) as Vector2
	stamp.scale = base_scale * 1.34
	stamp.rotation = -0.14
	stamp.modulate = Color(1.0, 1.0, 1.0, 1.0)
	var tween: Tween = stamp.create_tween()
	tween.set_parallel(true)
	tween.tween_property(stamp, "scale", base_scale * 1.08, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(stamp, "rotation", 0.08, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(stamp, "modulate:a", 0.96, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(stamp, "scale", base_scale, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(stamp, "rotation", 0.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void:
		if stamp != null and is_instance_valid(stamp):
			stamp.set_meta("image2_slot_affordability_feedback", false)
	)


func _show_build_slot_manage_badge_feedback(slot: Node2D) -> void:
	if _slot_buttons == null:
		return
	var index: int = _build_slot_index(slot)
	if index <= 0:
		return
	var manage_badge: TextureRect = _slot_buttons.get_node_or_null(NodePath(_build_slot_manage_badge_name(index))) as TextureRect
	if manage_badge == null:
		return
	manage_badge.visible = true
	manage_badge.set_meta("image2_slot_manage_feedback", true)
	manage_badge.pivot_offset = manage_badge.size * 0.5
	var base_scale: Vector2 = manage_badge.get_meta("image2_slot_manage_base_scale", Vector2.ONE) as Vector2
	manage_badge.scale = base_scale * 1.28
	manage_badge.rotation = -0.10
	var tween: Tween = manage_badge.create_tween()
	tween.set_parallel(true)
	tween.tween_property(manage_badge, "scale", base_scale * 1.08, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(manage_badge, "rotation", 0.06, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(manage_badge, "scale", base_scale, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(manage_badge, "rotation", 0.0, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void:
		if manage_badge != null and is_instance_valid(manage_badge):
			manage_badge.set_meta("image2_slot_manage_feedback", false)
	)


func _build_slot_index(slot: Node2D) -> int:
	if _slot_layer == null or slot == null:
		return -1
	var index: int = 1
	for child: Node in _slot_layer.get_children():
		if child == slot:
			return index
		if child is Node2D:
			index += 1
	return -1


func _update_build_slot_affordability_states() -> void:
	if _slot_layer == null:
		return
	var index: int = 1
	for child: Node in _slot_layer.get_children():
		var slot: Node2D = child as Node2D
		if slot == null:
			continue
		var ghost: Sprite2D = slot.get_node_or_null(NodePath(_build_slot_tower_ghost_name(index))) as Sprite2D
		if ghost != null:
			_update_build_slot_affordability_state(slot, index, ghost)
		index += 1


func _selected_tower_affordable() -> bool:
	if level == null:
		return true
	var stats: Dictionary = TowerStatsScript.get_tower(_selected_tower_id)
	return coins >= int(stats.get("cost", 0))


func _start_build_slot_tower_ghost_breath(ghost: Sprite2D) -> void:
	var tween: Tween = ghost.create_tween()
	tween.set_loops()
	tween.tween_property(ghost, "modulate:a", 0.54, 0.80).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(ghost, "modulate:a", 0.34, 0.80).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _show_build_slot_tower_ghost_refresh(ghost: Sprite2D) -> void:
	ghost.rotation = -0.03
	var tween: Tween = ghost.create_tween()
	tween.tween_property(ghost, "rotation", 0.03, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(ghost, "rotation", 0.0, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
	var upgrade_label: Label = _pause_label(_tower_upgrade_label_text(tower, upgrade_cost), Vector2(384, 456), Vector2(236, 58), 24, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER)
	upgrade_label.name = "TowerUpgradeCostLabel"
	overlay.add_child(upgrade_label)
	var sell_label: Label = _pause_label("出售返还 %d" % sell_refund, Vector2(660, 456), Vector2(236, 58), 24, Color(0.27, 0.13, 0.07), HORIZONTAL_ALIGNMENT_CENTER)
	overlay.add_child(sell_label)
	_refresh_tower_action_max_state(overlay, tower)

	var upgrade_button: Button = _pause_transparent_text_button("UpgradeTowerButton", "", Rect2(Vector2(384, 442), Vector2(244, 82)), 24)
	_attach_press_feedback(upgrade_button, panel)
	upgrade_button.pressed.connect(func() -> void:
		var previous_level: int = int(tower.get("level"))
		_upgrade_tower_from_overlay(tower, panel)
		if tower != null and is_instance_valid(tower):
			stats_label.text = _tower_action_stats_text(tower)
			sell_label.text = "出售返还 %d" % _tower_sell_refund(tower)
			upgrade_label.text = _tower_upgrade_label_text(tower, upgrade_cost)
			if int(tower.get("level")) != previous_level:
				_refresh_tower_action_max_state(overlay, tower)
	)
	overlay.add_child(upgrade_button)

	var sell_button: Button = _pause_transparent_text_button("SellTowerButton", "", Rect2(Vector2(652, 442), Vector2(244, 82)), 24)
	_attach_press_feedback(sell_button, panel)
	sell_button.pressed.connect(func() -> void:
		_sell_tower_from_overlay(tower, slot, overlay, sell_button)
	)
	overlay.add_child(sell_button)

	var close_button: Button = _pause_transparent_text_button("CloseTowerActionButton", "", Rect2(Vector2(842, 206), Vector2(106, 92)), 22)
	_attach_press_feedback(close_button, panel)
	close_button.pressed.connect(func() -> void: _animate_hud_overlay_exit(overlay, close_button))
	overlay.add_child(close_button)
	_pop_in_control(panel)


func _upgrade_tower_from_overlay(tower: Node2D, feedback_target: Control) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	var upgrade_cost: int = int(tower.get("upgrade_cost"))
	if _tower_is_max_level(tower):
		if _tip_label != null:
			_tip_label.text = "%s 已经满级，守住这一波！" % str(tower.get("display_name"))
		_show_tower_max_level_feedback(tower.global_position)
		_animate_control_scale(feedback_target, 1.03, 0.08)
		return
	if coins < upgrade_cost:
		_tip_label.text = "小鱼干不够，先守住下一波。"
		_show_resource_shortage_feedback("升级还差 %d 小鱼干" % max(1, upgrade_cost - coins), tower.global_position)
		_animate_control_scale(feedback_target, 0.98, 0.06)
		return
	var did_upgrade: bool = bool(tower.call("upgrade"))
	if not did_upgrade:
		_show_tower_max_level_feedback(tower.global_position)
		_update_hud()
		return
	coins -= upgrade_cost
	_show_tower_upgrade_feedback(tower.global_position)
	_tip_label.text = "%s 升到 %d 级！" % [str(tower.get("display_name")), int(tower.get("level"))]
	_animate_control_scale(feedback_target, 1.05, 0.08)
	_update_hud()


func _sell_tower_from_overlay(tower: Node2D, slot: Node2D, overlay: Control, trigger_button: Button = null) -> void:
	if tower == null or not is_instance_valid(tower):
		return
	var refund: int = _tower_sell_refund(tower)
	var feedback_anchor: Vector2 = tower.global_position
	coins += refund
	towers.erase(tower)
	_tower_by_slot.erase(slot)
	slot.set_occupied(false)
	_mark_slot_button_empty(slot)
	_show_tower_sell_feedback(feedback_anchor)
	tower.queue_free()
	if overlay != null and is_instance_valid(overlay):
		_animate_hud_overlay_exit(overlay, trigger_button)
	_tip_label.text = "已收回猫塔，返还小鱼干 %d。" % refund
	_update_hud()


func _tower_sell_refund(tower: Node2D) -> int:
	if tower == null:
		return 0
	var base_refund: int = int(round(float(tower.get("cost")) * 0.5))
	var upgrade_refund: int = int(round(float(max(0, int(tower.get("level")) - 1) * int(tower.get("upgrade_cost"))) * 0.35))
	return max(1, base_refund + upgrade_refund)


func _tower_action_stats_text(tower: Node2D) -> String:
	return "等级 %d/%d    伤害 %.1f    范围 %d" % [int(tower.get("level")), _tower_max_level(tower), float(tower.get("damage")), int(float(tower.get("attack_range")))]


func _tower_upgrade_label_text(tower: Node2D, upgrade_cost: int) -> String:
	if _tower_is_max_level(tower):
		return "已达满级"
	return "升级消耗 %d" % upgrade_cost


func _tower_max_level(tower: Node2D) -> int:
	if tower == null:
		return 3
	return max(1, int(tower.get("max_level")))


func _tower_is_max_level(tower: Node2D) -> bool:
	if tower == null or not is_instance_valid(tower):
		return false
	return int(tower.get("level")) >= _tower_max_level(tower)


func _refresh_tower_action_max_state(overlay: Control, tower: Node2D) -> void:
	if overlay == null or not is_instance_valid(overlay):
		return
	var existing_stamp: Node = overlay.find_child("TowerMaxLevelStamp", true, false)
	if existing_stamp != null:
		existing_stamp.queue_free()
	var existing_label: Node = overlay.find_child("TowerMaxLevelLabel", true, false)
	if existing_label != null:
		existing_label.queue_free()
	if not _tower_is_max_level(tower):
		return

	var stamp: TextureRect = _hud_texture_rect("TowerMaxLevelStamp", TowerMaxLevelStampTexture, Vector2(418, 384), Vector2(190, 150))
	stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stamp.z_index = 8
	stamp.process_mode = Node.PROCESS_MODE_ALWAYS
	stamp.pivot_offset = stamp.size * 0.5
	stamp.scale = Vector2(0.88, 0.88)
	stamp.modulate = Color(1.0, 1.0, 1.0, 0.0)
	overlay.add_child(stamp)

	var label: Label = _pause_label("满级", Vector2(445, 440), Vector2(136, 42), 30, Color(1.0, 0.88, 0.38), HORIZONTAL_ALIGNMENT_CENTER)
	label.name = "TowerMaxLevelLabel"
	label.z_index = 9
	label.add_theme_color_override("font_outline_color", Color(0.55, 0.12, 0.02, 0.95))
	label.add_theme_constant_override("outline_size", 5)
	overlay.add_child(label)

	var tween: Tween = stamp.create_tween()
	tween.set_parallel(true)
	tween.tween_property(stamp, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(stamp, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _show_tower_max_level_feedback(world_anchor: Vector2) -> void:
	if _hud == null:
		return
	var existing: Node = _hud.find_child("TowerMaxLevelFeedback", true, false)
	if existing != null:
		existing.queue_free()
	_tower_max_level_feedback_index += 1
	var feedback: TextureRect = _hud_texture_rect("TowerMaxLevelFeedback", TowerMaxLevelBurstTexture, Vector2.ZERO, Vector2(320, 320))
	feedback.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	feedback.z_index = 86
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	var target_center: Vector2 = Vector2(clamp(world_anchor.x, 440.0, 820.0), clamp(world_anchor.y - 74.0, 230.0, 430.0))
	feedback.position = target_center - feedback.size * 0.5
	feedback.scale = Vector2(0.68, 0.68)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label("满级啦")
	label.name = "TowerMaxLevelFeedbackLabel"
	label.position = Vector2(72, 202)
	label.size = Vector2(176, 48)
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color(0.43, 0.15, 0.04))
	label.add_theme_constant_override("outline_size", 4)
	label.clip_text = true
	feedback.add_child(label)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", -5.0, 0.08).set_delay(0.14).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 5.0, 0.08).set_delay(0.24).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.08).set_delay(0.34).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "position:y", feedback.position.y - 24.0, 0.44).set_delay(0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.26).set_delay(1.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.38)


func _show_resource_shortage_feedback(message: String, world_anchor: Vector2) -> void:
	if _hud == null:
		return
	var existing: Node = _hud.find_child("BattleResourceFeedback", true, false)
	if existing != null:
		existing.queue_free()

	var feedback: TextureRect = _hud_texture_rect("BattleResourceFeedback", BattleResourceShortageBurstTexture, Vector2.ZERO, Vector2(390, 390))
	feedback.z_index = 80
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	var target_center: Vector2 = Vector2(clamp(world_anchor.x, 470.0, 810.0), 430.0)
	feedback.position = target_center - feedback.size * 0.5
	feedback.scale = Vector2(0.72, 0.72)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label(message)
	label.name = "BattleResourceFeedbackLabel"
	label.position = Vector2(48, 252)
	label.size = Vector2(294, 54)
	label.add_theme_font_size_override("font_size", 23)
	label.add_theme_color_override("font_color", Color(0.39, 0.17, 0.05))
	label.add_theme_constant_override("outline_size", 4)
	label.clip_text = true
	feedback.add_child(label)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", -4.0, 0.06).set_delay(0.14).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 4.0, 0.07).set_delay(0.20).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.08).set_delay(0.28).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.28).set_delay(1.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.34)


func _show_base_damage_feedback(damage: int, world_anchor: Vector2) -> void:
	if _hud == null:
		return
	var existing: Node = _hud.find_child("BaseDamageFeedback", true, false)
	if existing != null:
		existing.queue_free()

	var feedback: TextureRect = _hud_texture_rect("BaseDamageFeedback", BaseDamageWarningBurstTexture, Vector2.ZERO, Vector2(320, 320))
	feedback.z_index = 82
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	var target_center: Vector2 = Vector2(clamp(world_anchor.x - 205.0, 820.0, 1040.0), clamp(world_anchor.y + 65.0, 300.0, 400.0))
	feedback.position = target_center - feedback.size * 0.5
	feedback.scale = Vector2(0.72, 0.72)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label("-%d 猫粮罐" % max(1, damage))
	label.name = "BaseDamageFeedbackLabel"
	label.position = Vector2(45, 225)
	label.size = Vector2(230, 48)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.46, 0.12, 0.04))
	label.add_theme_constant_override("outline_size", 4)
	label.clip_text = true
	feedback.add_child(label)

	if _base_label != null:
		_animate_control_scale(_base_label, 1.10, 0.08)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", 5.0, 0.06).set_delay(0.14).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", -5.0, 0.07).set_delay(0.20).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.08).set_delay(0.29).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "position:y", feedback.position.y - 18.0, 0.36).set_delay(0.54).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.28).set_delay(1.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.38)


func _show_enemy_reward_feedback(reward: int, world_anchor: Vector2) -> void:
	if _hud == null or reward <= 0:
		return
	_enemy_reward_feedback_index += 1

	var feedback: TextureRect = _hud_texture_rect("EnemyRewardFeedback%d" % _enemy_reward_feedback_index, EnemyRewardFishBurstTexture, Vector2.ZERO, Vector2(260, 260))
	feedback.z_index = 84
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	var reward_side_offset: float = 150.0 if world_anchor.x < 760.0 else -150.0
	var target_center: Vector2 = Vector2(clamp(world_anchor.x + reward_side_offset, 220.0, 990.0), clamp(world_anchor.y - 76.0, 165.0, 475.0))
	feedback.position = target_center - feedback.size * 0.5
	feedback.scale = Vector2(0.64, 0.64)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label("+%d 小鱼干" % reward)
	label.name = "EnemyRewardFeedbackLabel"
	label.position = Vector2(34, 180)
	label.size = Vector2(192, 46)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.36, 0.16, 0.05))
	label.add_theme_constant_override("outline_size", 4)
	label.clip_text = true
	feedback.add_child(label)

	if _coins_label != null:
		_animate_control_scale(_coins_label, 1.10, 0.08)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", -3.0, 0.08).set_delay(0.13).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 3.0, 0.08).set_delay(0.22).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.08).set_delay(0.31).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "position:y", feedback.position.y - 34.0, 0.52).set_delay(0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.30).set_delay(1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.42)


func _show_enemy_hit_feedback(world_anchor: Vector2) -> void:
	if _world == null:
		return
	_enemy_hit_feedback_index += 1
	var effect: Sprite2D = Sprite2D.new()
	effect.name = "EnemyHitFeedback%d" % _enemy_hit_feedback_index
	effect.texture = EnemyHitFishSparkTexture
	effect.centered = true
	effect.position = world_anchor + Vector2(4, -18)
	effect.scale = Vector2(0.058, 0.058)
	effect.rotation_degrees = -10.0 + float(_enemy_hit_feedback_index % 5) * 5.0
	effect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	effect.z_index = 24
	_world.add_child(effect)

	var tween: Tween = effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 1.0, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "scale", Vector2(0.092, 0.092), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation_degrees", effect.rotation_degrees + 12.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "position:y", effect.position.y - 16.0, 0.25).set_delay(0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.0, 0.16).set_delay(0.20).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(effect, "queue_free")).set_delay(0.38)


func _show_enemy_spawn_feedback(world_anchor: Vector2) -> void:
	if _world == null:
		return
	_enemy_spawn_feedback_index += 1
	var effect: Sprite2D = Sprite2D.new()
	effect.name = "EnemySpawnFeedback%d" % _enemy_spawn_feedback_index
	effect.texture = EnemySpawnMouseDustTexture
	effect.centered = true
	var viewport_size: Vector2 = get_viewport_rect().size
	effect.position = Vector2(
		clampf(world_anchor.x, 64.0, maxf(64.0, viewport_size.x - 64.0)),
		clampf(world_anchor.y - 18.0, 76.0, maxf(76.0, viewport_size.y - 128.0))
	)
	effect.scale = Vector2(0.036, 0.036)
	effect.rotation_degrees = -4.0 + float(_enemy_spawn_feedback_index % 3) * 4.0
	effect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	effect.z_index = 22
	_world.add_child(effect)

	var tween: Tween = effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 0.94, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "scale", Vector2(0.066, 0.066), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation_degrees", effect.rotation_degrees + 8.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "position:y", effect.position.y - 14.0, 0.32).set_delay(0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.0, 0.18).set_delay(0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(effect, "queue_free")).set_delay(0.56)


func _show_enemy_defeat_feedback(world_anchor: Vector2) -> void:
	if _world == null:
		return
	_enemy_defeat_feedback_index += 1
	var effect: Sprite2D = Sprite2D.new()
	effect.name = "EnemyDefeatFeedback%d" % _enemy_defeat_feedback_index
	effect.texture = EnemyDefeatMousePuffTexture
	effect.centered = true
	effect.position = world_anchor + Vector2(0, -16)
	effect.scale = Vector2(0.046, 0.046)
	effect.rotation_degrees = -6.0 + float(_enemy_defeat_feedback_index % 4) * 4.0
	effect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	effect.z_index = 24
	_world.add_child(effect)

	var tween: Tween = effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 0.96, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "scale", Vector2(0.086, 0.086), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation_degrees", effect.rotation_degrees + 9.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "position:y", effect.position.y - 22.0, 0.38).set_delay(0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.0, 0.22).set_delay(0.46).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(effect, "queue_free")).set_delay(0.76)


func _show_tower_fire_feedback(tower_anchor: Vector2, target_anchor: Vector2) -> void:
	if _world == null:
		return
	_tower_fire_feedback_index += 1
	var direction: Vector2 = target_anchor - tower_anchor
	if direction.length() <= 0.001:
		direction = Vector2.RIGHT
	direction = direction.normalized()

	var effect: Sprite2D = Sprite2D.new()
	effect.name = "TowerFireFeedback%d" % _tower_fire_feedback_index
	effect.texture = TowerFireFishboneMuzzleFlashTexture
	effect.centered = true
	effect.position = tower_anchor + Vector2(0, -28) + direction * 48.0
	effect.rotation = direction.angle()
	effect.scale = Vector2(0.038, 0.038)
	effect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	effect.z_index = 25
	_world.add_child(effect)

	var tween: Tween = effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 1.0, 0.04).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "scale", Vector2(0.068, 0.068), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "position", effect.position + direction * 22.0 + Vector2(0, -4), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.0, 0.16).set_delay(0.13).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(effect, "queue_free")).set_delay(0.34)


func _spawn_tower_projectile(tower_anchor: Vector2, target: Node2D) -> void:
	if _world == null or target == null or not is_instance_valid(target):
		return
	_projectile_index += 1
	var projectile: Sprite2D = ProjectileScript.new()
	projectile.name = "Image2Projectile%d" % _projectile_index
	projectile.global_position = tower_anchor + Vector2(0, -28)
	projectile.configure(target, 0.0, Color.WHITE, false)
	_world.add_child(projectile)


func _show_build_success_feedback(world_anchor: Vector2) -> void:
	if _world == null:
		return
	_build_success_feedback_index += 1
	var effect: Sprite2D = Sprite2D.new()
	effect.name = "BuildSuccessFeedback%d" % _build_success_feedback_index
	effect.texture = BuildSuccessCatPawPuffTexture
	effect.centered = true
	effect.position = world_anchor + Vector2(0, -14)
	effect.scale = Vector2(0.070, 0.070)
	effect.rotation_degrees = -4.0
	effect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	effect.z_index = 22
	_world.add_child(effect)

	var tween: Tween = effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 0.92, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "scale", Vector2(0.112, 0.112), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation_degrees", 5.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "position:y", effect.position.y - 18.0, 0.36).set_delay(0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.0, 0.22).set_delay(0.46).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(effect, "queue_free")).set_delay(0.72)


func _show_tower_upgrade_feedback(world_anchor: Vector2) -> void:
	if _world == null:
		return
	_tower_upgrade_feedback_index += 1
	var effect: Sprite2D = Sprite2D.new()
	effect.name = "TowerUpgradeFeedback%d" % _tower_upgrade_feedback_index
	effect.texture = TowerUpgradeCatStarburstTexture
	effect.centered = true
	effect.position = world_anchor + Vector2(0, -42)
	effect.scale = Vector2(0.060, 0.060)
	effect.rotation_degrees = -8.0
	effect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	effect.z_index = 26
	_world.add_child(effect)

	var tween: Tween = effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 0.95, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "scale", Vector2(0.108, 0.108), 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation_degrees", 8.0, 0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "position:y", effect.position.y - 28.0, 0.42).set_delay(0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.0, 0.24).set_delay(0.58).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(effect, "queue_free")).set_delay(0.88)


func _show_tower_sell_feedback(world_anchor: Vector2) -> void:
	if _world == null:
		return
	_tower_sell_feedback_index += 1
	var effect: Sprite2D = Sprite2D.new()
	effect.name = "TowerSellFeedback%d" % _tower_sell_feedback_index
	effect.texture = TowerSellFishRefundBurstTexture
	effect.centered = true
	effect.position = world_anchor + Vector2(4, -34)
	effect.scale = Vector2(0.055, 0.055)
	effect.rotation_degrees = -12.0
	effect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	effect.z_index = 28
	_world.add_child(effect)

	var tween: Tween = effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 0.96, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "scale", Vector2(0.102, 0.102), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation_degrees", 5.0, 0.26).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "position", effect.position + Vector2(-62.0, -86.0), 0.52).set_delay(0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate:a", 0.0, 0.22).set_delay(0.48).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(effect, "queue_free")).set_delay(0.76)


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


func _tower_select_card(tower_id: String) -> Control:
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var card_size := Vector2(174, 172)
	var card: Control = Control.new()
	card.name = _tower_card_container_name(tower_id)
	card.custom_minimum_size = card_size
	card.size = card_size
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var frame: TextureRect = _hud_texture_rect(_tower_card_frame_name(tower_id), _tower_card_texture(tower_id), Vector2.ZERO, card_size)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(frame)

	var selected_state: TextureRect = _hud_texture_rect(_tower_selected_state_name(tower_id), BattleTowerCardSelectedBadgeTexture, Vector2.ZERO, card_size)
	selected_state.z_index = 2
	selected_state.visible = tower_id == _selected_tower_id
	card.add_child(selected_state)

	var insufficient_state: TextureRect = _hud_texture_rect(_tower_insufficient_state_name(tower_id), BattleTowerCardInsufficientFishStampTexture, Vector2(92, 8), Vector2(76, 76))
	insufficient_state.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	insufficient_state.z_index = 5
	insufficient_state.visible = false
	insufficient_state.modulate = Color(1.0, 1.0, 1.0, 0.94)
	card.add_child(insufficient_state)

	var name_label: Label = _hud_label(str(stats.get("name", tower_id)))
	name_label.name = _tower_label_name(tower_id, "NameLabel")
	name_label.position = Vector2(22, 106)
	name_label.size = Vector2(130, 28)
	name_label.z_index = 3
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.33, 0.14, 0.05))
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(name_label)

	var cost_label: Label = _hud_label("小鱼干 %d" % int(stats.get("cost", 0)))
	cost_label.name = _tower_label_name(tower_id, "CostLabel")
	cost_label.position = Vector2(28, 135)
	cost_label.size = Vector2(118, 24)
	cost_label.z_index = 3
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color(0.46, 0.22, 0.07))
	cost_label.add_theme_constant_override("outline_size", 2)
	card.add_child(cost_label)

	var insufficient_label: Label = _hud_label("")
	insufficient_label.name = _tower_insufficient_label_name(tower_id)
	insufficient_label.position = Vector2(101, 72)
	insufficient_label.size = Vector2(68, 24)
	insufficient_label.z_index = 6
	insufficient_label.visible = false
	insufficient_label.add_theme_font_size_override("font_size", 13)
	insufficient_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.56))
	insufficient_label.add_theme_color_override("font_outline_color", Color(0.58, 0.10, 0.04, 0.95))
	insufficient_label.add_theme_constant_override("outline_size", 3)
	insufficient_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	insufficient_label.clip_text = true
	card.add_child(insufficient_label)

	var button: Button = Button.new()
	button.name = _tower_button_name(tower_id)
	button.text = ""
	button.position = Vector2.ZERO
	button.size = card_size
	button.custom_minimum_size = card_size
	button.z_index = 4
	_make_button_transparent(button)
	_attach_press_feedback(button, card)
	button.pressed.connect(func() -> void: _select_tower(tower_id))
	card.add_child(button)
	return card


func _select_tower(tower_id: String) -> void:
	if not level.allowed_towers.has(tower_id):
		return
	_selected_tower_id = tower_id
	var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
	var cost: int = int(stats.get("cost", 0))
	if coins < cost:
		_tip_label.text = "已选择：%s，还差 %d 小鱼干。" % [str(stats.get("name", tower_id)), max(1, cost - coins)]
	else:
		_tip_label.text = "已选择：%s，点击猫爪位建造。" % str(stats.get("name", tower_id))
	_update_tower_selector_state()
	_update_build_slot_range_previews(true)
	_update_build_slot_tower_ghosts(true)
	_show_tower_card_selection_feedback(tower_id)


func _update_tower_selector_state() -> void:
	if _hud == null or level == null:
		return
	for tower_id: String in level.allowed_towers:
		var selected: bool = tower_id == _selected_tower_id
		var stats: Dictionary = TowerStatsScript.get_tower(tower_id)
		var cost: int = int(stats.get("cost", 0))
		var insufficient: bool = coins < cost
		var selected_state: TextureRect = _hud.find_child(_tower_selected_state_name(tower_id), true, false) as TextureRect
		if selected_state != null:
			selected_state.visible = selected
		var insufficient_state: TextureRect = _hud.find_child(_tower_insufficient_state_name(tower_id), true, false) as TextureRect
		if insufficient_state != null:
			insufficient_state.visible = insufficient
		var insufficient_label: Label = _hud.find_child(_tower_insufficient_label_name(tower_id), true, false) as Label
		if insufficient_label != null:
			insufficient_label.visible = insufficient
			if insufficient:
				insufficient_label.text = "差 %d" % max(1, cost - coins)
		var frame: TextureRect = _hud.find_child(_tower_card_frame_name(tower_id), true, false) as TextureRect
		if frame != null:
			if insufficient:
				frame.modulate = Color(0.70, 0.64, 0.57, 0.78)
			else:
				frame.modulate = Color.WHITE if selected else Color(0.82, 0.78, 0.70, 0.88)


func _show_tower_card_selection_feedback(tower_id: String) -> void:
	if _hud == null:
		return
	var selected_state: TextureRect = _hud.find_child(_tower_selected_state_name(tower_id), true, false) as TextureRect
	if selected_state == null:
		return
	selected_state.pivot_offset = selected_state.size * 0.5
	selected_state.scale = Vector2(0.88, 0.88)
	selected_state.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = selected_state.create_tween()
	tween.set_parallel(true)
	tween.tween_property(selected_state, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(selected_state, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _toggle_battle_speed() -> void:
	_battle_speed_multiplier = 2.0 if _battle_speed_multiplier < 2.0 else 1.0
	if _speed_multiplier_label != null:
		_speed_multiplier_label.text = "%dx" % int(_battle_speed_multiplier)
	if _speed_control_frame != null:
		_speed_control_frame.modulate = Color(1.0, 0.90, 0.66) if _battle_speed_multiplier > 1.0 else Color.WHITE
		_animate_control_scale(_speed_control_frame, 1.08, 0.08)
		_speed_control_frame.set_meta("image2_speed_feedback", true)
	if _tip_label != null:
		_tip_label.text = "战斗速度已切换为 %dx。" % int(_battle_speed_multiplier)
	_show_battle_speed_feedback()


func _show_battle_speed_feedback() -> void:
	if _hud == null or _speed_control_frame == null:
		return
	_battle_speed_feedback_index += 1
	var feedback_position: Vector2 = _speed_control_frame.position - Vector2(64, 62)
	var feedback: TextureRect = _hud_texture_rect("BattleSpeedFeedback%d" % _battle_speed_feedback_index, BattleSpeedFeedbackBurstTexture, feedback_position, Vector2(224, 224))
	feedback.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	feedback.z_index = 89
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	feedback.scale = Vector2(0.64, 0.64)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label("%dx" % int(_battle_speed_multiplier))
	label.name = "BattleSpeedFeedbackLabel"
	label.position = Vector2(82, 86)
	label.size = Vector2(68, 42)
	label.add_theme_font_size_override("font_size", 27)
	label.add_theme_color_override("font_color", Color(0.34, 0.13, 0.02))
	label.add_theme_constant_override("outline_size", 5)
	label.clip_text = true
	feedback.add_child(label)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 0.96, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", -4.0 if _battle_speed_feedback_index % 2 == 0 else 4.0, 0.12).set_delay(0.10).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.16).set_delay(0.24).set_trans(Tween.TRANS_BACK)
	tween.tween_property(feedback, "position:y", feedback.position.y - 12.0, 0.38).set_delay(0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.22).set_delay(0.86).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.12)
	tween.tween_callback(func() -> void:
		if _speed_control_frame != null and is_instance_valid(_speed_control_frame):
			_speed_control_frame.set_meta("image2_speed_feedback", false)
	).set_delay(0.48)


func _rush_next_wave() -> void:
	if finished or level == null:
		return
	var state: Dictionary = _next_rushable_wave_state()
	if state.is_empty():
		if _tip_label != null:
			_tip_label.text = "已经没有可提前的波次，守住清场。"
		_show_wave_rush_feedback("没有可提前的波次")
		_update_hud()
		return

	var wave_index: int = int(state.get("index", 1))
	state["start_time"] = min(float(state.get("start_time", elapsed)), elapsed)
	state["next_time"] = elapsed
	_spawn_due_enemies()
	_show_wave_rush_feedback("提前开波 第 %d/%d 波" % [wave_index, _wave_states.size()])
	if _tip_label != null:
		_tip_label.text = "已提前开波，马上补强猫爪位！"
	_update_hud()


func _next_rushable_wave_state() -> Dictionary:
	for state: Dictionary in _wave_states:
		if int(state.get("remaining", 0)) <= 0:
			continue
		var next_time: float = float(state.get("next_time", state.get("start_time", 0.0)))
		if next_time > elapsed + 0.05:
			return state
	return {}


func _show_wave_rush_feedback(message: String) -> void:
	if _hud == null:
		return
	_wave_rush_feedback_index += 1
	var feedback: TextureRect = _hud_texture_rect("BattleWaveRushFeedback%d" % _wave_rush_feedback_index, BattleWaveRushBurstTexture, Vector2(470, 42), Vector2(340, 192))
	feedback.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	feedback.z_index = 88
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	feedback.scale = Vector2(0.70, 0.70)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label(message)
	label.name = "BattleWaveRushFeedbackLabel"
	label.position = Vector2(38, 132)
	label.size = Vector2(264, 44)
	label.add_theme_font_size_override("font_size", 21)
	label.add_theme_color_override("font_color", Color(0.35, 0.14, 0.04))
	label.add_theme_constant_override("outline_size", 4)
	label.clip_text = true
	feedback.add_child(label)

	var preview_frame: Control = _hud.find_child("WavePreviewFrame", true, false) as Control
	if preview_frame != null:
		_animate_control_scale(preview_frame, 1.07, 0.08)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", -4.0, 0.07).set_delay(0.12).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 4.0, 0.08).set_delay(0.20).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.08).set_delay(0.30).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "position:y", feedback.position.y - 18.0, 0.44).set_delay(0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.28).set_delay(1.00).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.34)


func _maybe_show_wave_clear_feedback(wave_index: int) -> void:
	if wave_index <= 0 or _cleared_wave_indices.has(wave_index):
		return
	var state: Dictionary = _wave_state_for_index(wave_index)
	if state.is_empty() or int(state.get("remaining", 0)) > 0:
		return
	for enemy: Node2D in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if int(enemy.get_meta("battle_wave_index", -1)) == wave_index:
			return
	_cleared_wave_indices[wave_index] = true
	var message: String = "第 %d/%d 波 清理完成" % [wave_index, _wave_states.size()]
	_show_wave_clear_feedback(message)
	if _tip_label != null:
		_tip_label.text = "第 %d 波清理完成，准备下一波猫爪防线。" % wave_index
	_update_hud()


func _wave_state_for_index(wave_index: int) -> Dictionary:
	for state: Dictionary in _wave_states:
		if int(state.get("index", 0)) == wave_index:
			return state
	return {}


func _show_wave_clear_feedback(message: String) -> void:
	if _hud == null:
		return
	_wave_clear_feedback_index += 1
	var feedback: TextureRect = _hud_texture_rect("BattleWaveClearFeedback%d" % _wave_clear_feedback_index, BattleWaveClearBurstTexture, Vector2(468, 126), Vector2(344, 344))
	feedback.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	feedback.z_index = 87
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	feedback.scale = Vector2(0.62, 0.62)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label(message)
	label.name = "BattleWaveClearFeedbackLabel"
	label.position = Vector2(58, 242)
	label.size = Vector2(228, 44)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.35, 0.15, 0.04))
	label.add_theme_constant_override("outline_size", 4)
	label.clip_text = true
	feedback.add_child(label)

	var preview_frame: Control = _hud.find_child("WavePreviewFrame", true, false) as Control
	if preview_frame != null:
		_animate_control_scale(preview_frame, 1.06, 0.08)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 0.96, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", -3.0, 0.08).set_delay(0.13).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 3.0, 0.08).set_delay(0.22).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.09).set_delay(0.31).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "position:y", feedback.position.y - 18.0, 0.44).set_delay(0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.26).set_delay(1.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.44)


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
			_tip_label.text = "毛线陷阱用完了，去商店补给后再来。"
		_show_yarn_trap_empty_feedback()
		_update_yarn_trap_hud()
		return
	var target: Node2D = _first_active_enemy()
	if target == null:
		_arm_yarn_trap()
		return
	_deploy_yarn_trap_on_target(target, false)


func _arm_yarn_trap() -> void:
	_yarn_trap_armed = true
	if _tip_label != null:
		_tip_label.text = "毛线陷阱已待机，等小老鼠出现就自动缠住。"
	_show_yarn_trap_ready_feedback("毛线待机中")
	_show_yarn_trap_ready_hud_glow()
	_update_yarn_trap_hud()


func _try_fire_armed_yarn_trap() -> void:
	if not _yarn_trap_armed or yarn_traps_available <= 0:
		if _yarn_trap_armed and yarn_traps_available <= 0:
			_clear_yarn_trap_ready_state()
		return
	var target: Node2D = _first_active_enemy()
	if target == null:
		return
	_deploy_yarn_trap_on_target(target, true)


func _deploy_yarn_trap_on_target(target: Node2D, from_ready_state: bool) -> void:
	if target == null or not is_instance_valid(target) or yarn_traps_available <= 0:
		return
	yarn_traps_available = max(0, yarn_traps_available - 1)
	_apply_yarn_trap_at(target.global_position)
	_clear_yarn_trap_ready_state()
	_update_yarn_trap_hud()
	yarn_traps_changed.emit(yarn_traps_available)
	if _tip_label != null:
		_tip_label.text = "待机毛线触发！" if from_ready_state else "毛线陷阱缠住了小老鼠！"


func _clear_yarn_trap_ready_state() -> void:
	_yarn_trap_armed = false
	if _hud == null:
		return
	var ready_feedback: Node = _hud.find_child("BattleYarnTrapReadyFeedback", true, false)
	if ready_feedback != null:
		ready_feedback.queue_free()
	var hud_glow: Node = _hud.find_child("YarnTrapReadyHudGlow", true, false)
	if hud_glow != null:
		hud_glow.queue_free()


func _show_yarn_trap_ready_feedback(message: String) -> void:
	if _hud == null:
		return
	var existing: Node = _hud.find_child("BattleYarnTrapReadyFeedback", true, false)
	if existing != null:
		existing.queue_free()

	var feedback: TextureRect = _hud_texture_rect("BattleYarnTrapReadyFeedback", BattleYarnTrapReadyBurstTexture, Vector2(808, 336), Vector2(300, 238))
	feedback.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	feedback.z_index = 85
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	feedback.scale = Vector2(0.72, 0.72)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label(message)
	label.name = "BattleYarnTrapReadyFeedbackLabel"
	label.position = Vector2(58, 158)
	label.size = Vector2(188, 42)
	label.add_theme_font_size_override("font_size", 21)
	label.add_theme_color_override("font_color", Color(0.36, 0.16, 0.05))
	label.add_theme_constant_override("outline_size", 4)
	label.clip_text = true
	feedback.add_child(label)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 0.92, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "position:y", feedback.position.y - 10.0, 0.46).set_delay(0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _show_yarn_trap_ready_hud_glow() -> void:
	if _hud == null or _yarn_trap_hud_icon == null:
		return
	var existing: Node = _hud.find_child("YarnTrapReadyHudGlow", true, false)
	if existing != null:
		existing.queue_free()
	var glow: TextureRect = _hud_texture_rect("YarnTrapReadyHudGlow", BattleYarnTrapReadyBurstTexture, _yarn_trap_hud_icon.position - Vector2(28, 30), Vector2(154, 154))
	glow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	glow.z_index = _yarn_trap_hud_icon.z_index - 1
	glow.process_mode = Node.PROCESS_MODE_ALWAYS
	glow.pivot_offset = glow.size * 0.5
	glow.modulate = Color(1.0, 0.96, 0.74, 0.78)
	_hud.add_child(glow)

	var tween: Tween = glow.create_tween()
	tween.set_loops()
	tween.set_parallel(true)
	tween.tween_property(glow, "scale", Vector2(1.08, 1.08), 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(glow, "modulate:a", 0.48, 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(glow, "scale", Vector2.ONE, 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(glow, "modulate:a", 0.78, 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _show_yarn_trap_empty_feedback() -> void:
	if _hud == null:
		return
	var existing: Node = _hud.find_child("BattleYarnTrapEmptyFeedback", true, false)
	if existing != null:
		existing.queue_free()

	var feedback: TextureRect = _hud_texture_rect("BattleYarnTrapEmptyFeedback", BattleYarnTrapEmptyBurstTexture, Vector2(802, 306), Vector2(340, 340))
	feedback.z_index = 86
	feedback.process_mode = Node.PROCESS_MODE_ALWAYS
	feedback.pivot_offset = feedback.size * 0.5
	feedback.scale = Vector2(0.70, 0.70)
	feedback.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_hud.add_child(feedback)

	var label: Label = _hud_label("毛线陷阱用完啦\n去商店补给")
	label.name = "BattleYarnTrapEmptyFeedbackLabel"
	label.position = Vector2(44, 232)
	label.size = Vector2(260, 72)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.39, 0.17, 0.05))
	label.add_theme_constant_override("outline_size", 4)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_child(label)

	var tween: Tween = feedback.create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "rotation_degrees", -3.0, 0.06).set_delay(0.14).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 3.0, 0.07).set_delay(0.22).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "rotation_degrees", 0.0, 0.08).set_delay(0.31).set_trans(Tween.TRANS_SINE)
	tween.tween_property(feedback, "position:y", feedback.position.y - 18.0, 0.34).set_delay(0.58).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.26).set_delay(1.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(feedback, "queue_free")).set_delay(1.48)


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
		if _yarn_trap_armed:
			_yarn_trap_hud_icon.modulate = Color(1.0, 0.92, 0.56, 1.0)
		else:
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


func _tower_card_container_name(tower_id: String) -> String:
	if tower_id == "orange_cat":
		return "TowerCardOrangeCat"
	if tower_id == "tabby_slow_cat":
		return "TowerCardTabbySlowCat"
	return "TowerCard%s" % tower_id.capitalize().replace("_", "")


func _tower_card_frame_name(tower_id: String) -> String:
	return "%sFrame" % _tower_card_container_name(tower_id)


func _tower_selected_state_name(tower_id: String) -> String:
	return "%sSelectedState" % _tower_card_container_name(tower_id)


func _tower_insufficient_state_name(tower_id: String) -> String:
	return "%sInsufficientFishState" % _tower_card_container_name(tower_id)


func _tower_insufficient_label_name(tower_id: String) -> String:
	return "%sInsufficientFishLabel" % _tower_card_container_name(tower_id)


func _tower_label_name(tower_id: String, suffix: String) -> String:
	return "%s%s" % [_tower_card_container_name(tower_id), suffix]


func _tower_card_texture(tower_id: String) -> Texture2D:
	if tower_id == "tabby_slow_cat":
		return BattleTowerCardTabbyTexture
	return BattleTowerCardOrangeTexture


func _on_tower_fired(tower: Node2D, target: Node2D) -> void:
	if target == null or not is_instance_valid(target):
		return
	if tower != null and is_instance_valid(tower):
		_show_tower_fire_feedback(tower.global_position, target.global_position)
		_spawn_tower_projectile(tower.global_position, target)
	_show_enemy_hit_feedback(target.global_position)


func _on_enemy_defeated(enemy: Node2D) -> void:
	var wave_index: int = int(enemy.get_meta("battle_wave_index", -1))
	if enemies.has(enemy):
		enemies.erase(enemy)
	var reward: int = int(enemy.reward)
	var reward_anchor: Vector2 = enemy.global_position
	coins += reward
	_update_hud()
	_show_enemy_defeat_feedback(reward_anchor)
	_show_enemy_reward_feedback(reward, reward_anchor)
	_maybe_show_wave_clear_feedback(wave_index)
	enemy.queue_free()


func _on_enemy_reached_goal(enemy: Node2D) -> void:
	var wave_index: int = int(enemy.get_meta("battle_wave_index", -1))
	if enemies.has(enemy):
		enemies.erase(enemy)
	var damage: int = int(enemy.base_damage)
	base_hp = max(0, base_hp - damage)
	_base_hit_timer = 0.22
	var base_anchor: Vector2 = _base_node.global_position if _base_node != null else level.path_points[level.path_points.size() - 1]
	_show_base_damage_feedback(damage, base_anchor)
	_update_hud()
	if base_hp > 0:
		_maybe_show_wave_clear_feedback(wave_index)
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
	_pause_overlay.z_index = 100
	_pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud.add_child(_pause_overlay)

	var dim: TextureRect = _hud_texture_rect("PauseDimTexture", CommonOverlayDimTexture, Vector2.ZERO, Vector2(1280, 720))
	dim.modulate = Color(1.0, 1.0, 1.0, 0.62)
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
		_animate_hud_overlay_exit(_pause_overlay, _pause_overlay.find_child("ResumeButton", true, false) as Button, func() -> void:
			_pause_overlay = null
		)
	else:
		_pause_overlay = null


func _restart_from_pause() -> void:
	get_tree().paused = false
	if _pause_overlay != null and is_instance_valid(_pause_overlay):
		_animate_hud_overlay_exit(_pause_overlay, _pause_overlay.find_child("RestartBattleButton", true, false) as Button, func() -> void:
			_pause_overlay = null
			start_level(level_path)
		)
	else:
		_pause_overlay = null
		start_level(level_path)


func _quit_to_levels_from_pause() -> void:
	get_tree().paused = false
	if _pause_overlay != null and is_instance_valid(_pause_overlay):
		_animate_hud_overlay_exit(_pause_overlay, _pause_overlay.find_child("QuitToLevelsButton", true, false) as Button, func() -> void:
			_pause_overlay = null
			exit_to_levels_requested.emit()
		)
	else:
		_pause_overlay = null
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
		_animate_hud_overlay_exit(overlay, close, func() -> void:
			_set_pause_menu_content_visible(true)
		)
	)
	overlay.add_child(close)


func _set_pause_menu_content_visible(visible: bool) -> void:
	if _pause_overlay == null or not is_instance_valid(_pause_overlay):
		return
	for child: Node in _pause_overlay.get_children():
		if child.name == "PauseDimTexture" or child.name == "PauseSettingsOverlay":
			continue
		if child is CanvasItem:
			(child as CanvasItem).visible = visible


func _animate_hud_overlay_exit(target: Control, trigger_button: Button = null, finish_callback: Callable = Callable()) -> void:
	if target == null or not is_instance_valid(target):
		if finish_callback.is_valid():
			finish_callback.call()
		return
	if bool(target.get_meta("image2_overlay_exit_animation", false)):
		return
	target.set_meta("image2_overlay_exit_animation", true)
	target.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target.pivot_offset = Vector2(640, 360)
	target.modulate.a = min(target.modulate.a, 0.96)
	if trigger_button != null and is_instance_valid(trigger_button):
		trigger_button.disabled = true
	var tween: Tween = target.create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2(0.96, 0.96), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(target, "position:y", target.position.y + 14.0, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(target, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func() -> void:
		if is_instance_valid(target):
			target.queue_free()
		if finish_callback.is_valid():
			finish_callback.call()
	)


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
	_update_tower_selector_state()
	_update_build_slot_affordability_states()


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
