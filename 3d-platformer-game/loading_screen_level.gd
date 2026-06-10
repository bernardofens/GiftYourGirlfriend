extends Control

@onready var progress_bar = $ProgressBar

var scene_path: String
var minimum_time_passed: bool = false

func _ready() -> void:
	# Pega o caminho salvo no global e inicia o carregamento na memória
	scene_path = Global.next_scene_path
	ResourceLoader.load_threaded_request(scene_path)
	
	# Tempo mínimo de 1.5 segundos para a tela ficar visível e o jogador 
	# conseguir ler "Você venceu!" e ver as artes bonitas.
	await get_tree().create_timer(1.5).timeout
	minimum_time_passed = true

func _process(_delta: float) -> void:
	var progress = [] 
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = progress[0] * 100
		
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		progress_bar.value = 100
		
		# Quando carregar 100% E passar o tempo do timer, muda a cena
		if minimum_time_passed:
			set_process(false) 
			var packed_scene = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(packed_scene)
			
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Erro: Não foi possível carregar a cena!")
		set_process(false)
