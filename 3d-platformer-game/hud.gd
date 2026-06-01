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
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	roses_label.text = str(Global.roses)
	chocolate_label.text = str(Global.chocolates)
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
		
	pass
