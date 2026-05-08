extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RosesPanel/RosesLabel.text = str(0)
	$HeartPanel/HeartLabel.text = str(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# $RosesLabel.text = str(Global.roses)
	pass
