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

var xform: Transform3D

func take_damage():
	if !Global.can_take_damage:
		return
	Global.hearts -= 1
	Global.can_take_damage = false
	if Global.hearts <= 0:
		Global.hearts =3
		if Global.level == 1:
			get_tree().change_scene_to_file("res://level_1.tscn")
		else:
			get_tree().change_scene_to_file("res://level_2.tscn")
	else:
		await get_tree().create_timer(1.0).timeout
	Global.can_take_damage = true
	
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Play robot animations (should be above "move_and_slide()")
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		$AnimationPlayer.play("jump")
	elif is_on_floor() and input_dir != Vector2.ZERO:
		$AnimationPlayer.play("run")
	elif is_on_floor() and input_dir == Vector2.ZERO:
		$AnimationPlayer.play("idle")
	
	# Suaviza a rotação atual em direção ao alvo
	$Camera_Controller.rotation.y = lerp_angle(
		$Camera_Controller.rotation.y,
		target_cam_y_rotation,
		CAM_ROTATION_SPEED * delta
	)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reset jumps when touching floor
	if is_on_floor():
		jump_count = 0
	# Jump / Double Jump
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		if jump_count == 1:
			if velocity.y < 0:
					velocity.y = JUMP_VELOCITY/1.5
			else:
				velocity.y += JUMP_VELOCITY/1.5
		else:
			velocity.y = JUMP_VELOCITY
		jump_count += 1
	
	# New Vector3 direction, taking into account the user arrow inputs and the camera rotation
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Rotate the character mesh so oriented towards the direction moving to the camera
	if input_dir != Vector2(0,0):
		$Armature.rotation_degrees.y = $Camera_Controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90
	
	


	
	# Align character with floor
	if is_on_floor():
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform, 0.3)

	else:
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.3)
	# Define a velocidade atual baseada no sprint
	var current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	if is_on_floor() and direction != Vector3.ZERO:
		
		var floor_normal = get_floor_normal()

		# downhill direction
		var downhill = Vector3.DOWN.slide(floor_normal).normalized()

		# compare movement with downhill direction
		var slope_dot = direction.dot(downhill)

		# uphill
		if slope_dot < 0:
			current_speed *= lerp(1.0, 0.6, -slope_dot)

		# downhill
		elif slope_dot > 0:
			current_speed *= lerp(1.0, 1.4, slope_dot)
	# Ao aplicar o movimento, use current_speed:
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()
	# Make Camera_Controller match the position of myself
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
#Pra mexer a camera diretamente com o mouse mexendo
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
	
	
	
