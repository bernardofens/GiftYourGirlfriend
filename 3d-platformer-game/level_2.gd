extends Node3D

func _ready() -> void:
	# Garante que a música da fase esteja tocando
	AudioManager.play_music(AudioManager.music_level)
	
	Global.level = 2
	Global.chocolates = 0
	Global.hearts = 3 

func _process(_delta: float) -> void:
	pass
