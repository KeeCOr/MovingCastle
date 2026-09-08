# scenes/ui/HUD.gd
class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $StatsPanel/HPBar
@onready var hp_label: Label = $StatsPanel/HPLabel
@onready var xp_bar: ProgressBar = $StatsPanel/XPBar
@onready var level_label: Label = $StatsPanel/LevelLabel
@onready var wave_label: Label = $WaveLabel
@onready var gold_label: Label = $GoldLabel

func _ready() -> void:
	_attach_gold_icon(gold_label)

func _attach_gold_icon(label: Label) -> void:
	var icon := TextureRect.new()
	icon.texture = preload("res://assets/ui/resource_icons/gold.png")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(24, 24)
	icon.position = Vector2(-28, 0)
	icon.size = Vector2(24, 24)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_child(icon)

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
