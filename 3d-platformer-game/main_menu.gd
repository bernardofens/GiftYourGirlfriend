extends Control

@onready var title_logo = $TitleLogo
@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton
@onready var settings_button = $Settings

# --- REFERÊNCIAS DO PAINEL DE CONFIGURAÇÕES ---
@onready var settings_panel = $SettingsPanel
@onready var sfx_mute_check: CheckBox = $SettingsPanel/SfxMuteCheck
@onready var music_mute_check: CheckBox = $SettingsPanel/MusicMuteCheck
@onready var music_slider: HSlider = $SettingsPanel/MusicSlider
@onready var sfx_slider: HSlider = $SettingsPanel/SfxSlider

func _ready() -> void:
	if AudioManager:
		AudioManager.play_music(AudioManager.music_menu)
	
	if title_logo:
		title_logo.scale = Vector2.ZERO 
	if play_button:
		play_button.modulate.a = 0.0 
	if quit_button:
		quit_button.modulate.a = 0.0
	if settings_button:
		settings_button.modulate.a = 0.0
		
	if settings_panel:
		settings_panel.visible = false
		settings_panel.scale = Vector2.ZERO
		settings_panel.pivot_offset = settings_panel.size / 2
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
		
	if music_slider:
		music_slider.value_changed.connect(_on_music_slider_changed)
	if music_mute_check:
		music_mute_check.toggled.connect(_on_music_mute_toggled)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	if sfx_mute_check:
		sfx_mute_check.toggled.connect(_on_sfx_mute_toggled)
		
	animate_menu_entrance()

func animate_menu_entrance() -> void:
	var tween = create_tween()
	if title_logo:
		tween.tween_property(title_logo, "scale", Vector2(1, 1), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if play_button:
		tween.tween_property(play_button, "modulate:a", 1.0, 0.4)
	if settings_button:
		tween.parallel().tween_property(settings_button, "modulate:a", 1.0, 0.4)
	if quit_button:
		tween.parallel().tween_property(quit_button, "modulate:a", 1.0, 0.4)

# --- SINAIS DA INTERFACE PRINCIPAL ---

func _on_play_pressed() -> void:
	Global.next_scene_path = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
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

# --- SINAIS DE CONFIGURAÇÃO DE ÁUDIO COM SINCRONIZAÇÃO ---

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
