extends Node

const BGM_PATH := "res://assets/audio/original/bgm-loop.ogg"
const SFX_PATHS := {
	&"ui": "res://assets/audio/original/sfx-ui.ogg",
	&"action": "res://assets/audio/original/sfx-action.ogg",
	&"danger": "res://assets/audio/original/sfx-danger.ogg",
	&"transition": "res://assets/audio/original/sfx-transition.ogg",
	&"result": "res://assets/audio/original/sfx-result.ogg",
}
const SFX_POOL_SIZE := 6
const DUCK_FACTOR := 0.55
const DANGER_DUCK_SECONDS := 1.0
const RESULT_DUCK_SECONDS := 0.8

var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var _bgm_volume := 0.24
var _sfx_volume := 0.62
var _muted := false
var _bgm_started := false
var _sfx_streams := {}
var _sfx_cursor := 0
var _duck_until_msec := 0
var _duck_timer_running := false

var muted: bool:
	get: return _muted
	set(value): _muted = value; _apply_volumes()
var bgm_volume: float:
	get: return _bgm_volume
	set(value): _bgm_volume = clamp_mix(value); _apply_volumes()
var sfx_volume: float:
	get: return _sfx_volume
	set(value): _sfx_volume = clamp_mix(value); _apply_volumes()

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	for index in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % index
		sfx_players.append(player)
		add_child(player)
	var bgm_stream = load(BGM_PATH)
	if bgm_stream is AudioStream: bgm_player.stream = bgm_stream
	for cue_name in SFX_PATHS:
		var stream = load(SFX_PATHS[cue_name])
		if stream is AudioStream: _sfx_streams[cue_name] = stream
	bgm_player.finished.connect(_on_bgm_finished)
	_apply_volumes()

func _input(event: InputEvent) -> void:
	if not _bgm_started and (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		_start_bgm()

func _start_bgm() -> void:
	if _bgm_started or bgm_player.stream == null: return
	_bgm_started = true
	bgm_player.play()

func _on_bgm_finished() -> void:
	if _bgm_started and bgm_player.stream != null: bgm_player.play()

func play_cue(cue: StringName) -> void:
	if not _sfx_streams.has(cue): return
	var player := _next_sfx_player()
	player.stream = _sfx_streams[cue]
	player.volume_db = linear_to_db(effective_volume(_sfx_volume, _muted))
	player.play()
	var duck_seconds := duck_duration(cue)
	if duck_seconds > 0.0:
		duck_seconds = maxf(duck_seconds, float(player.stream.get_length()))
		_request_duck(duck_seconds)

func _next_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing: return player
	var player := sfx_players[_sfx_cursor]
	_sfx_cursor = (_sfx_cursor + 1) % sfx_players.size()
	return player

func _apply_volumes() -> void:
	if bgm_player != null:
		var ducked := _duck_timer_running
		bgm_player.volume_db = linear_to_db(ducked_volume(_bgm_volume, _muted, ducked))
	for player in sfx_players:
		player.volume_db = linear_to_db(effective_volume(_sfx_volume, _muted))

func _request_duck(duration_seconds: float) -> void:
	_duck_until_msec = extend_duck_deadline(_duck_until_msec, Time.get_ticks_msec(), int(ceil(duration_seconds * 1000.0)))
	if not _duck_timer_running: _run_duck_timer()
	_apply_volumes()

func _run_duck_timer() -> void:
	_duck_timer_running = true
	_apply_volumes()
	while Time.get_ticks_msec() < _duck_until_msec:
		await get_tree().process_frame
	_duck_timer_running = false
	_apply_volumes()

static func clamp_mix(value: float) -> float: return clampf(value, 0.0, 1.0)
static func effective_volume(volume: float, is_muted: bool) -> float: return 0.0 if is_muted else clamp_mix(volume)
static func ducked_volume(volume: float, is_muted: bool, is_ducked: bool) -> float:
	return effective_volume(volume, is_muted) * (DUCK_FACTOR if is_ducked else 1.0)
static func duck_duration(cue: StringName) -> float:
	if cue == &"danger": return DANGER_DUCK_SECONDS
	if cue == &"result": return RESULT_DUCK_SECONDS
	return 0.0
static func extend_duck_deadline(current_deadline: int, now_msec: int, duration_msec: int) -> int:
	return maxi(current_deadline, now_msec + maxi(0, duration_msec))
