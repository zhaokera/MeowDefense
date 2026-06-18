extends RefCounted
class_name TowerStats

const TOWERS: Dictionary = {
	"orange_cat": {
		"id": "orange_cat",
		"name": "橘猫鱼骨炮",
		"description": "稳定攻击最近的小老鼠。",
		"cost": 60,
		"upgrade_cost": 55,
		"max_level": 3,
		"range": 188.0,
		"damage": 5.0,
		"fire_interval": 0.55,
		"texture": "res://assets/generated/towers/orange_cat_tower_sheet.png",
		"accent": Color(1.0, 0.58, 0.23)
	},
	"tabby_slow_cat": {
		"id": "tabby_slow_cat",
		"name": "狸花毛线塔",
		"description": "发射毛线团，造成伤害并短暂减速。",
		"cost": 75,
		"upgrade_cost": 65,
		"max_level": 3,
		"range": 164.0,
		"damage": 3.0,
		"fire_interval": 0.82,
		"slow_multiplier": 0.58,
		"slow_duration": 1.35,
		"texture": "res://assets/generated/towers/tabby_slow_cat_sheet.png",
		"accent": Color(0.72, 0.54, 0.35)
	}
}

const ENEMIES: Dictionary = {
	"mouse_basic": {
		"id": "mouse_basic",
		"name": "偷鱼干小鼠",
		"max_hp": 16,
		"speed": 72.0,
		"reward": 7,
		"damage": 1,
		"texture": "res://assets/generated/enemies/mouse_basic_sheet.png",
		"accent": Color(0.62, 0.45, 0.35)
	},
	"mouse_fast": {
		"id": "mouse_fast",
		"name": "快跑仓鼠",
		"max_hp": 11,
		"speed": 118.0,
		"reward": 9,
		"damage": 1,
		"texture": "res://assets/generated/enemies/mouse_fast_sheet.png",
		"accent": Color(0.84, 0.65, 0.28)
	},
	"rat_tank": {
		"id": "rat_tank",
		"name": "罐头胖鼠",
		"max_hp": 42,
		"speed": 48.0,
		"reward": 16,
		"damage": 2,
		"texture": "res://assets/generated/enemies/rat_tank_sheet.png",
		"accent": Color(0.52, 0.38, 0.30)
	},
	"hamster_runner": {
		"id": "hamster_runner",
		"name": "冲刺仓鼠",
		"max_hp": 9,
		"speed": 146.0,
		"reward": 11,
		"damage": 1,
		"texture": "res://assets/generated/enemies/hamster_runner_sheet.png",
		"accent": Color(0.95, 0.68, 0.28)
	}
}


static func get_tower(id: String) -> Dictionary:
	if not TOWERS.has(id):
		push_error("Unknown tower id: %s" % id)
		return {}
	return (TOWERS[id] as Dictionary).duplicate(true)


static func get_enemy(id: String) -> Dictionary:
	if not ENEMIES.has(id):
		push_error("Unknown enemy id: %s" % id)
		return {}
	return (ENEMIES[id] as Dictionary).duplicate(true)
