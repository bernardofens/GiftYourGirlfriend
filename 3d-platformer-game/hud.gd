extends CanvasLayer

@onready var chocolate_panel = $Control/ChocolatePanel
@onready var heart3 = $Control/HeartPanel/Heart3
@onready var heart2 = $Control/HeartPanel/Heart2
@onready var heart1 = $Control/HeartPanel/Heart1
@onready var game_over = $Control/GameOverControl
@onready var stamina_bar = $Control/StaminaBar 
@onready var roses_label = $Control/RosesPanel/RosesLabel
@onready var win_screen = $Control/YouWinPanel
@onready var roses_panel = $Control/RosesPanel
@onready var chocolate_label = $Control/ChocolatePanel/ChocolateLabel
func _ready() -> void:
	# 1. Setup Game Over initial state and signals
	game_over.visible = false
	var player = get_tree().get_first_node_in_group("Steve")
	if player:
		player.player_died.connect(_on_player_died)
		
	# 2. Setup Stamina Bar
	if stamina_bar:
		stamina_bar.max_value = Global.max_stamina

func _on_player_died():
	# Display UI before freezing the tree execution
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over.visible = true
	get_tree().paused = true	

func _on_retry_button_pressed():
	Global.hearts = 3
	Global.chocolates = 0
	Global.roses = 0
	Global.can_take_damage = true
	get_tree().paused = false
	if Global.level == 1:
		get_tree().change_scene_to_file("res://level_1.tscn")
	else:
		get_tree().change_scene_to_file("res://level_2.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	roses_label.text = str(Global.roses)
	chocolate_label.text = str(Global.chocolates)
	
	# --- ATUALIZA A BARRA DE ESTAMINA ---
	stamina_bar.value = Global.stamina
	# ------------------------------------
	
	if Global.chocolates >= 5:
		win_screen.visible = true
	if Global.level == 2:
		chocolate_panel.visible = true
		roses_panel.visible = false
		
	if Global.hearts == 2:
		heart3.visible = false
	if Global.hearts == 1:
		heart2.visible = false 
	if Global.hearts == 0:
		heart1.visible = false 
	if Global.hearts == 3:
		heart3.visible = true
		heart2.visible = true
		heart1.visible = true
