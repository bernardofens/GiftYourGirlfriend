extends Control

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	# Conecta o sinal de quando o vídeo termina para avançar de cena
	if video_player:
		video_player.finished.connect(_on_video_finished)

func _input(event: InputEvent) -> void:
	# Permite que o jogador pule a cutscene pressionando Esc, Enter ou Espaço
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_on_video_finished()

func _on_video_finished() -> void:
	# Para o vídeo caso o jogador tenha pulado
	if video_player.is_playing():
		video_player.stop()
		
	# Define o próximo destino como Level 1 e chama a tela de loading
	Global.next_scene_path = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")
