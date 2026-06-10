extends Area3D

const ROT_SPEED = 2 

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))

func _on_body_entered(body: Node3D) -> void:
	if Global.level == 1:
		Global.roses += 1
	else:
		Global.chocolates += 1
		
	# Toca o efeito sonoro de coleta
	AudioManager.play_sfx(AudioManager.sfx_collect)
		
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	$AnimationPlayer.play("bounce")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
