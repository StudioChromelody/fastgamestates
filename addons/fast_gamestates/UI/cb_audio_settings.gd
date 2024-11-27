@tool
extends CheckBox

@export_category("General")
@export var settings_section = "Audio"
@export var settings_name = "Audio"
@export var bus_name = "Master"


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	Gamestate.register_setting(settings_section, settings_name, self.button_pressed)
	self.set_pressed_no_signal(true)
	self.button_pressed = Gamestate.get_setting(settings_name)
	
	self.toggled.connect(_on_value_changed)


func _on_value_changed(toggled_on: bool) -> void:
	Gamestate.change_setting(settings_name, toggled_on)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus_name), !toggled_on)
