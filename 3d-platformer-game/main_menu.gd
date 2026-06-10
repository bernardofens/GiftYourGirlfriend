extends Control

@onready var title_logo = $TitleLogo
@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton

func _ready() -> void:
	# Inicia a música do menu principal
	AudioManager.play_music(AudioManager.music_menu)
	
	title_logo.scale = Vector2.ZERO 
	play_button.modulate.a = 0.0 
	
	if quit_button:
		quit_button.modulate.a = 0.0
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		
	animate_menu_entrance()

func animate_menu_entrance() -> void:
	var tween = create_tween()
	tween.tween_property(title_logo, "scale", Vector2(1, 1), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(play_button, "modulate:a", 1.0, 0.5)
	if quit_button:
		tween.parallel().tween_property(quit_button, "modulate:a", 1.0, 0.5)

func _on_play_pressed() -> void:
	Global.next_scene_path = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
