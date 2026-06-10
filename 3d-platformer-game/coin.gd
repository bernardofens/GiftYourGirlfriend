extends Area3D

const ROT_SPEED = 2 # number of degrees the coin rotates every frame

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))

func _on_body_entered(body: Node3D) -> void:
	# Apenas adiciona os itens dependendo do nível
	if Global.level == 1:
		Global.roses += 1
	else:
		Global.chocolates += 1
		
	# A lógica de mudar de fase não fica mais aqui! O level_1.gd vai cuidar disso.
		
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	$AnimationPlayer.play("bounce")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
