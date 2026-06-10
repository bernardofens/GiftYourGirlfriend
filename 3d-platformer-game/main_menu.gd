extends Control

@onready var title_logo = $TitleLogo
@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton # Nova referência

func _ready() -> void:
	title_logo.scale = Vector2.ZERO 
	play_button.modulate.a = 0.0 
	
	if quit_button:
		quit_button.modulate.a = 0.0 # Esconde o botão quit também
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed) # Conecta o novo botão
		
	animate_menu_entrance()

func animate_menu_entrance() -> void:
	var tween = create_tween()
	
	tween.tween_property(title_logo, "scale", Vector2(1, 1), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Anima o botão de Play
	tween.tween_property(play_button, "modulate:a", 1.0, 0.5)
	
	# Usa o parallel() para fazer o botão Quit aparecer exatamente ao mesmo tempo que o Play
	if quit_button:
		tween.parallel().tween_property(quit_button, "modulate:a", 1.0, 0.5)

func _on_play_pressed() -> void:
	Global.next_scene_path = "res://level_1.tscn" # Usando Global
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_quit_pressed() -> void:
	# Fecha o jogo definitivamente
	get_tree().quit()
