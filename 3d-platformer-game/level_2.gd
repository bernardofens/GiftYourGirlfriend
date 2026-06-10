extends Node3D

func _ready() -> void:
	# 1. ISSO ARUMA O BUG: Avisa o HUD que agora estamos oficialmente no Level 2
	Global.level = 2
	
	# 2. Reseta os chocolates para o início da fase
	Global.chocolates = 0
	
	# 3. Recupera a vida do jogador para começar o nível bem (opcional)
	Global.hearts = 3 

# O Nível 2 não precisa de lógica no _process, pois o seu 'hud.gd' 
# já verifica sozinho quando os chocolates chegam a 5 para vencer o jogo!
func _process(_delta: float) -> void:
	pass
