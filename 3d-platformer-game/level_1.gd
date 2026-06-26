extends Node3D

@onready var CutSceneAnim = $CutScene
var changing_level := false

func _ready() -> void:
	# Inicia a música de fundo da fase
	AudioManager.play_music(AudioManager.music_level)
	
	Global.roses = 0
	Global.hearts = 3
	Global.level = 1
	
	CutSceneAnim.play("Intro")
	
func _process(_delta: float) -> void:
	if Global.roses >= Global.NUM_ROSES_TO_WIN and not changing_level:
		changing_level = true
		
		# Toca o efeito sonoro de vitória do nível
		AudioManager.play_sfx(AudioManager.sfx_level_win)
		
		Global.level = 2
		Global.next_scene_path = "res://level_2.tscn"
		get_tree().change_scene_to_file("res://loading_screen_level.tscn")
