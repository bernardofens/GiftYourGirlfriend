extends CanvasLayer

@onready var heart_label = $HeartPanel/HeartLabel
@onready var roses_label = $RosesPanel/RosesLabel
@onready var chocolate_label = $ChocolatePanel/ChocolateLabel
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	roses_label.text = str(Global.roses)
	heart_label.text = str(Global.hearts)
	chocolate_label.text = str(Global.chocolates)
	pass
