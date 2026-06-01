extends CanvasLayer

@onready var heart_label = $Control/HeartPanel/HeartLabel
@onready var roses_label = $Control/RosesPanel/RosesLabel
@onready var roses_panel = $Control/RosesPanel
@onready var chocolate_label = $Control/ChocolatePanel/ChocolateLabel
@onready var win_screen = $Control/YouWinPanel
@onready var chocolate_panel = $Control/ChocolatePanel
@onready var heart3 = $Control/HeartPanel/Heart3
@onready var heart2 = $Control/HeartPanel/Heart2
@onready var heart1 = $Control/HeartPanel/Heart1

# --- NOVA REFERÊNCIA DA BARRA DE ESTAMINA ---
@onready var stamina_bar = $Control/StaminaBar 
# --------------------------------------------

func _ready() -> void:
	# Define o valor máximo da barra logo que o jogo começa
	stamina_bar.max_value = Global.max_stamina

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
