extends Node3D

var changing_level := false

func _ready() -> void:
	Global.roses = 0
	Global.hearts = 3
	Global.level = 1

func _process(_delta: float) -> void:
	# Verifica se pegou as rosas e se já não está mudando de level
	if Global.roses >= Global.NUM_ROSES_TO_WIN and not changing_level:
		changing_level = true
		
		# Prepara as variáveis para o Level 2
		Global.level = 2 
		Global.next_scene_path = "res://level_2.tscn"
		
		# Chama a nova cena de loading personalizada!
		get_tree().change_scene_to_file("res://loading_screen_level.tscn")
