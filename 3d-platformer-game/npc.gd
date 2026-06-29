extends Node3D

@export var dialog_lines: Array[String] = [
	"Ola, Steve!",
	"Colete os 5 chocolates para avancar!",
	"Tome cuidado com os perigos pelo caminho.",
	"Boa sorte!"
]

@export var prompt_text: String = "[E] Interagir"
@export var victory_anim: String = "acao/waving"
@export var idle_anim: String = "acao/idle"
@export var turn_speed: float = 5.0 # Controla a velocidade do giro (maior = mais rápido)

@onready var anim_player: AnimationPlayer = $Idle/AnimationPlayer
@onready var dialog_balloon: Label3D = $Label3D 

var player_node: Node3D = null
var is_interacting := false
var current_dialog_index := 0

# Guarda a rotação original para o NPC voltar a olhar para frente quando você sair
var original_rotation_y: float 

func _ready() -> void:
	original_rotation_y = global_rotation.y
	
	if dialog_balloon:
		dialog_balloon.hide()
	
	if anim_player and anim_player.has_animation(idle_anim):
		anim_player.play(idle_anim)
		
	# --- VERIFICA O NOME DO LEVEL ---
	# Pega o nome da cena principal atual (ex: "Level1", "level2", etc)
	var scene_name = get_tree().current_scene.name
	
	# Ajusta o diálogo dependendo do level
	if scene_name == "Level1":
		dialog_lines[1] = "Colete as 6 Rosas para avancar!"
	elif scene_name == "Level2":
		dialog_lines[1] = "Colete os 5 chocolates para ganhar!"

func _process(delta: float) -> void:
	var target_rotation_y = original_rotation_y
	
	# Se o jogador estiver na área, calcula o ângulo até ele
	if player_node:
		var direction = (player_node.global_position - global_position).normalized()
		# Descobre o ângulo em radianos necessário para olhar para o alvo
		target_rotation_y = atan2(direction.x, direction.z)
		
		# Somamos PI (180 graus) para arrumar as costas do modelo Mixamo.
		# Somamos +0.3 para ela olhar ligeiramente mais para a esquerda, alinhando com o Steve.
		# (Se quiser que ela olhe mais, aumente para 0.5. Se for para o outro lado, use -0.3)
		target_rotation_y -= 0.3

	# Suaviza a rotação de onde ela está agora até o alvo, usando o delta
	global_rotation.y = lerp_angle(global_rotation.y, target_rotation_y, turn_speed * delta)

func _input(event: InputEvent) -> void:
	if player_node != null:
		if event is InputEventKey and event.physical_keycode == KEY_E and event.pressed:
			interact()

func interact() -> void:
	if not is_interacting:
		# Primeira vez apertando E: Começa a conversa
		is_interacting = true
		current_dialog_index = 0
		show_dialog_line()
		
		# Toca o Waving com uma TRANSIÇÃO SUAVE de 0.4 segundos (adeus quebra brusca!)
		if anim_player and anim_player.has_animation(victory_anim):
			anim_player.play(victory_anim, 0.4)
	else:
		# Já está conversando e apertou E de novo: Avança o texto
		current_dialog_index += 1
		
		if current_dialog_index < dialog_lines.size():
			show_dialog_line()
			# Opcional: Dá um "reset" suave na animação de aceno a cada fala
			if anim_player and anim_player.has_animation(victory_anim):
				anim_player.play(victory_anim, 0.2)
		else:
			# Fim da lista de diálogos
			end_interaction()

func show_dialog_line() -> void:
	if dialog_balloon:
		dialog_balloon.text = dialog_lines[current_dialog_index]
		dialog_balloon.show()
		
		# Toca o som (toda vez que uma nova frase aparece)
		AudioManager.play_npc_voice(AudioManager.sfx_npc, 1.0)

func end_interaction() -> void:
	is_interacting = false
	
	# --- AQUI ESTÁ O CORTE DO SOM ---
	AudioManager.stop_npc_voice() 
	
	if dialog_balloon:
		dialog_balloon.text = prompt_text
		
	if anim_player and anim_player.has_animation(idle_anim):
		anim_player.play(idle_anim, 0.5)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Steve":
		player_node = body
		if dialog_balloon and not is_interacting:
			dialog_balloon.text = prompt_text
			dialog_balloon.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Steve":
		player_node = null
		end_interaction()
		if dialog_balloon:
			dialog_balloon.hide()
