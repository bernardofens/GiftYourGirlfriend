extends Area3D

const ROT_SPEED = 2 # number of degrees the coin rotates every frame

# A variável @export var hud foi removida pois o coin não precisa mais gerenciar a UI

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))

func _on_body_entered(body: Node3D) -> void:
	if Global.level == 1:
		Global.roses += 1
		
		# restart level (could change it later on)
		if Global.roses >= Global.NUM_ROSES_TO_WIN:
			Global.level = 2
			get_tree().change_scene_to_file("res://level_2.tscn")
	else:
		Global.chocolates += 1
		
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	$AnimationPlayer.play("bounce")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
