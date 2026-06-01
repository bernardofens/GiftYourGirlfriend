extends CharacterBody3D

var speed = 6.0
var turning := false
var current_angle: float = 0.0
var direction := Vector3.ZERO

func _ready() -> void:
	$RayCast3D.enabled = true
	definir_direcao_aleatoria()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not turning:
		velocity.x = speed * direction.x
		velocity.z = speed * direction.z
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if not turning:
		# Colisão com parede
		if is_on_wall():
			mudar_direcao_por_colisao()
		# Borda detectada: está no chão mas o RayCast não vê chão à frente
		elif is_on_floor() and not $RayCast3D.is_colliding():
			mudar_direcao_por_colisao()

func definir_direcao_aleatoria():
	var novo_angulo: float
	var tentativas := 0
	while tentativas < 10:
		var angulo_graus = randi_range(0, 35) * 10
		novo_angulo = deg_to_rad(angulo_graus)
		if abs(novo_angulo - current_angle) > deg_to_rad(30):
			break
		tentativas += 1

	current_angle = novo_angulo
	direction = Vector3(sin(current_angle), 0, cos(current_angle)).normalized()

	# Atualiza o RayCast para apontar à frente na nova direção
	# O target_position aponta levemente para baixo para detectar o chão à frente
	$RayCast3D.target_position = Vector3(direction.x * 1.0, -1.0, direction.z * 1.0)

	var target_basis = Basis.looking_at(-direction, Vector3.UP)
	var tween = create_tween()
	tween.tween_method(
		func(t: float):
			basis = basis.slerp(target_basis, t),
		0.0, 1.0, 0.25
	)

func mudar_direcao_por_colisao():
	if turning:
		return
	turning = true

	velocity.x = 0
	velocity.z = 0

	# Recua brevemente para sair da parede ou borda
	var direcao_recuo = -direction
	var tween_recuo = create_tween()
	tween_recuo.tween_method(
		func(t: float):
			velocity.x = direcao_recuo.x * speed * t
			velocity.z = direcao_recuo.z * speed * t
			move_and_slide(),
		1.0, 0.0, 0.15
	)
	await tween_recuo.finished

	direction = Vector3.ZERO
	definir_direcao_aleatoria()

	await get_tree().create_timer(0.3).timeout
	turning = false

func _on_sides_checker_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()

func _on_top_checker_body_entered(body: Node3D) -> void:
	$AnimationPlayer.play("squash")
	if body is RigidBody3D:
		body.apply_central_impulse(Vector3.UP * 8.0)
	elif body is CharacterBody3D:
		body.velocity.y = 8.0
	$SidesChecker.set_collision_mask_value(1, false)
	$TopChecker.set_collision_mask_value(1, false)
	direction = Vector3.ZERO
	speed = 0
	await get_tree().create_timer(1.0).timeout
	queue_free()
