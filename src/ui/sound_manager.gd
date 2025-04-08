extends Node

var audio_stream_players_2d : Array[AudioStreamPlayer2D] = []
var audio_stream_players : Array[AudioStreamPlayer]


func get_player_2d() -> AudioStreamPlayer2D:
	if audio_stream_players_2d.is_empty():
		var player := AudioStreamPlayer2D.new()
		player.finished.connect(on_stream_finished_2d.bind(player))
		player.bus = Settings.sound_bus_name
		self.add_child(player)
		return player
	return audio_stream_players_2d.pop_back()


func on_stream_finished_2d(player: AudioStreamPlayer2D):
	audio_stream_players_2d.append(player)


func get_player() -> AudioStreamPlayer:
	if audio_stream_players.is_empty():
		var player := AudioStreamPlayer.new()
		player.finished.connect(on_stream_finished.bind(player))
		player.bus = Settings.sound_bus_name
		self.add_child(player)
		return player
	return audio_stream_players.pop_back()


func on_stream_finished(player: AudioStreamPlayer):
	audio_stream_players.append(player)


func play_sound_2d(pos: Vector2, sound: AudioStream, pitch_variance: float = 0.0, volume_db: float = 0.0):
	var pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	var player : AudioStreamPlayer2D = get_player_2d()
	player.stream = sound
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.global_position = pos
	player.play()


func play_sound(sound: AudioStream, pitch_variance: float = 0.0, volume_db: float = 0.0):
	var pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	var player : AudioStreamPlayer = get_player()
	player.stream = sound
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.play()
