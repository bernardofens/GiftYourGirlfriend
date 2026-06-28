extends Node

var bgm_player: AudioStreamPlayer
var step_player: AudioStreamPlayer
var npc_player: AudioStreamPlayer
var sfx_player_pool: Array[AudioStreamPlayer] = []
var max_sfx_channels := 8

var music_volume_db := 0.0
var sfx_volume_db := 0.0

var music_menu = preload("res://Assets/Audio/music_menu.ogg")
var music_level = preload("res://Assets/Audio/music_level.ogg")
var music_game_over = preload("res://Assets/Audio/music_game_over.ogg")
var music_game_win = preload("res://Assets/Audio/music_game_win.ogg")

var sfx_jump = preload("res://Assets/Audio/sfx_jump.wav")
var sfx_walk = preload("res://Assets/Audio/sfx_walk.wav")
var sfx_damage_taken = preload("res://Assets/Audio/sfx_damage_taken.wav")
var sfx_damage_dealt = preload("res://Assets/Audio/sfx_damage_dealt.wav")
var sfx_shoot = preload("res://Assets/Audio/sfx_shoot.wav")
var sfx_collect = preload("res://Assets/Audio/sfx_collect.wav")
var sfx_level_win = preload("res://Assets/Audio/sfx_level_win.wav")
var sfx_npc = preload("res://Assets/Audio/npc-sfx.ogg")

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(bgm_player)
	
	step_player = AudioStreamPlayer.new()
	add_child(step_player)
	
	npc_player = AudioStreamPlayer.new()
	add_child(npc_player)
	
	for i in range(max_sfx_channels):
		var player = AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		sfx_player_pool.append(player)
		

func play_npc_voice(stream: AudioStream, volume_db: float = 0.0) -> void:
	npc_player.stream = stream
	npc_player.volume_db = volume_db + sfx_volume_db
	npc_player.play()

func stop_npc_voice() -> void:
	npc_player.stop()

func play_npc_sfx(volume_db: float = 0.0) -> void:
	# Usamos o pool genérico aqui, pois sons de diálogo não precisam de "stop" imediato
	play_sfx(sfx_npc, volume_db)

# Nova função para tocar passos
func play_step(stream: AudioStream, volume_db: float = 0.0) -> void:
	step_player.stream = stream
	step_player.volume_db = volume_db + sfx_volume_db
	step_player.play()

# Nova função para parar passos imediatamente
func stop_step() -> void:
	step_player.stop()

func set_music_volume(percentage: float) -> void:
	if percentage <= 0.01:
		music_volume_db = -80.0
	else:
		music_volume_db = linear_to_db(percentage / 100.0)
	
	if bgm_player:
		bgm_player.volume_db = music_volume_db

func set_sfx_volume(percentage: float) -> void:
	if percentage <= 0.01:
		sfx_volume_db = -80.0
	else:
		sfx_volume_db = linear_to_db(percentage / 100.0)

	for player in sfx_player_pool:
		player.volume_db = sfx_volume_db

func play_music(stream: AudioStream) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stop()
	bgm_player.stream = stream
	bgm_player.volume_db = music_volume_db
	bgm_player.play()

func play_sfx(stream: AudioStream, base_volume_db: float = 0.0) -> void:
	var target_vol = base_volume_db + sfx_volume_db
	if target_vol <= -79.0:
		return
		
	for player in sfx_player_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = target_vol
			player.play()
			return
			
	sfx_player_pool[0].stream = stream
	sfx_player_pool[0].volume_db = target_vol
	sfx_player_pool[0].play()
