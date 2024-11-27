@tool
class_name RemapButton
extends Button

@export var awaiting_text: String = "Awaiting Input ..."
@export var action: String


var initial_event

func _init() -> void:
	toggle_mode = true


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	set_process_unhandled_input(false)
	update_text()
	return
	#TODO: find a way to make it work (when changing an input
	# it is the initial_event the next time the menu is opened)
	initial_event = InputMap.action_get_events(action)[0]
	Gamestate.register_setting("_Input", "input_" + action, self)


func reset() -> void:
	set_input_action_event(initial_event)


func set_input_action_event(event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	self.button_pressed = false
	update_text()


func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		self.text = awaiting_text
		self.release_focus()
	else:
		update_text()
		self.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and self.button_pressed:
		set_input_action_event(event)


func update_text() -> void:
	var action_events = InputMap.action_get_events(action)
	if len(action_events) > 0:
		self.text = "%s" % action_events[0].as_text()
	else:
		self.text = "N/A"
