extends Area3D

@export var speed: float = 16.0 # Aumentado de 11.5 para 16.0
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Destrói o projétil após 4 segundos se não acertar em nada
	get_tree().create_timer(4.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if direction != Vector3.ZERO:
		# Movimento retilíneo direto
		global_position += direction * speed * delta

func set_direction(dir: Vector3) -> void:
	direction = dir.normalized()

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
	
	queue_free()
