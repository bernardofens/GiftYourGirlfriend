extends Node

# --- CANAIS DE ÁUDIO ---
var bgm_player: AudioStreamPlayer
var sfx_player_pool: Array[AudioStreamPlayer] = []
var max_sfx_channels := 8

# --- CARREGAMENTO DOS ÁUDIOS (Preload) ---
# Substitua os caminhos abaixo pelos caminhos reais dos seus arquivos de áudio
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

func _ready() -> void:
	# Configura o player de música de fundo
	bgm_player = AudioStreamPlayer.new()
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS # Toca mesmo pausado
	add_child(bgm_player)
	
	# Cria um pool de canais para os efeitos sonoros (permite tocar vários SFX ao mesmo tempo)
	for i in range(max_sfx_channels):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_player_pool.append(player)

# --- FUNÇÕES PARA TOCAR MÚSICA ---
func play_music(stream: AudioStream) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return # Já está tocando a mesma música
	bgm_player.stop()
	bgm_player.stream = stream
	bgm_player.play()

func stop_music() -> void:
	bgm_player.stop()

# --- FUNÇÃO PARA TOCAR EFEITOS SONOROS ---
func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	for player in sfx_player_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db # Aplica o volume desejado
			player.play()
			return
	# Caso todos os canais estejam ocupados
	sfx_player_pool[0].stream = stream
	sfx_player_pool[0].volume_db = volume_db
	sfx_player_pool[0].play()
