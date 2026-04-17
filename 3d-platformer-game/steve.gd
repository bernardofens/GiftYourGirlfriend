extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 12
const SPRINT_SPEED = 9.0

var target_cam_y_rotation : float = 0.0
const CAM_ROTATION_SPEED : float = 8.0   # Ajuste para controlar a suavidade
const CAM_ROTATION_STEP : float = 30.0   # Graus por toque

var xform: Transform3D

func _physics_process(delta: float) -> void:
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Play robot animations (should be above "move_and_slide()")
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$AnimationPlayer.play("jump")
	elif is_on_floor() and input_dir != Vector2.ZERO:
		$AnimationPlayer.play("run")
	elif is_on_floor() and input_dir == Vector2.ZERO:
		$AnimationPlayer.play("idle")
	
	# Rotate the camera left/right
	# No lugar do trecho com is_action_just_pressed
	if Input.is_action_just_pressed("cam_left"):
		target_cam_y_rotation += deg_to_rad(CAM_ROTATION_STEP)
	if Input.is_action_just_pressed("cam_right"):
		target_cam_y_rotation -= deg_to_rad(CAM_ROTATION_STEP)

	# Suaviza a rotação atual em direção ao alvo
	$Camera_Controller.rotation.y = lerp_angle(
		$Camera_Controller.rotation.y,
		target_cam_y_rotation,
		CAM_ROTATION_SPEED * delta
	)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# New Vector3 direction, taking into account the user arrow inputs and the camera rotation
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Rotate the character mesh so oriented towards the direction moving to the camera
	if input_dir != Vector2(0,0):
		$Armature.rotation_degrees.y = $Camera_Controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90
	
	# Rotate the character to align with the floor (the "and input_dir != Vector2(0,0)" is optional to fix the edge movement)
	if is_on_floor():
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform, 0.3)
	elif not is_on_floor():
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.3)
	
	# Update the velocity and move the character
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Make Camera_Controller match the position of myself
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.15)
	
	# Define a velocidade atual baseada no sprint
	var current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED

	# Ao aplicar o movimento, use current_speed:
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	
func align_with_floor(floor_normal):
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()
	
	
func _ready():
	target_cam_y_rotation = $Camera_Controller.rotation.y


func _on_fall_zone_body_entered(body: Node3D) -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")
	
	
	
	
	
	
