@tool
extends EditorPlugin

const AL_NAME_GAMESTATE = "Gamestate"

var dock_settings
var dock_menus


func _enter_tree() -> void:
	dock_settings = preload("res://addons/fast_gamestates/docks/fast_game_states_settings.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock_settings)
	dock_menus = preload("res://addons/fast_gamestates/docks/fast_game_states_menus.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock_menus)
	add_autoload_singleton(AL_NAME_GAMESTATE, "res://addons/fast_gamestates/gamestate.gd")
	
	
	add_custom_type("StartButton", "Button", preload("res://addons/fast_gamestates/UI/start_button.gd"), null)
	add_custom_type("QuitButton", "Button", preload("res://addons/fast_gamestates/UI/quit_button.gd"), null)
	add_custom_type("ExitPauseButton", "Button", preload("res://addons/fast_gamestates/UI/exit_pause_button.gd"), null)
	add_custom_type("RemapButton", "Button", preload("res://addons/fast_gamestates/UI/remap_button.gd"), null)
	
	add_custom_type("AudioSettingsCheckBox", "CheckBox", preload("res://addons/fast_gamestates/UI/cb_audio_settings.gd"), null)
	add_custom_type("AudioSettingsHSlider", "HSlider", preload("res://addons/fast_gamestates/UI/h_settings_sound_slider.gd"), null)


func _exit_tree() -> void:
	remove_control_from_docks(dock_settings)
	remove_control_from_docks(dock_menus)
	remove_autoload_singleton(AL_NAME_GAMESTATE)
	
	
	remove_custom_type("AudioSettingsHSlider")
	remove_custom_type("AudioSettingsCheckBox")
	
	remove_custom_type("RemapButton")
	remove_custom_type("ExitPauseButton")
	remove_custom_type("QuitButton")
	remove_custom_type("StartButton")
