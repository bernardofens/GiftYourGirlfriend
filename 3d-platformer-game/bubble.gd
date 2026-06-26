extends Node3D

# Velocidade de rotação. 
# O @export faz essa variável aparecer no Inspector para você testar valores mais rápido.
@export var rotation_speed: float = 1.5 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# O método rotate_y faz a bolha girar em torno do próprio eixo vertical (Y).
	# Multiplicar pelo 'delta' garante que a velocidade seja constante 
	# independente da taxa de quadros (FPS) do computador.
	rotate_y(rotation_speed * delta)
	
	# DICA: Se quiser que ela gire em outras direções também, 
	# remova o '#' das linhas abaixo:
	rotate_x(rotation_speed * delta) # Gira para frente/trás
	rotate_z(rotation_speed * delta) # Gira para os lados
