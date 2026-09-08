# scenes/ui/ResultScreen.gd
extends CanvasLayer

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var stage_label: Label = $Panel/VBoxContainer/StageLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel
@onready var gold_reward: HBoxContainer = $Panel/VBoxContainer/GoldReward
@onready var gold_label: Label = $Panel/VBoxContainer/GoldReward/AmountLabel
@onready var level_label: Label = $Panel/VBoxContainer/LevelLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton

signal continue_pressed()

func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_on_continue)

func show_victory(stage: int, gold_reward: int) -> void:
	title_label.text = "Stage Clear!"
	stage_label.text = "Stage %d" % stage
	wave_label.text = "All Waves Cleared"
	self.gold_reward.visible = true
	gold_label.text = "+%d" % gold_reward
	level_label.text = "Lv. %d" % GameState.level
	continue_button.text = "Continue"
	visible = true
	get_tree().paused = true

func show_defeat(stage: int, wave_reached: int) -> void:
	title_label.text = "Game Over"
	stage_label.text = "Stage %d" % stage
	wave_label.text = "Wave %d" % wave_reached
	gold_reward.visible = false
	level_label.text = "Lv. %d" % GameState.level
	continue_button.text = "Retry"
	visible = true
	get_tree().paused = true

func _on_continue() -> void:
	get_tree().paused = false
	visible = false
	emit_signal("continue_pressed")
