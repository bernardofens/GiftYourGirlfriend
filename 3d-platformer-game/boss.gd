extends CharacterBody3D

enum State { PATROL, CHASE, SHOOT }
var current_state = State.PATROL

@export var speed = 4.0 
@export var chase_speed = 6.0
@export var detection_range := 25.0
@export var shoot_range := 12.0
@export var bullet_scene: PackedScene 

var direction := Vector3.ZERO
var player: Node3D
var turning := false
var can_shoot := true

func _ready() -> void:
	$RayCast3D.enabled = true
	player = get_tree().get_first_node_in_group("Steve")
	definir_direcao_aleatoria()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match current_state:
		State.PATROL:
			_patrol_state()
		State.CHASE:
			_chase_state()
		State.SHOOT:
			_shoot_state(delta)

	if not turning and current_state != State.SHOOT:
		var current_speed = chase_speed if current_state == State.CHASE else speed
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if direction != Vector3.ZERO:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 5 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	if current_state != State.SHOOT:
		_check_collisions()

func _patrol_state():
	if player and global_position.distance_to(player.global_position) < detection_range:
		current_state = State.CHASE

func _chase_state():
	if not player: return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > detection_range * 1.5:
		current_state = State.PATROL
		definir_direcao_aleatoria()
	elif distance_to_player < shoot_range:
		current_state = State.SHOOT 
	else:
		var dir_to_player = (player.global_position - global_position)
		dir_to_player.y = 0
		direction = dir_to_player.normalized()

func _shoot_state(delta: float):
	if not player: return
	
	var dir_to_player = (player.global_position - global_position)
	dir_to_player.y = 0
	var target_rotation = atan2(dir_to_player.x, dir_to_player.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, 8 * delta)
	
	if global_position.distance_to(player.global_position) > shoot_range * 1.2:
		current_state = State.CHASE
		return
		
	if can_shoot and bullet_scene:
		fire_projectile()

func fire_projectile():
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet) 
	
	# Posição de origem: centro do Boss
	var spawn_pos = global_position
	spawn_pos.y += 0.5 
	
	# Posição do alvo: mira exata no peito do jogador
	var target_pos = player.global_position
	target_pos.y += 1.0 
	
	# Calcula a direção reta
	var dir = (target_pos - spawn_pos).normalized()
	
	# Nasce um pouco à frente para não colidir com o próprio Boss
	bullet.global_position = spawn_pos + (dir * 1.5) 
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(dir)
	
	await get_tree().create_timer(2.2).timeout
	can_shoot = true

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
		$SidesChecker.set_collision_mask_value(1, false)
		$TopChecker.set_collision_mask_value(1, false)
		direction = Vector3.ZERO
		speed = 0
		await get_tree().create_timer(1.0).timeout
		queue_free()
