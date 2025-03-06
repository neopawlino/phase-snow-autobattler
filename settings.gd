extends Node

var config : ConfigFile = ConfigFile.new()
const CONFIG_FILE_PATH : String = "user://settings.cfg"
const SECTION : String = "Settings"


var master_bus_name := &"Master"
@onready var master_bus := AudioServer.get_bus_index(master_bus_name)
const MASTER_VOLUME : String = "master_volume"

var music_bus_name := &"Music"
@onready var music_bus := AudioServer.get_bus_index(music_bus_name)
const MUSIC_VOLUME : String = "music_volume"

var sound_bus_name := &"Sound"
@onready var sound_bus := AudioServer.get_bus_index(sound_bus_name)
const SOUND_VOLUME : String = "sound_volume"

const HARD_MODE := "hard_mode"


func _ready() -> void:
	config.load(CONFIG_FILE_PATH)
	load_volume()
	load_game_settings()


func load_volume() -> void:
	var master_vol = get_master_volume()
	set_master_volume(master_vol)
	var music_vol = get_music_volume()
	set_music_volume(music_vol)
	var sound_vol = get_sound_volume()
	set_sound_volume(sound_vol)


func load_game_settings() -> void:
	var hard_mode = get_value(HARD_MODE, false)
	set_hard_mode(hard_mode)


func set_hard_mode(hard_mode : bool):
	config.set_value(SECTION, HARD_MODE, hard_mode)
	GameState.hard_mode = hard_mode


func get_value(key : String, default = null):
	return config.get_value(SECTION, key, default)


func set_value(key : String, value):
	config.set_value(SECTION, key, value)


func get_master_volume():
	return get_value(MASTER_VOLUME, 0.1)


func get_music_volume():
	return get_value(MUSIC_VOLUME, 1.0)


func get_sound_volume():
	return get_value(SOUND_VOLUME, 1.0)


func set_master_volume(value: float) -> void:
	set_value(MASTER_VOLUME, value)
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))


func set_music_volume(value: float) -> void:
	set_value(MUSIC_VOLUME, value)
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))


func set_sound_volume(value : float) -> void:
	set_value(SOUND_VOLUME, value)
	AudioServer.set_bus_volume_db(sound_bus, linear_to_db(value))


func _exit_tree() -> void:
	config.save(CONFIG_FILE_PATH)
