extends Control

# --- CONSTANTES DE ANIMAÇÃO ---
const LOGO_HOVER_OFFSET = Vector2(10, 5)
const LOGO_HOVER_DURATION = 1.0

# --- REFERÊNCIAS PRINCIPAIS ---
@onready var title_logo = $TitleLogo
@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton
@onready var settings_button = $Settings
@onready var tutorial_button = $Tutorial 

# --- REFERÊNCIA DO FUNDO ---
@onready var background = $Background 

# --- REFERÊNCIAS DO PAINEL DE CONFIGURAÇÕES ---
@onready var settings_panel = $SettingsPanel
@onready var sfx_mute_check: CheckBox = $SettingsPanel/SfxMuteCheck
@onready var music_mute_check: CheckBox = $SettingsPanel/MusicMuteCheck
@onready var music_slider: HSlider = $SettingsPanel/MusicSlider
@onready var sfx_slider: HSlider = $SettingsPanel/SfxSlider

# --- REFERÊNCIAS DO TUTORIAL ---
@onready var tutorial_overlay = $TutorialOverlay
@onready var page_1_story = $TutorialOverlay/Panel/Page1_Story
@onready var page_2_mechanics = $TutorialOverlay/Panel/Page2_Mechanics
@onready var next_page_button: BaseButton = $TutorialOverlay/Panel/Page1_Story/VBoxContainer/NextPageButton
@onready var close_tutorial_button: BaseButton = $TutorialOverlay/Panel/Page2_Mechanics/VBoxContainer/CloseTutorialButton
@onready var prev_page_button: BaseButton = $TutorialOverlay/Panel/Page2_Mechanics/VBoxContainer/PrevPageButton

# Variáveis de controle de animação
var _logo_original_position: Vector2

func _ready() -> void:
	if AudioManager:
		AudioManager.play_music(AudioManager.music_menu)
	
	if title_logo: 
		title_logo.scale = Vector2.ZERO 
		_logo_original_position = title_logo.position
		_start_logo_hover_loop()
		
	if play_button: play_button.modulate.a = 0.0 
	if quit_button: quit_button.modulate.a = 0.0
	if settings_button: settings_button.modulate.a = 0.0
	if tutorial_button: tutorial_button.modulate.a = 0.0
	
	# Ajusta o pivot no centro para a animação de mola de TODOS os elementos interativos
	var all_interactables = [play_button, quit_button, settings_button, tutorial_button, next_page_button, prev_page_button, close_tutorial_button, music_slider, sfx_slider, music_mute_check, sfx_mute_check]
	for item in all_interactables:
		if item: item.pivot_offset = item.size / 2.0

	if settings_panel:
		settings_panel.visible = false
		settings_panel.scale = Vector2.ZERO
		settings_panel.pivot_offset = settings_panel.size / 2.0
		
	if tutorial_overlay:
		tutorial_overlay.visible = false
		page_1_story.visible = true
		page_2_mechanics.visible = false
	
	# Conexão de sinais principais
	if play_button: play_button.pressed.connect(_on_play_pressed)
	if quit_button: quit_button.pressed.connect(_on_quit_pressed)
	if settings_button: settings_button.pressed.connect(_on_settings_pressed)
	if tutorial_button: tutorial_button.pressed.connect(_on_tutorial_pressed)
	
	if next_page_button: next_page_button.pressed.connect(_on_next_page_pressed)
	if prev_page_button: prev_page_button.pressed.connect(_on_prev_page_pressed)
	if close_tutorial_button: close_tutorial_button.pressed.connect(_on_close_tutorial_pressed)
		
	# Conexão de sinais de áudio e interação manual (gui_input) para sliders
	if music_slider: 
		music_slider.value_changed.connect(_on_music_slider_changed)
		music_slider.gui_input.connect(_on_audio_slider_gui_input.bind(music_slider))
	if sfx_slider: 
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
		sfx_slider.gui_input.connect(_on_audio_slider_gui_input.bind(sfx_slider))
		
	if music_mute_check: music_mute_check.toggled.connect(_on_music_mute_toggled)
	if sfx_mute_check: sfx_mute_check.toggled.connect(_on_sfx_mute_toggled)
		
	animate_menu_entrance()

func animate_menu_entrance() -> void:
	var tween = create_tween()
	if title_logo: tween.tween_property(title_logo, "scale", Vector2(1, 1), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if play_button: tween.tween_property(play_button, "modulate:a", 1.0, 0.4)
	if settings_button: tween.parallel().tween_property(settings_button, "modulate:a", 1.0, 0.4)
	if quit_button: tween.parallel().tween_property(quit_button, "modulate:a", 1.0, 0.4)
	if tutorial_button: tween.parallel().tween_property(tutorial_button, "modulate:a", 1.0, 0.4)

# --- FUNÇÕES DE ANIMAÇÃO E SOM ---

func _play_click_sfx() -> void:
	if AudioManager:
		AudioManager.play_sfx(AudioManager.sfx_collect)

# Alterado para aceitar qualquer nó do tipo Control (inclui sliders e checkboxes)
func _play_ui_interact_animation(node: Control) -> void:
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(0.9, 0.9), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _start_logo_hover_loop() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(title_logo, "position", _logo_original_position + LOGO_HOVER_OFFSET, LOGO_HOVER_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_logo, "position", _logo_original_position - LOGO_HOVER_OFFSET, LOGO_HOVER_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# --- SINAIS DA INTERFACE PRINCIPAL ---

func _on_play_pressed() -> void:
	_play_click_sfx()
	_play_ui_interact_animation(play_button)
	await get_tree().create_timer(0.15).timeout
	Global.next_scene_path = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_quit_pressed() -> void:
	_play_click_sfx()
	_play_ui_interact_animation(quit_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()

func _on_settings_pressed() -> void:
	_play_click_sfx()
	_play_ui_interact_animation(settings_button)
	if tutorial_overlay and tutorial_overlay.visible:
		return 
		
	if settings_panel:
		if not settings_panel.visible:
			settings_panel.visible = true
			var tween = create_tween()
			tween.tween_property(settings_panel, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			var tween = create_tween()
			tween.tween_property(settings_panel, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			await tween.finished
			settings_panel.visible = false

# --- SINAIS DO TUTORIAL (OVERLAY E PÁGINAS) ---

func _on_tutorial_pressed() -> void:
	_play_click_sfx()
	_play_ui_interact_animation(tutorial_button)
	if settings_panel and settings_panel.visible:
		return 
		
	if tutorial_overlay:
		page_1_story.visible = true
		page_2_mechanics.visible = false
		
		tutorial_overlay.modulate.a = 0.0
		tutorial_overlay.visible = true
		var tween = create_tween()
		tween.tween_property(tutorial_overlay, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_next_page_pressed() -> void:
	_play_click_sfx()
	_play_ui_interact_animation(next_page_button)
	page_1_story.visible = false
	page_2_mechanics.visible = true

func _on_prev_page_pressed() -> void:
	_play_click_sfx()
	_play_ui_interact_animation(prev_page_button)
	page_2_mechanics.visible = false
	page_1_story.visible = true

func _on_close_tutorial_pressed() -> void:
	_play_click_sfx()
	_play_ui_interact_animation(close_tutorial_button)
	if tutorial_overlay:
		var tween = create_tween()
		tween.tween_property(tutorial_overlay, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished
		tutorial_overlay.visible = false

# --- SINAIS DE CONFIGURAÇÃO DE ÁUDIO COM SINCRONIZAÇÃO E ANIMAÇÃO ---

func _on_audio_slider_gui_input(event: InputEvent, slider: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_play_click_sfx()
		_play_ui_interact_animation(slider)

func _on_music_slider_changed(value: float) -> void:
	if AudioManager: AudioManager.set_music_volume(value)
	if music_mute_check: music_mute_check.set_pressed_no_signal(value >= 100.0)

func _on_music_mute_toggled(is_button_pressed: bool) -> void:
	_play_click_sfx()
	_play_ui_interact_animation(music_mute_check)
	var target_volume = 100.0 if is_button_pressed else 0.0
	if music_slider: music_slider.set_value_no_signal(target_volume)
	if AudioManager: AudioManager.set_music_volume(target_volume)

func _on_sfx_slider_changed(value: float) -> void:
	if AudioManager: AudioManager.set_sfx_volume(value)
	if sfx_mute_check: sfx_mute_check.set_pressed_no_signal(value >= 100.0)

func _on_sfx_mute_toggled(is_button_pressed: bool) -> void:
	_play_click_sfx()
	_play_ui_interact_animation(sfx_mute_check)
	var target_volume = 100.0 if is_button_pressed else 0.0
	if sfx_slider: sfx_slider.set_value_no_signal(target_volume)
	if AudioManager: AudioManager.set_sfx_volume(target_volume)
