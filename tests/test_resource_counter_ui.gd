# tests/test_resource_counter_ui.gd
extends GutTest

const GOLD_ICON_PATH := "res://assets/ui/resource_icons/gold.png"

func test_gold_icon_asset_exists() -> void:
	assert_true(ResourceLoader.exists(GOLD_ICON_PATH), "Gold counters must use the shipped PNG icon")

func test_hud_counter_is_icon_and_number_without_gold_text() -> void:
	var scene_text := FileAccess.get_file_as_string("res://scenes/ui/HUD.tscn")
	assert_string_contains(scene_text, "resource_icons/gold.png")
	assert_string_contains(scene_text, "GoldCounter")
	assert_false(scene_text.contains("Gold: 0"))

func test_result_reward_is_icon_and_signed_number() -> void:
	var scene_text := FileAccess.get_file_as_string("res://scenes/ui/ResultScreen.tscn")
	var script_text := FileAccess.get_file_as_string("res://scenes/ui/ResultScreen.gd")
	assert_string_contains(scene_text, "resource_icons/gold.png")
	assert_string_contains(script_text, "gold_label.text = \"+%d\"")
	assert_false(script_text.contains("Gold +%d"))

func test_meta_screen_uses_icon_for_balance_and_cost() -> void:
	var scene_text := FileAccess.get_file_as_string("res://scenes/ui/MetaScreen.tscn")
	var script_text := FileAccess.get_file_as_string("res://scenes/ui/MetaScreen.gd")
	assert_string_contains(scene_text, "GoldRow")
	assert_string_contains(scene_text, "resource_icons/gold.png")
	assert_string_contains(script_text, "var cost_row := HBoxContainer.new()")
	assert_string_contains(script_text, "cost_label.text = \"%d\"")
