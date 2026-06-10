extends Node3D

# Variável de controle para não carregar a cena repetidas vezes
var changing_level := false

func _ready() -> void:
	Global.roses = 0
	Global.hearts = 3
	Global.level = 1 # Garante que o HUD saiba que estamos no nível 1

func _process(delta: float) -> void:
	# Verifica se pegou todas as rosas e se a transição ainda não começou
	if Global.roses >= Global.NUM_ROSES_TO_WIN and not changing_level:
		changing_level = true
		
		# Atualiza o nível global para o HUD mudar os ícones
		Global.level = 2 
		
		# Define o Nível 2 como destino
		Global.next_scene_path = "res://level_2.tscn"
		
		# Chama a sua SEGUNDA tela de loading (a nova que criamos)
		get_tree().change_scene_to_file("res://loading_screen_level.tscn")
