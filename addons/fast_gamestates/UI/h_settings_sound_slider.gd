@tool
extends HSlider

@export_category("General")
@export var settings_section = "Audio"
@export var settings_name = "Audio"
@export var display_name = "Audio"
@export var bus_name = "Master"

@export_category("Behaviour")
@export var log_curve = 3.0
@export var range = Vector2(-60.0, 15.0)



func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
		
	Gamestate.register_setting(settings_section, settings_name, self.value)
	self.value = Gamestate.get_setting(settings_name)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), value_to_decibel(self.value))
	
	self.value_changed.connect(_on_value_changed)


func value_to_decibel(p_value: float) -> float:
	var remap_value_s1 = remap(p_value, self.min_value, self.max_value, 0, 1.0)
	var exponentaited_remap = 1 - pow(1 - remap_value_s1, log_curve)
	var remap_value_s2 = remap(exponentaited_remap, 0.0, 1.0, range.x, range.y)
	return remap_value_s2


func _on_value_changed(p_value: float) -> void:
	Gamestate.change_setting(settings_name, p_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), value_to_decibel(p_value))
