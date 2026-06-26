extends Node3D

@onready var anim: AnimationPlayer = $"../AnimationPlayer"

func _ready():
	# --- Lógica da Animação Original ---
	if anim != null:
		if anim.has_animation("Take 001"):
			var current_anim = anim.get_animation("Take 001")
			current_anim.loop_mode = Animation.LOOP_LINEAR
			
			anim.speed_scale = 2.5
			anim.play("Take 001")
	
	# --- Busca as malhas "0" e "02" recursivamente ---
	var mesh_node_0 = find_child("0", true, false) as MeshInstance3D
	if mesh_node_0 != null:
		aplicar_transparencia(mesh_node_0)
	else:
		print("Aviso: Não foi possível encontrar a malha '0'.")
		
	var mesh_node_02 = find_child("02", true, false) as MeshInstance3D
	if mesh_node_02 != null:
		aplicar_transparencia(mesh_node_02)
	else:
		print("Aviso: Não foi possível encontrar a malha '02'.")

func aplicar_transparencia(mesh_instance: MeshInstance3D):
	# Pega o material atual da superfície 0
	var mat = mesh_instance.get_active_material(0)
	
	# Verifica se o material existe e é um material 3D padrão
	if mat and mat is BaseMaterial3D:
		# Duplica o material para não afetar o arquivo original importado
		var novo_mat = mat.duplicate()
		
		# Força o modo de transparência
		novo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		
		# Pega a cor atual do material
		var cor = novo_mat.albedo_color
		
		# Deixa a cor mais clara misturando com branco (0.0 a 1.0)
		cor = cor.lerp(Color.WHITE, 0.4) 
		
		# Define o Alpha (Transparência) - 0.0 é invisível, 1.0 é sólido
		cor.a = 0.6 
		
		# Aplica a nova cor
		novo_mat.albedo_color = cor
		
		# Opcional: Força brilho e reflexo para parecer mais com água
		novo_mat.roughness = 0.1
		novo_mat.metallic = 0.3
		
		# Aplica o material modificado de volta na malha
		mesh_instance.set_surface_override_material(0, novo_mat)
