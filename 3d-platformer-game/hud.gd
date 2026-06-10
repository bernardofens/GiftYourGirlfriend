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
@onready var win_screen = $Control/GameWinControl # Caminho atualizado para o novo nó

# --- BOTÕES ---
@onready var try_again_btn = $Control/GameOverControl/TryAgainButton
@onready var quit_btn = $Control/GameOverControl/QuitButton

@onready var resume_btn = $Control/PauseControl/ResumeButton 
@onready var pause_quit_btn = $Control/PauseControl/QuitButton 

@onready var win_restart_btn = $Control/GameWinControl/RestartButton # Novo botão da tela de vitória
@onready var win_quit_btn = $Control/GameWinControl/QuitButton # Novo botão da tela de vitória

# --- TEXTURAS ---
var full_heart = preload("res://Assets/Images/heart-gyg.png")
var empty_heart = preload("res://Assets/Images/heartless-gyg.png")

var rose_tex = preload("res://Assets/Images/rose.png") 
var chocolate_tex = preload("res://Assets/Images/chocolate.webp") 

# --- VARIÁVEIS DE CONTROLE ---
var game_won := false

func _ready() -> void:
	# Garante que as telas estejam invisíveis ao iniciar
	game_over.visible = false
	if win_screen: win_screen.visible = false
	if pause_control: pause_control.visible = false
	
	var player = get_tree().get_first_node_in_group("Steve")
	if player:
		player.player_died.connect(_on_player_died)
		
	if stamina_bar:
		stamina_bar.max_value = Global.max_stamina
		
	# Conexões de botões Game Over
	if try_again_btn: try_again_btn.pressed.connect(_on_retry_button_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_button_pressed)
	
	# Conexões de botões Pause
	if pause_button: pause_button.pressed.connect(toggle_pause)
	if resume_btn: resume_btn.pressed.connect(toggle_pause)
	if pause_quit_btn: pause_quit_btn.pressed.connect(_on_quit_button_pressed)
		
	# Conexões de botões Game Win
	if win_restart_btn: win_restart_btn.pressed.connect(_on_win_restart_pressed)
	if win_quit_btn: win_quit_btn.pressed.connect(_on_quit_button_pressed)

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
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over.visible = true
	
	_hide_hud_elements()
	get_tree().paused = true

func show_win_screen():
	game_won = true
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
	# Reinicia o nível atual
	Global.hearts = 3
	Global.chocolates = 0
	Global.roses = 0
	Global.can_take_damage = true
	get_tree().paused = false
	game_won = false
	
	# Direciona para a tela de loading correspondente ao nível atual
	if Global.level == 1:
		Global.next_scene_path = "res://level_1.tscn"
	else:
		Global.next_scene_path = "res://level_2.tscn"
		
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_win_restart_pressed():
	# Zera o jogo e força o retorno para o Nível 1
	Global.hearts = 3
	Global.chocolates = 0
	Global.roses = 0
	Global.level = 1
	Global.can_take_damage = true
	get_tree().paused = false
	game_won = false
	
	# Salva a rota do Nível 1 e vai para a tela de loading
	Global.next_scene_path = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_quit_button_pressed():
	# É obrigatório despausar o jogo antes de sair
	get_tree().paused = false
	
	# Salva a rota do Menu e vai para a tela de loading
	# (É bom usar o loading para voltar ao menu principal pois limpa a memória do mundo 3D de forma suave)
	Global.next_scene_path = "res://menu.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _process(delta: float) -> void:
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
