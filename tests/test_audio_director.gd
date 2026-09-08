extends GutTest

const AudioDirectorScript = preload("res://autoloads/AudioDirector.gd")

func test_clamps_mix_values() -> void:
	assert_eq(AudioDirectorScript.clamp_mix(4.0), 1.0)
	assert_eq(AudioDirectorScript.clamp_mix(-2.0), 0.0)

func test_keeps_channels_independent() -> void:
	assert_eq(AudioDirectorScript.effective_volume(0.24, false), 0.24)
	assert_eq(AudioDirectorScript.effective_volume(0.62, false), 0.62)

func test_muting_silences_a_channel() -> void:
	assert_eq(AudioDirectorScript.effective_volume(0.62, true), 0.0)

func test_danger_and_result_use_required_duck_windows() -> void:
	assert_eq(AudioDirectorScript.duck_duration(&"danger"), 1.0)
	assert_eq(AudioDirectorScript.duck_duration(&"result"), 0.8)
	assert_eq(AudioDirectorScript.duck_duration(&"action"), 0.0)

func test_ducking_applies_one_gain_stage() -> void:
	assert_almost_eq(AudioDirectorScript.ducked_volume(0.8, false, true), 0.44, 0.0001)
	assert_eq(AudioDirectorScript.ducked_volume(0.8, true, true), 0.0)

func test_overlapping_duck_requests_extend_the_deadline() -> void:
	assert_eq(AudioDirectorScript.extend_duck_deadline(11_000, 10_500, 800), 11_300)
	assert_eq(AudioDirectorScript.extend_duck_deadline(11_300, 10_600, 200), 11_300)
