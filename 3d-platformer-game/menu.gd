extends Control

@onready var title_logo = $TitleLogo
@onready var play_button = $PlayButton

func _ready() -> void:
	# 1. Prepara os elementos escondendo-os no primeiro frame
	title_logo.scale = Vector2.ZERO # Encolhe o logo para tamanho 0
	play_button.modulate.a = 0.0 # Deixa o botão de play invisível (alfa 0)
	
	# 2. Conecta o clique do botão à função de iniciar
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
		
	# 3. Chama a função que cria a animação de entrada
	animate_menu_entrance()

func animate_menu_entrance() -> void:
	# Cria um Tween (animador via código)
	var tween = create_tween()
	
	# Anima o logo crescendo até o tamanho original (Vector2(1,1)) em 1 segundo
	# O TRANS_ELASTIC e EASE_OUT criam o efeito de "pulo" divertido
	tween.tween_property(title_logo, "scale", Vector2(1, 1), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Depois do logo pular, faz o botão de Play aparecer suavemente (fade in) em 0.5 segundos
	tween.tween_property(play_button, "modulate:a", 1.0, 0.5)

func _on_play_pressed() -> void:
	# Transição para o Nível 1
	get_tree().change_scene_to_file("res://level_1.tscn")
