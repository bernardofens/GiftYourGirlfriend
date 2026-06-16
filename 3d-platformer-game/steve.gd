extends CharacterBody3D

@export var mouse_sensitivity := 0.003

# Valores ajustados para dar Match com as animações
const SPEED = 3.5
const SPRINT_SPEED = 6.0
const JUMP_VELOCITY = 7.5

const MAX_JUMPS = 2
var jump_count = 0
var target_cam_y_rotation : float = 0.0
const CAM_ROTATION_SPEED : float = 8.0
const CAM_ROTATION_STEP : float = 30.0

@export var spawn_position: Vector3
signal player_died
var xform: Transform3D

# --- SISTEMA DE ESTAMINA ---
@export var max_stamina := 100.0
var current_stamina := 100.0
@export var stamina_drain_rate := 25.0
@export var stamina_regen_rate := 15.0
@export var stamina_bar : ProgressBar
# ---------------------------

# --- CONTROLE DE ÁUDIO DE PASSOS ---
var step_timer := 0.0
var step_interval := 0.35

func _ready() -> void:
	Global.can_take_damage = true
	spawn_position = global_position
	target_cam_y_rotation = $Camera_Controller.rotation.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	current_stamina = max_stamina
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina

func take_damage():
	if !Global.can_take_damage:
		return
	Global.hearts -= 1
	Global.can_take_damage = false
	
	AudioManager.play_sfx(AudioManager.sfx_damage_taken)
	
	# Chama o efeito visual de piscar em vermelho
	flash_damage()
	
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
		
	# 1. Controles de Entrada
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_moving = direction != Vector3.ZERO
	var is_trying_to_sprint = Input.is_action_pressed("sprint")
	
	# Rotação da Câmera e do Modelo
	$Camera_Controller.rotation.y = lerp_angle(
		$Camera_Controller.rotation.y,
		target_cam_y_rotation,
		CAM_ROTATION_SPEED * delta
	)
	if input_dir != Vector2.ZERO:
		$Armature.rotation_degrees.y = $Camera_Controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90
	
	# 2. Gravidade e Lógica do Pulo
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		if jump_count == 1:
			velocity.y = (JUMP_VELOCITY / 1.5) if velocity.y < 0 else (velocity.y + JUMP_VELOCITY / 1.5)
		else:
			velocity.y = JUMP_VELOCITY
		jump_count += 1
		AudioManager.play_sfx(AudioManager.sfx_jump)
	
	# 3. Lógica de Velocidade e Estamina
	var current_speed = SPEED
	var is_sprinting = is_trying_to_sprint and is_moving and Global.stamina > 0

	if is_sprinting:
		current_speed = SPRINT_SPEED
		Global.stamina -= stamina_drain_rate * delta
	else:
		Global.stamina += stamina_regen_rate * delta

	Global.stamina = clamp(Global.stamina, 0.0, Global.max_stamina)

	# 4. Cálculo de Ladeiras
	if is_on_floor() and direction != Vector3.ZERO:
		var floor_normal = get_floor_normal()
		var downhill = Vector3.DOWN.slide(floor_normal).normalized()
		var slope_dot = direction.dot(downhill)
		if slope_dot < 0:
			current_speed *= lerp(1.0, 0.6, -slope_dot)
		elif slope_dot > 0:
			current_speed *= lerp(1.0, 1.4, slope_dot)
			
	# 5. Aplicação do Movimento
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	# 6. Alinhamento com o chão
	if is_on_floor():
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform, 0.3)
	else:
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.3)
		
	move_and_slide()
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.15)

	# 7. MÁQUINA DE ANIMAÇÃO E ÁUDIO
	if not is_on_floor():
		# Se estiver no ar E apertando algum botão de andar, toca o salto direcional
		if is_moving:
			$Armature/AnimationPlayer.play("acao/Jump", 0.2)
		else:
			# Se pulou parado, toca o salto vertical
			$Armature/AnimationPlayer.play("acao/Jumping", 0.2)
	else:
		if is_moving:
			if is_sprinting:
				$Armature/AnimationPlayer.play("acao/Running", 0.2)
				_handle_step_audio(delta, true)
			else:
				$Armature/AnimationPlayer.play("acao/Walking", 0.2)
				_handle_step_audio(delta, false)
		else:
			$Armature/AnimationPlayer.play("mixamo_com", 0.2)

func _handle_step_audio(delta: float, is_sprinting: bool) -> void:
	step_timer += delta
	var current_interval = step_interval * 0.6 if is_sprinting else step_interval
	if step_timer >= current_interval:
		AudioManager.play_sfx(AudioManager.sfx_walk, -12.0)
		step_timer = 0.0

func align_with_floor(floor_normal):
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		target_cam_y_rotation -= event.relative.x * mouse_sensitivity
		
func _on_fall_zone_body_entered(body: Node3D) -> void:
	if body.name == "Steve":
		take_damage()
		velocity = Vector3.ZERO
		global_position = spawn_position
		
func bounce():
	velocity.y = JUMP_VELOCITY * 0.7

# --- SISTEMA DE FEEDBACK VISUAL DE DANO ---
func flash_damage():
	# Acessa a malha onde a textura principal foi aplicada
	var mesh_node = $Armature/Skeleton3D/node_0
	var mat = mesh_node.get_surface_override_material(0)
	
	if mat:
		var tween = create_tween()
		# Fica vermelho em 0.1 segundos
		tween.tween_property(mat, "albedo_color", Color.RED, 0.1)
		# Retorna à cor original em 0.2 segundos
		tween.tween_property(mat, "albedo_color", Color.WHITE, 0.2)
