extends CanvasLayer

@onready var heart_label = $Control/HeartPanel/HeartLabel
@onready var roses_label = $Control/RosesPanel/RosesLabel
@onready var roses_panel = $Control/RosesPanel
@onready var chocolate_label = $Control/ChocolatePanel/ChocolateLabel
@onready var win_screen = $Control/YouWinPanel
@onready var chocolate_panel = $Control/ChocolatePanel
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	roses_label.text = str(Global.roses)
	heart_label.text = str(Global.hearts)
	chocolate_label.text = str(Global.chocolates)
	if Global.chocolates >= 5:
		win_screen.visible = true
	if Global.level == 2:
		chocolate_panel.visible = true
		roses_panel.visible = false
		
		
	pass
