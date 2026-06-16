extends CanvasLayer

# --- PAINEL PRINCIPAL (ITENS) ---
@onready var item_panel = $Control/RosesPanel
@onready var item_icon = $Control/RosesPanel/TextureRect 
@onready var item_label = $Control/RosesPanel/Label 

# --- OUTROS NÓS ---
@onready var heart3 = $Control/Healthbar/Heart3
@onready var heart2 = $Control/Healthbar/Heart2
@onready var heart1 = $Control/Healthbar/Heart1
@onready var health_bar = $Control/Healthbar
@onready var stamina_bar = $Control/StaminaBar 
@onready var stamina = $Control/Stamina
@onready var pause_button = $Control/PauseButton

# --- TELAS DE ESTADO ---
@onready var game_over = $Control/GameOverControl
@onready var pause_control = $Control/PauseControl 
@onready var win_screen = $Control/GameWinControl

# --- BOTÕES ---
@onready var try_again_btn = $Control/GameOverControl/TryAgainButton
@onready var quit_btn = $Control/GameOverControl/QuitButton
@onready var pause_quit_btn = $Control/PauseControl/QuitButton 
@onready var win_restart_btn = $Control/GameWinControl/TryAgainButton 
@onready var win_quit_btn = $Control/GameWinControl/QuitButton
@onready var resume_btn: TextureButton = $Control/PauseControl/TryAgainButton

# --- REFERÊNCIAS DE ÁUDIO NO PAUSE ---
@onready var music_slider = $Control/PauseControl/MusicSlider
@onready var music_mute_check = $Control/PauseControl/MusicMuteCheck
@onready var sfx_slider = $Control/PauseControl/SfxSlider
@onready var sfx_mute_check = $Control/PauseControl/SfxMuteCheck

# --- TEXTURAS ---
var full_heart = preload("res://Assets/Images/heart-gyg.png")
var empty_heart = preload("res://Assets/Images/heartless-gyg.png")
var rose_tex = preload("res://Assets/Images/rose.png") 
var chocolate_tex = preload("res://Assets/Images/chocolate.webp") 

var game_won := false

# --- VARIÁVEIS DE FEEDBACK DE DANO ---
var previous_hearts: int = 3
var original_control_pos: Vector2
var damage_overlay: ColorRect
var shake_tween: Tween

func _ready() -> void:
	game_over.visible = false
	if win_screen: win_screen.visible = false
	if pause_control: pause_control.visible = false
	
	var player = get_tree().get_first_node_in_group("Steve")
	if player:
		player.player_died.connect(_on_player_died)
		
	if stamina_bar:
		stamina_bar.max_value = Global.max_stamina
		
	if try_again_btn: try_again_btn.pressed.connect(_on_retry_button_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_button_pressed)
	if pause_button: pause_button.pressed.connect(toggle_pause)
	if resume_btn: resume_btn.pressed.connect(toggle_pause)
	if pause_quit_btn: pause_quit_btn.pressed.connect(_on_quit_button_pressed)
	if win_restart_btn: win_restart_btn.pressed.connect(_on_win_restart_pressed)
	if win_quit_btn: win_quit_btn.pressed.connect(_on_quit_button_pressed)

	if music_slider: music_slider.value_changed.connect(_on_music_slider_changed)
	if music_mute_check: music_mute_check.toggled.connect(_on_music_mute_toggled)
	if sfx_slider: sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	if sfx_mute_check: sfx_mute_check.toggled.connect(_on_sfx_mute_toggled)
	
	_setup_damage_feedback()

# --- CONFIGURA O FEEDBACK VISUAL DE DANO ---
func _setup_damage_feedback() -> void:
	# Guarda a posição original do Control para o Shake
	original_control_pos = $Control.position
	
	# Cria um overlay vermelho dinamicamente para o "flash" de dano
	damage_overlay = ColorRect.new()
	damage_overlay.color = Color(0.8, 0.0, 0.0, 0.0) # Vermelho transparente
	damage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT) # Cobre a tela toda
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE # Não bloqueia cliques
	add_child(damage_overlay)
	move_child(damage_overlay, 0) # Coloca atrás do $Control, mas na frente do jogo

func trigger_damage_effect() -> void:
	# 1. Efeito de Flash (Vermelho na tela)
	var flash_tween = create_tween()
	damage_overlay.color.a = 0.35 # Fica vermelho
	flash_tween.tween_property(damage_overlay, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE) # Esmaece suavemente
	
	# 2. Efeito de Shake do HUD
	if shake_tween and shake_tween.is_running():
		shake_tween.kill() # Para o shake anterior se tomar dano rápido demais
		
	shake_tween = create_tween()
	var shakes = 6
	var shake_strength = 15.0 # Intensidade do tremor em pixels
	
	for i in range(shakes):
		var random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * shake_strength
		shake_tween.tween_property($Control, "position", original_control_pos + random_offset, 0.04)
		shake_strength *= 0.6 # O tremor vai diminuindo de intensidade
		
	# Retorna o HUD para a posição exata de origem no final
	shake_tween.tween_property($Control, "position", original_control_pos, 0.05)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not game_over.visible and not game_won:
		toggle_pause()

func toggle_pause():
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	
	if pause_control:
		pause_control.visible = is_paused
	
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 

func _on_player_died():
	if game_won: return 
	
	AudioManager.play_music(AudioManager.music_game_over)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over.visible = true
	
	_hide_hud_elements()
	get_tree().paused = true

func show_win_screen():
	game_won = true
	AudioManager.play_music(AudioManager.music_game_win)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	win_screen.visible = true
	
	_hide_hud_elements()
	get_tree().paused = true

func _hide_hud_elements():
	if item_panel: item_panel.visible = false
	if stamina_bar: stamina_bar.visible = false
	if health_bar: health_bar.visible = false
	if pause_button: pause_button.visible = false
	if stamina: stamina.visible = false

func _on_retry_button_pressed():
	Global.hearts = 3
	Global.chocolates = 0
	Global.roses = 0
	Global.can_take_damage = true
	get_tree().paused = false
	game_won = false
	
	if Global.level == 1:
		Global.next_scene_path = "res://level_1.tscn"
	else:
		Global.next_scene_path = "res://level_2.tscn"
		
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_win_restart_pressed():
	Global.hearts = 3
	Global.chocolates = 0
	Global.roses = 0
	Global.level = 1
	Global.can_take_damage = true
	get_tree().paused = false
	game_won = false
	
	Global.next_scene_path = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_quit_button_pressed():
	get_tree().paused = false
	Global.next_scene_path = "res://menu.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

# --- SINAIS DE CONFIGURAÇÃO DE ÁUDIO COM SINCRONIZAÇÃO NO PAUSE ---

func _on_music_slider_changed(value: float) -> void:
	if AudioManager:
		AudioManager.set_music_volume(value)
	if music_mute_check:
		music_mute_check.set_pressed_no_signal(value >= 100.0)

func _on_music_mute_toggled(is_button_pressed: bool) -> void:
	var target_volume = 100.0 if is_button_pressed else 0.0
	if music_slider:
		music_slider.set_value_no_signal(target_volume)
	if AudioManager:
		AudioManager.set_music_volume(target_volume)

func _on_sfx_slider_changed(value: float) -> void:
	if AudioManager:
		AudioManager.set_sfx_volume(value)
	if sfx_mute_check:
		sfx_mute_check.set_pressed_no_signal(value >= 100.0)

func _on_sfx_mute_toggled(is_button_pressed: bool) -> void:
	var target_volume = 100.0 if is_button_pressed else 0.0
	if sfx_slider:
		sfx_slider.set_value_no_signal(target_volume)
	if AudioManager:
		AudioManager.set_sfx_volume(target_volume)

func _process(delta: float) -> void:
	# DETECTA DANO: Se a vida for menor que no frame anterior, treme a tela
	if Global.hearts < previous_hearts:
		trigger_damage_effect()
	previous_hearts = Global.hearts # Atualiza o rastreador
	
	
	if Global.level == 1:
		item_icon.texture = rose_tex
		item_label.text = "x " + str(Global.roses)
	elif Global.level == 2:
		item_icon.texture = chocolate_tex
		item_label.text = "x " + str(Global.chocolates)
		
		if Global.chocolates >= 5 and not game_won:
			show_win_screen()
	
	stamina_bar.value = Global.stamina
		
	if Global.hearts >= 1:
		heart1.texture = full_heart
	else:
		heart1.texture = empty_heart
		
	if Global.hearts >= 2:
		heart2.texture = full_heart
	else:
		heart2.texture = empty_heart
		
	if Global.hearts >= 3:
		heart3.texture = full_heart
	else:
		heart3.texture = empty_heart
