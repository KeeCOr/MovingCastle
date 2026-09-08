# scenes/ui/MetaScreen.gd
extends Control

const UPGRADE_PATHS = [
	"res://resources/meta_upgrades/slot_expand.tres",
	"res://resources/meta_upgrades/hp_up.tres",
	"res://resources/meta_upgrades/start_gold.tres",
	"res://resources/meta_upgrades/hero_level.tres",
	"res://resources/meta_upgrades/xp_bonus.tres",
	"res://resources/meta_upgrades/fac_discount.tres",
]

@onready var gold_label: Label = $VBoxContainer/GoldLabel
@onready var upgrade_list: VBoxContainer = $VBoxContainer/ScrollContainer/UpgradeList
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn"))
	var icon := TextureRect.new()
	icon.texture = preload("res://assets/ui/resource_icons/gold.png")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(24, 24)
	icon.position = Vector2(-28, 0)
	icon.size = Vector2(24, 24)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gold_label.add_child(icon)
	_build_list()

func _build_list() -> void:
	gold_label.text = "%d" % SaveData.total_gold
	for child in upgrade_list.get_children():
		child.queue_free()
	for path in UPGRADE_PATHS:
		var data = load(path) as MetaUpgradeData
		if not data:
			continue
		var current_level = SaveData.get_upgrade_level(data.id)
		var hbox = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = "%s  Lv.%d/%d  (비용: %d골드)" % [data.display_name, current_level, data.max_level, data.cost]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var btn = Button.new()
		btn.text = "업그레이드"
		btn.disabled = current_level >= data.max_level or SaveData.total_gold < data.cost
		btn.pressed.connect(_on_upgrade.bind(data))
		hbox.add_child(lbl)
		hbox.add_child(btn)
		upgrade_list.add_child(hbox)

func _on_upgrade(data: MetaUpgradeData) -> void:
	if SaveData.try_upgrade(data.id, data.cost, data.max_level):
		_build_list()
