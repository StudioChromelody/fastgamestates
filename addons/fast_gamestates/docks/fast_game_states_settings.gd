@tool
extends Control

@onready var timer: Timer = $Timer


func _ready() -> void:
	call_deferred("initialize")


func initialize() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	load_settings()


func _schedule_save() -> void:
	timer.stop()
	timer.start(2.0)


func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("general", "rootnode", $VBoxContainer/Rootnode_Settings/TextEdit.text)
	config.set_value("general", "startup_menu", $VBoxContainer/StartupMenu_Settings/TextEdit.text)
	config.set_value("general", "load_game_in_bg", $VBoxContainer/LoadGameOnStartup_Settings/VBoxContainer/CheckBox.button_pressed)
	config.set_value("general", "gamecontroler", $VBoxContainer/LoadGameOnStartup_Settings/VBoxContainer/TextEdit.text)
	config.set_value("general", "game_settings_path", $VBoxContainer/GameSettingsPath_Settings/TextEdit.text)
	config.save(Gamestate.SETTINGS_CONFIG_PATH)


func load_settings() -> void:
	var settings = Gamestate.load_plugin_settings()
	if settings.size() < 5:
		push_error("[FastGameStates Error] Could not load plugin settings. Try to delete the settings file and restart the plugin.")
		return
	$VBoxContainer/Rootnode_Settings/TextEdit.text = settings[0]
	$VBoxContainer/StartupMenu_Settings/TextEdit.text = settings[1]
	$VBoxContainer/LoadGameOnStartup_Settings/VBoxContainer/CheckBox.button_pressed = settings[2]
	$VBoxContainer/LoadGameOnStartup_Settings/VBoxContainer/TextEdit.text = settings[3]
	$VBoxContainer/GameSettingsPath_Settings/TextEdit.text = settings[4]


func _on_timer_timeout() -> void:
	print("[FastGameStates Info] Plugin settings saved!")
	save_settings()
