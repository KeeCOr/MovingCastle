# autoloads/GameState.gd
extends Node

# 런 상태
var current_stage: int = 1
var current_wave: int = 0
var castle_hp: float = 100.0
var castle_max_hp: float = 100.0
var xp: float = 0.0
var xp_to_next_level: float = 10.0
var level: int = 1
var gold: int = 0

# 슬롯 상태: [{unit_data: HeroData/FacilityData or null, unit_node: Node or null}]
var slot_count: int = 3
var slots: Array = []

# 선택지 풀
var hero_pool: Array[HeroData] = []
var facility_pool: Array[FacilityData] = []

signal level_up_triggered(choices: Array)
signal castle_died()
signal wave_cleared(wave_number: int)
signal stage_cleared(stage_number: int, gold_reward: int)

func _ready() -> void:
	SaveData.load_save()
	_apply_meta_upgrades()

func reset_run() -> void:
	current_wave = 0
	castle_hp = castle_max_hp
	xp = 0.0
	xp_to_next_level = 10.0
	level = 1
	gold = int(SaveData.get_upgrade_value("start_gold"))
	slots.clear()
	for i in slot_count:
		slots.append({unit_data = null, unit_node = null})

func gain_xp(amount: float) -> void:
	var bonus = 1.0 + SaveData.get_upgrade_value("xp_bonus") * 0.1
	xp += amount * bonus
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		xp_to_next_level = floor(xp_to_next_level * 1.2)
		level += 1
		emit_signal("level_up_triggered", _get_levelup_choices())

func take_castle_damage(amount: float) -> void:
	castle_hp = max(0.0, castle_hp - amount)
	AudioDirector.play_cue(&"danger")
	if castle_hp <= 0.0:
		AudioDirector.play_cue(&"result")
		emit_signal("castle_died")

func heal_castle(amount: float) -> void:
	castle_hp = min(castle_max_hp, castle_hp + amount)

func _get_levelup_choices() -> Array:
	var all: Array = []
	all.append_array(hero_pool)
	all.append_array(facility_pool)
	all.shuffle()
	return all.slice(0, 3)

func _apply_meta_upgrades() -> void:
	slot_count = 3 + int(SaveData.get_upgrade_value("slot_count"))
	castle_max_hp = 100.0 + SaveData.get_upgrade_value("max_hp") * 10.0
