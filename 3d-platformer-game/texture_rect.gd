extends TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cancel_event := InputEventAction.new()
			cancel_event.action = "ui_cancel"
			cancel_event.pressed = true
			cancel_event.strength = 1.0
			Input.parse_input_event(cancel_event)

			var release_event := InputEventAction.new()
			release_event.action = "ui_cancel"
			release_event.pressed = false
			release_event.strength = 0.0
			Input.parse_input_event(release_event)
