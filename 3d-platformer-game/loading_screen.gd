extends Control

@onready var progress_bar = $ProgressBar

var scene_path: String
var minimum_time_passed: bool = false

func _ready() -> void:
	scene_path = Global.next_scene_path
	ResourceLoader.load_threaded_request(scene_path)
	
	# Cria um timer de 0.8 segundos (você pode alterar esse valor)
	# Isso garante que a tela de loading apareça por pelo menos esse tempo
	await get_tree().create_timer(0.8).timeout
	minimum_time_passed = true

func _process(_delta: float) -> void:
	var progress = [] 
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = progress[0] * 100
		
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		# Garante que a barra mostre 100% quando terminar
		progress_bar.value = 100
		
		# Só permite trocar de cena se o nível já carregou E o tempo mínimo já passou
		if minimum_time_passed:
			set_process(false) 
			var packed_scene = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(packed_scene)
			
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Erro: Não foi possível carregar a cena!")
		set_process(false)
