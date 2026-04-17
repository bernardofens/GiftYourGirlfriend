extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RosesLabel.text = str(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# $RosesLabel.text = str(Global.roses)
	pass
