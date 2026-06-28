extends CanvasLayer

# --- PAINEL PRINCIPAL (ITENS) ---
@onready var item_panel = $Control/RosesPanel
@onready var item_icon = $Control/RosesPanel/TextureRect 
@onready var item_label = $Control/RosesPanel/Label 
@onready var chocolate_panel = $Control.get_node_or_null("ChocolatePanel")

# --- OUTROS NÓS DA UI ---
@onready var heart3 = $Control/Healthbar/Heart3
@onready var heart2 = $Control/Healthbar/Heart2
@onready var heart1 = $Control/Healthbar/Heart1
@onready var health_bar = $Control/Healthbar
@onready var stamina_bar = $Control/StaminaBar 
@onready var stamina = $Control/Stamina

# --- TELAS DE ESTADO (PAINÉIS DE CONTROLE) ---
@onready var game_over = $Control/GameOverControl
@onready var pause_control = $Control/PauseControl 
@onready var win_screen = $Control/GameWinControl

# --- REFERÊNCIAS DO PARALLAX (TELAS DE ESTADO) ---
@onready var parallax_game_over = $Control/GameOverControl/ParallaxBackground
@onready var parallax_game_win = $Control/GameWinControl/ParallaxBackground

# --- BOTÕES ---
@onready var try_again_btn: BaseButton = $Control/GameOverControl/TryAgainButton
@onready var quit_btn: BaseButton = $Control/GameOverControl/QuitButton
@onready var pause_quit_btn: BaseButton = $Control/PauseControl/QuitButton 
@onready var win_restart_btn: BaseButton = $Control/GameWinControl/TryAgainButton 
@onready var win_quit_btn: BaseButton = $Control/GameWinControl/QuitButton
@onready var resume_btn: BaseButton = $Control/PauseControl/TryAgainButton
@onready var pause_button: BaseButton = $Control/PauseButton

# --- REFERÊNCIAS DE ÁUDIO NO PAUSE ---
@onready var music_slider: HSlider = $Control/PauseControl/MusicSlider
@onready var music_mute_check: CheckBox = $Control/PauseControl/MusicMuteCheck
@onready var sfx_slider: HSlider = $Control/PauseControl/SfxSlider
@onready var sfx_mute_check: CheckBox = $Control/PauseControl/SfxMuteCheck

# --- TEXTURAS ---
var full_heart = preload("res://Assets/Images/heart-gyg.png")
var empty_heart = preload("res://Assets/Images/heartless-gyg.png")
var rose_tex = preload("res://Assets/Images/rose.png") 
var chocolate_tex = preload("res://Assets/Images/chocolate.webp") 

# --- VARIÁVEIS DE ESTADO E ANIMAÇÃO ---
var game_won := false

var sway_time_game_over: float = 0.0
var sway_time_game_win: float = 0.0

const SWAY_SPEED: float = 0.5    
const SWAY_AMOUNT_X: float = 35.0 
const SWAY_AMOUNT_Y: float = 15.0 

# --- VARIÁVEIS DE FEEDBACK DE DANO ---
var previous_hearts: int = 3
var original_control_pos: Vector2
var damage_overlay: ColorRect
var shake_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	game_over.visible = false
	if win_screen: win_screen.visible = false
	if pause_control: pause_control.visible = false
	
	# Conecta diretamente ao Viewport, ignorando possíveis limitações de âncora do Control
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	if parallax_game_over: parallax_game_over.visible = false
	if parallax_game_win: parallax_game_win.visible = false
	
	_connect_buttons()

	var player = get_tree().get_first_node_in_group("Steve")
	if player:
		player.player_died.connect(_on_player_died)
		
	if stamina_bar:
		stamina_bar.max_value = Global.max_stamina
		
	_setup_damage_feedback()
	
func _on_viewport_size_changed() -> void:
	if parallax_game_over and game_over.visible: 
		_configurar_parallax_automaticamente(parallax_game_over)
	if parallax_game_win and win_screen.visible: 
		_configurar_parallax_automaticamente(parallax_game_win)

func _configurar_parallax_automaticamente(parallax_bg: ParallaxBackground) -> void:
	var tamanho_tela = get_viewport().get_visible_rect().size
	if tamanho_tela == Vector2.ZERO:
		tamanho_tela = Vector2(1920, 1080)
		
	var margem_x = SWAY_AMOUNT_X * 4.0
	var margem_y = SWAY_AMOUNT_Y * 4.0
	
	# BLINDAGEM 1: Zera qualquer offset acidental do CanvasLayer/ParallaxBackground
	parallax_bg.offset = Vector2.ZERO
	parallax_bg.scroll_base_offset = Vector2.ZERO
	
	for layer in parallax_bg.get_children():
		if layer is ParallaxLayer:
			layer.motion_mirroring = Vector2.ZERO
			layer.scale = Vector2.ONE
			layer.position = Vector2.ZERO
			# BLINDAGEM 2: Zera offsets de movimento do Layer
			layer.motion_offset = Vector2.ZERO 
			
			for sprite in layer.get_children():
				if sprite is Sprite2D and sprite.texture:
					sprite.centered = true
					# BLINDAGEM 3: Zera offsets internos do Sprite
					sprite.offset = Vector2.ZERO 
					
					sprite.position = tamanho_tela / 2.0
					
					var tex_size = sprite.texture.get_size()
					
					var escala_x = (tamanho_tela.x + margem_x) / tex_size.x
					var escala_y = (tamanho_tela.y + margem_y) / tex_size.y
					
					var final_scale = max(escala_x, escala_y) * 1.4
					sprite.scale = Vector2(final_scale, final_scale)

func _connect_buttons():
	var all_interactables = [try_again_btn, quit_btn, pause_quit_btn, win_restart_btn, win_quit_btn, resume_btn, pause_button, music_slider, sfx_slider, music_mute_check, sfx_mute_check]
	for item in all_interactables:
		if item: item.pivot_offset = item.size / 2.0
		
	if try_again_btn: try_again_btn.pressed.connect(_on_game_over_retry_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_game_over_quit_pressed)
	if pause_button: pause_button.pressed.connect(_on_pause_button_pressed)
	if resume_btn: resume_btn.pressed.connect(_on_resume_button_pressed)
	if pause_quit_btn: pause_quit_btn.pressed.connect(_on_pause_quit_pressed)
	if win_restart_btn: win_restart_btn.pressed.connect(_on_win_restart_pressed)
	if win_quit_btn: win_quit_btn.pressed.connect(_on_win_quit_pressed)

	if music_slider: 
		music_slider.value_changed.connect(_on_music_slider_changed)
		music_slider.gui_input.connect(_on_audio_slider_gui_input.bind(music_slider))
	if sfx_slider: 
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
		sfx_slider.gui_input.connect(_on_audio_slider_gui_input.bind(sfx_slider))
		
	if music_mute_check: music_mute_check.toggled.connect(_on_music_mute_toggled)
	if sfx_mute_check: sfx_mute_check.toggled.connect(_on_sfx_mute_toggled)

func _play_click_sfx() -> void:
	if AudioManager:
		AudioManager.play_sfx(AudioManager.sfx_collect)

func _play_ui_interact_animation(node: Control) -> void:
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(0.9, 0.9), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _setup_damage_feedback() -> void:
	original_control_pos = $Control.position
	
	damage_overlay = ColorRect.new()
	damage_overlay.color = Color(0.8, 0.0, 0.0, 0.0)
	damage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(damage_overlay)
	move_child(damage_overlay, 0)

func trigger_damage_effect() -> void:
	var flash_tween = create_tween()
	damage_overlay.color.a = 0.35
	flash_tween.tween_property(damage_overlay, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
		
	shake_tween = create_tween()
	var shakes = 6
	var shake_strength = 15.0
	
	for i in range(shakes):
		var random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * shake_strength
		shake_tween.tween_property($Control, "position", original_control_pos + random_offset, 0.04)
		shake_strength *= 0.6
		
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
	if parallax_game_over: 
		parallax_game_over.visible = true
		_configurar_parallax_automaticamente(parallax_game_over)
	
	_hide_hud_elements()
	get_tree().paused = true

func show_win_screen():
	game_won = true
	AudioManager.play_music(AudioManager.music_game_win)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	win_screen.visible = true
	if parallax_game_win: 
		parallax_game_win.visible = true
		_configurar_parallax_automaticamente(parallax_game_win)
	
	_hide_hud_elements()
	get_tree().paused = true

func _hide_hud_elements():
	if item_panel: item_panel.visible = false
	if chocolate_panel: chocolate_panel.visible = false
	if stamina_bar: stamina_bar.visible = false
	if health_bar: health_bar.visible = false
	if pause_button: pause_button.visible = false
	if stamina: stamina.visible = false
	
	var background = $Control.get_node_or_null("Background")
	if background: background.visible = false
	
	var background_game_over = $Control.get_node_or_null("BackgroundGameOver")
	if background_game_over: background_game_over.visible = false

func _on_pause_button_pressed():
	_play_click_sfx()
	_play_ui_interact_animation(pause_button)
	await get_tree().create_timer(0.1).timeout
	toggle_pause()

func _on_resume_button_pressed():
	_play_click_sfx()
	_play_ui_interact_animation(resume_btn)
	await get_tree().create_timer(0.15).timeout
	toggle_pause()

func _on_game_over_retry_pressed():
	_play_click_sfx()
	_play_ui_interact_animation(try_again_btn)
	await get_tree().create_timer(0.15).timeout
	
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
	_play_click_sfx()
	_play_ui_interact_animation(win_restart_btn)
	await get_tree().create_timer(0.15).timeout
	
	Global.hearts = 3
	Global.chocolates = 0
	Global.roses = 0
	Global.level = 1
	Global.can_take_damage = true
	get_tree().paused = false
	game_won = false
	
	Global.next_scene_path = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_game_over_quit_pressed():
	_play_click_sfx()
	_play_ui_interact_animation(quit_btn)
	await get_tree().create_timer(0.15).timeout
	_execute_quit()

func _on_pause_quit_pressed():
	_play_click_sfx()
	_play_ui_interact_animation(pause_quit_btn)
	await get_tree().create_timer(0.15).timeout
	_execute_quit()

func _on_win_quit_pressed():
	_play_click_sfx()
	_play_ui_interact_animation(win_quit_btn)
	await get_tree().create_timer(0.15).timeout
	_execute_quit()

func _execute_quit():
	get_tree().paused = false
	Global.next_scene_path = "res://menu.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_audio_slider_gui_input(event: InputEvent, slider: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_play_click_sfx()
		_play_ui_interact_animation(slider)

func _on_music_slider_changed(value: float) -> void:
	if AudioManager:
		AudioManager.set_music_volume(value)
	if music_mute_check:
		music_mute_check.set_pressed_no_signal(value >= 100.0)

func _on_music_mute_toggled(is_button_pressed: bool) -> void:
	_play_click_sfx()
	_play_ui_interact_animation(music_mute_check)
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
	_play_click_sfx()
	_play_ui_interact_animation(sfx_mute_check)
	var target_volume = 100.0 if is_button_pressed else 0.0
	if sfx_slider:
		sfx_slider.set_value_no_signal(target_volume)
	if AudioManager:
		AudioManager.set_sfx_volume(target_volume)

func _process(delta: float) -> void:
	if Global.hearts < previous_hearts:
		trigger_damage_effect()
	previous_hearts = Global.hearts 
	
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

	# --- ANIMAÇÃO DOS FUNDOS PARALLAX (VAI E VEM) ---
	if game_over and game_over.visible and parallax_game_over:
		sway_time_game_over += delta
		parallax_game_over.scroll_offset.x = sin(sway_time_game_over * SWAY_SPEED) * SWAY_AMOUNT_X
		parallax_game_over.scroll_offset.y = cos(sway_time_game_over * (SWAY_SPEED * 0.7)) * SWAY_AMOUNT_Y

	if win_screen and win_screen.visible and parallax_game_win:
		sway_time_game_win += delta
		parallax_game_win.scroll_offset.x = sin(sway_time_game_win * SWAY_SPEED) * SWAY_AMOUNT_X
		parallax_game_win.scroll_offset.y = cos(sway_time_game_win * (SWAY_SPEED * 0.7)) * SWAY_AMOUNT_Y
