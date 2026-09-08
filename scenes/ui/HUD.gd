# scenes/ui/HUD.gd
class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $StatsPanel/HPBar
@onready var hp_label: Label = $StatsPanel/HPLabel
@onready var xp_bar: ProgressBar = $StatsPanel/XPBar
@onready var level_label: Label = $StatsPanel/LevelLabel
@onready var wave_label: Label = $WaveLabel
@onready var gold_label: Label = $GoldCounter/GoldLabel

func _process(_delta: float) -> void:
	hp_bar.max_value = GameState.castle_max_hp
	hp_bar.value = GameState.castle_hp
	hp_label.text = "%d / %d" % [int(GameState.castle_hp), int(GameState.castle_max_hp)]
	xp_bar.max_value = GameState.xp_to_next_level
	xp_bar.value = GameState.xp
	level_label.text = "Lv. %d" % GameState.level
	gold_label.text = "%d" % GameState.gold

func set_wave(wave_number: int, total_waves: int) -> void:
	wave_label.text = "Wave %d / %d" % [wave_number, total_waves]
