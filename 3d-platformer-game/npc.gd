extends Node3D

@export var dialog_text: String = "Ola, Steve! Que bom ver voce."
@export var victory_anim: String = "misty_rig|misty_victory"
@export var idle_anim: String = "misty_rig|misty_idle"

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var dialog_balloon: Label3D = $Label3D # Certifique-se de que o nó tem este nome exato

var player_in_range := false
var has_interacted := false

func _ready() -> void:
	if dialog_balloon:
		dialog_balloon.text = dialog_text
		dialog_balloon.hide()
	
	if anim_player and anim_player.has_animation(idle_anim):
		anim_player.play(idle_anim)

func _input(event: InputEvent) -> void:
	if player_in_range and not has_interacted:
		# Detecta se a tecla "E" foi pressionada fisicamente no teclado
		if event is InputEventKey and event.physical_keycode == KEY_E and event.pressed:
			interact()

func interact() -> void:
	has_interacted = true
	if dialog_balloon:
		dialog_balloon.show()
	
	if anim_player and anim_player.has_animation(victory_anim):
		anim_player.play(victory_anim)
		
		# Espera 2.5 segundos (você pode ajustar o tempo conforme achar melhor)
		await get_tree().create_timer(2.5).timeout
		
		# Força a volta para o idle
		if anim_player.has_animation(idle_anim):
			anim_player.play(idle_anim)

# Atenção: Conecte o sinal "body_entered" do Area3D a esta função através do painel "Node"
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Steve":
		player_in_range = true

# Atenção: Conecte o sinal "body_exited" do Area3D a esta função através do painel "Node"
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Steve":
		player_in_range = false
		has_interacted = false
		if dialog_balloon:
			dialog_balloon.hide()
		if anim_player and anim_player.has_animation(idle_anim):
			anim_player.play(idle_anim)
