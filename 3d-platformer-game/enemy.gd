extends CharacterBody3D

enum State { PATROL, CHASE, WINDUP, LUNGE }
var current_state = State.PATROL

@export var speed = 2.0 
@export var chase_speed = 4.0 
@export var lunge_speed = 9.0 
@export var detection_range := 12.0
@export var attack_range := 4.0 

var direction := Vector3.ZERO
var player: Node3D
var turning := false

# --- SISTEMA DE ÁUDIO 3D ---
var step_audio_player: AudioStreamPlayer3D
var sfx_enemy_walk = preload("res://Assets/Audio/sfx_enemy_walk.wav")
var step_timer := 0.0
var step_interval := 0.5

func _ready() -> void:
	$RayCast3D.enabled = true
	player = get_tree().get_first_node_in_group("Steve")
	definir_direcao_aleatoria()
	
	# Inicializa e configura o player de áudio 3D
	step_audio_player = AudioStreamPlayer3D.new()
	add_child(step_audio_player)
	step_audio_player.stream = sfx_enemy_walk
	step_audio_player.max_distance = 15.0 # Distância máxima em metros para ouvir o som

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match current_state:
		State.PATROL:
			_patrol_state()
		State.CHASE:
			_chase_state()
		State.WINDUP:
			_windup_state(delta)
		State.LUNGE:
			pass 

	if not turning and current_state in [State.PATROL, State.CHASE]:
		var current_speed = chase_speed if current_state == State.CHASE else speed
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if direction != Vector3.ZERO:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 10 * delta)
			
	elif current_state == State.WINDUP or turning:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	if current_state in [State.PATROL, State.CHASE]:
		_check_collisions()
		
	# Gerencia o som de passos tridimensional baseado no movimento
	if is_on_floor() and velocity.length() > 0.1 and not turning and current_state in [State.PATROL, State.CHASE]:
		step_timer += delta
		# Reduz o intervalo se estiver perseguindo (passos mais rápidos)
		var current_interval = step_interval * 0.6 if current_state == State.CHASE else step_interval
		if step_timer >= current_interval:
			step_audio_player.play()
			step_timer = 0.0

func _patrol_state():
	if player and global_position.distance_to(player.global_position) < detection_range:
		current_state = State.CHASE

func _chase_state():
	if not player: return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist > detection_range * 1.5:
		current_state = State.PATROL
		definir_direcao_aleatoria()
	elif dist <= attack_range:
		_start_windup()
	else:
		var dir_to_player = (player.global_position - global_position)
		dir_to_player.y = 0
		direction = dir_to_player.normalized()

func _start_windup():
	current_state = State.WINDUP
	await get_tree().create_timer(0.8).timeout
	if current_state == State.WINDUP:
		_start_lunge()

func _windup_state(delta: float):
	if player:
		var dir_to_player = (player.global_position - global_position)
		dir_to_player.y = 0
		var target_rotation = atan2(dir_to_player.x, dir_to_player.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 12 * delta)

func _start_lunge():
	current_state = State.LUNGE
	var dir_to_player = (player.global_position - global_position)
	dir_to_player.y = 0
	direction = dir_to_player.normalized()
	velocity.x = direction.x * lunge_speed
	velocity.z = direction.z * lunge_speed
	velocity.y = 4.0 
	
	await get_tree().create_timer(0.6).timeout
	
	if current_state == State.LUNGE:
		current_state = State.PATROL
		definir_direcao_aleatoria()

func _check_collisions():
	if not turning:
		if is_on_wall() or (is_on_floor() and not $RayCast3D.is_colliding()):
			mudar_direcao_por_colisao()

func definir_direcao_aleatoria():
	var angulo = randf_range(0, TAU)
	direction = Vector3(sin(angulo), 0, cos(angulo)).normalized()

func mudar_direcao_por_colisao():
	if turning: return
	turning = true
	direction = Vector3.ZERO
	await get_tree().create_timer(0.2).timeout
	
	if current_state == State.CHASE:
		current_state = State.PATROL
		
	definir_direcao_aleatoria()
	turning = false

func _on_sides_checker_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()

func _on_top_checker_body_entered(body: Node3D) -> void:
	if "velocity" in body and body.velocity.y < 0:
		if $AnimationPlayer.has_animation("squash"):
			$AnimationPlayer.play("squash")
			
		if body is CharacterBody3D:
			body.velocity.y = 8.0 
			
		AudioManager.play_sfx(AudioManager.sfx_damage_dealt)
			
		$SidesChecker.set_collision_mask_value(1, false)
		$TopChecker.set_collision_mask_value(1, false)
		direction = Vector3.ZERO
		speed = 0
		current_state = State.WINDUP 
		
		await get_tree().create_timer(1.0).timeout
		queue_free()
