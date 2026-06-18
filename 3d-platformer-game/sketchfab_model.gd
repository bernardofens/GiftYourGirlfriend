extends Node3D

# Busca o nó em toda a árvore abaixo deste nó, independente da hierarquia
@onready var anim: AnimationPlayer = $"../AnimationPlayer"

func _ready():
	if anim != null:
		if anim.has_animation("Take 001"):
			var current_anim = anim.get_animation("Take 001")
			current_anim.loop_mode = Animation.LOOP_LINEAR
			
			# Altere este valor para testar a velocidade ideal (ex: 2.5 ou 3.0)
			anim.speed_scale = 2.5
			
			anim.play("Take 001")
