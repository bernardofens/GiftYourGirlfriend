extends CharacterBody3D

@export var mouse_sensitivity := 0.003

const SPEED = 5.0
const JUMP_VELOCITY = 10
const MAX_JUMPS = 2
var jump_count = 0
const SPRINT_SPEED = 9.0
var target_cam_y_rotation : float = 0.0
const CAM_ROTATION_SPEED : float = 8.0   # Ajuste para controlar a suavidade
const CAM_ROTATION_STEP : float = 30.0   # Graus por toque

@export var spawn_position: Vector3
signal player_died
var xform: Transform3D

# --- SISTEMA DE ESTAMINA ---
@export var max_stamina := 100.0
var current_stamina := 100.0
@export var stamina_drain_rate := 25.0 # O quão rápido a estamina cai correndo
@export var stamina_regen_rate := 15.0 # O quão rápido ela recupera
@export var stamina_bar : ProgressBar  # Referência para a barra na tela
# ---------------------------

func take_damage():
	if !Global.can_take_damage:
		return
	Global.hearts -= 1
	Global.can_take_damage = false
	if Global.hearts <= 0:
		print("player died calling signal")
		player_died.emit()
	else:
		await get_tree().create_timer(1.0).timeout
	Global.can_take_damage = true
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		$AnimationPlayer.play("jump")
	elif is_on_floor() and input_dir != Vector2.ZERO:
		$AnimationPlayer.play("run")
	elif is_on_floor() and input_dir == Vector2.ZERO:
		$AnimationPlayer.play("idle")
	
	$Camera_Controller.rotation.y = lerp_angle(
		$Camera_Controller.rotation.y,
		target_cam_y_rotation,
		CAM_ROTATION_SPEED * delta
	)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		jump_count = 0
		
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		if jump_count == 1:
			if velocity.y < 0:
					velocity.y = JUMP_VELOCITY/1.5
			else:
				velocity.y += JUMP_VELOCITY/1.5
		else:
			velocity.y = JUMP_VELOCITY
		jump_count += 1
	
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if input_dir != Vector2(0,0):
		$Armature.rotation_degrees.y = $Camera_Controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90
	
	if is_on_floor():
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform, 0.3)
	else:
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.3)
		
	# --- SISTEMA DE ESTAMINA (Lógica de corrida) ---
	var is_moving = direction != Vector3.ZERO
	var is_trying_to_sprint = Input.is_action_pressed("sprint")
	var current_speed = SPEED

	# Se está tentando correr, está se movendo e tem estamina
	if is_trying_to_sprint and is_moving and Global.stamina > 0:
		current_speed = SPRINT_SPEED
		Global.stamina -= stamina_drain_rate * delta
	else:
		# Se não está correndo, recupera
		Global.stamina += stamina_regen_rate * delta

	# Impede a estamina de passar do limite ou ficar negativa
	Global.stamina = clamp(Global.stamina, 0.0, Global.max_stamina)
	# -----------------------------------------------

	if is_on_floor() and direction != Vector3.ZERO:
		var floor_normal = get_floor_normal()
		var downhill = Vector3.DOWN.slide(floor_normal).normalized()
		var slope_dot = direction.dot(downhill)

		if slope_dot < 0:
			current_speed *= lerp(1.0, 0.6, -slope_dot)
		elif slope_dot > 0:
			current_speed *= lerp(1.0, 1.4, slope_dot)
			
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	move_and_slide()
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.15)

func align_with_floor(floor_normal):
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()
	
func _ready():
	spawn_position = global_position
	target_cam_y_rotation = $Camera_Controller.rotation.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# --- SISTEMA DE ESTAMINA (Setup inicial) ---
	current_stamina = max_stamina
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina
	# -------------------------------------------

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		target_cam_y_rotation -= event.relative.x * mouse_sensitivity
		
func _on_fall_zone_body_entered(body: Node3D) -> void:
	if body.name == "Steve": # Confirme se o nome do player é esse mesmo
		take_damage()
		velocity = Vector3.ZERO
		global_position = spawn_position
		
func bounce():
	velocity.y = JUMP_VELOCITY * 0.7
