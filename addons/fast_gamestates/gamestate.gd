@tool
extends Node

class Menu:
	var id: int
	var name: String
	var scene_path: String
	var process_mode: int
	var can_pause_game: bool

static func create_menu(id: int, name: String) -> Menu:
	var m = Menu.new()
	m.id = id
	m.name = name
	m.process_mode = 1
	m.can_pause_game = false
	return m


class Setting:
	var section: String
	var name: String
	var description: String # TODO
	var initial_value: Variant
	var value: Variant


const SETTINGS_CONFIG_PATH = "res://addons/fast_gamestates/files/settings.cfg"
const SETTINGS_MENUS_PATH = "res://addons/fast_gamestates/files/menus.cfg"

var game_settings_path = "user://settings.txt"

var root_node
var startup_menu_name
var load_game_in_bg
var gamecontroler_scene_path: String

var available_states = {}
var menus = {}
var settings = {}
var shared_values = {}

var current_state = -1
var loaded_menu
var gamecontroler_scene
var gamecontroler_instance



func _ready() -> void:
	if Engine.is_editor_hint():
		return
	call_deferred("initialize")


func get_menu_from_name(name: String) -> Menu:
	for m in menus:
		if menus[m].name == name:
			return menus[m]
	return null


func initialize() -> void:
	load_plugin_settings()
	init_menus()
	root_node = get_tree().root.get_node(root_node)
	if not gamecontroler_scene_path.is_empty():
		gamecontroler_scene = load(gamecontroler_scene_path)
	
	load_game_settings()
	if load_game_in_bg and gamecontroler_scene:
		load_game(gamecontroler_scene, 0)
	if startup_menu_name:
		load_menu(startup_menu_name)


func load_game(p_gamecontroler: PackedScene, idx: int=-1) -> void:
	if gamecontroler_instance:
		push_error("[FastGameStates ERROR]: Cannot create a new gamecontroler while another one is loaded. Use \"Gamestate.unload_game()\" to unload the current gamecontroler")
		return
	gamecontroler_instance = p_gamecontroler.instantiate()
	root_node.add_child(gamecontroler_instance)
	if idx >= 0:
		root_node.move_child(gamecontroler_instance, idx)


func start_game(p_gamecontroler: PackedScene = gamecontroler_scene) -> void:
	if not gamecontroler_instance and p_gamecontroler:
		load_game(p_gamecontroler)
	if loaded_menu:
		unload_menu()
	if gamecontroler_instance.has_method("start_game"):
		gamecontroler_instance.start_game()


func reset_game(reload: bool=false, idx: int=0) -> void:
	unload_game()
	if load_game_in_bg or reload:
		call_deferred("load_game", gamecontroler_scene, idx)


func unload_game() -> void:
	if gamecontroler_instance:
		root_node.get_node(root_node.get_path_to(gamecontroler_instance)).queue_free()
		gamecontroler_instance = null


func compute_process_mode(mode: int) -> int:
	match mode:
		0:
			return PROCESS_MODE_PAUSABLE
		1:
			return PROCESS_MODE_WHEN_PAUSED
		2:
			return PROCESS_MODE_ALWAYS
	return -1


func load_menu(menu_name: String) -> void:
	if loaded_menu:
		unload_menu()
	var m = get_menu_from_name(menu_name)
	if m.can_pause_game:
		get_tree().paused = true
	loaded_menu = load(m.scene_path).instantiate()
	loaded_menu.process_mode = compute_process_mode(m.process_mode)
	root_node.add_child(loaded_menu)


func unload_menu() -> void:
	root_node.get_node(root_node.get_path_to(loaded_menu)).queue_free()
	loaded_menu = null
	get_tree().paused = false


# # # # # # # # # # # # # # #
# 			Settings		#
# # # # # # # # # # # # # # #


func register_setting(p_section: String, p_name: String, p_initial_value: Variant) -> void:
	if settings.keys().has(p_name):
		#change_setting(p_name, p_initial_value)
		return
	var s = Setting.new()
	s.section = p_section
	s.name = p_name
	s.initial_value = p_initial_value
	s.value = p_initial_value
	settings[p_name] = s


func _check_setting(p_name: String) -> bool:
	if settings.has(p_name):
		return true
	push_error("[FastGameStates ERROR] Setting \"", p_name, "\" does not exist. Please register first using \"Gamestate.register_setting\"")
	return false


func change_setting(p_name: String, p_new_value: Variant) -> void:
	if not _check_setting(p_name):
		return
	settings[p_name].value = p_new_value


func get_setting(p_name: String) -> Variant:
	if not _check_setting(p_name):
		return null
	return settings[p_name].value


func unregister_setting(p_name: String) -> void:
	if not _check_setting(p_name):
		return
	settings.erase(p_name)


# TODO: find a better way for resetting remap buttons
func reset_input_map_settings() -> void:
	for key in settings:
		if not settings[key].section == "_Input":
			continue
		settings[key].value.reset()


# TODO: create a settings page from the registered settings
func create_settings_page() -> PackedScene:
	return null


func save_game_settings() -> void:
	var settings_file = FileAccess.open(game_settings_path, FileAccess.WRITE)
	if !settings_file:
		push_error("[FastGameStates Error] Could not open settings file. Settings could not be saved!")
		return

	for key in settings:
		settings_file.store_var(settings[key].section)
		settings_file.store_var(settings[key].name)
		settings_file.store_var(settings[key].description)
		settings_file.store_var(settings[key].initial_value)
		settings_file.store_var(settings[key].value)


func load_game_settings() -> void:
	var settings_file = FileAccess.open(game_settings_path, FileAccess.READ)
	if !settings_file:
		push_error("[FastGameStates Error] Could not open settings file. Settings could not be loaded!")
		return
	
	while settings_file.get_position() < settings_file.get_length():
		var s_section = settings_file.get_var()
		var s_name = settings_file.get_var()
		var s_description = settings_file.get_var()
		var s_initial_value = settings_file.get_var()
		var s_value = settings_file.get_var()
		register_setting(s_section, s_name, s_initial_value)
		change_setting(s_name, s_value)


# # # # # # # # # # # # # # #
# 		Shared Values		#
# # # # # # # # # # # # # # #


func register_shared_value(p_name: String, p_initial_value: Variant) -> void:
	if shared_values.keys().has(p_name):
		change_shared_value(p_name, p_initial_value)
		return
	var s = Setting.new()
	s.name = p_name
	s.initial_value = p_initial_value
	s.value = p_initial_value 
	shared_values[p_name] = s


func _check_shared_value(p_name: String) -> bool:
	if not shared_values.keys().has(p_name):
		push_error("[FastGameStates ERROR] Shared Value \"", p_name, "\" does not exist. Please register first using \"Gamestate.register_shared_value\"")
		return false
	return true


func change_shared_value(p_name: String, p_new_value: Variant) -> void:
	if not _check_shared_value(p_name):
		return
	shared_values[p_name].value = p_new_value


func get_shared_value(p_name: String) -> Variant:
	if not _check_shared_value(p_name):
		return null
	return shared_values[p_name].value


func unregister_shared_value(p_name: String) -> void:
	if not _check_shared_value(p_name):
		return
	shared_values.erase(p_name)


# # # # # # # # # # # # # # #
# 			Misc			#
# # # # # # # # # # # # # # #


func load_plugin_settings() -> Array:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_CONFIG_PATH)
	if err != OK:
		return []
	root_node = config.get_value("general", "rootnode")
	startup_menu_name = config.get_value("general", "startup_menu")
	load_game_in_bg = config.get_value("general", "load_game_in_bg")
	gamecontroler_scene_path = config.get_value("general", "gamecontroler")
	game_settings_path = config.get_value("general", "game_settings_path")
	return [root_node, startup_menu_name, load_game_in_bg, gamecontroler_scene_path, game_settings_path]


func init_menus() -> void:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_MENUS_PATH)
	if err != OK:
		return
	for i in config.get_sections():
		var m = Menu.new()
		m.id = config.get_value(i, "id")
		m.name = config.get_value(i, "name")
		m.scene_path = config.get_value(i, "scene_path")
		m.process_mode = config.get_value(i, "process_mode")
		m.can_pause_game = config.get_value(i, "can_pause_game")
		menus[int(i)] = m


func delete_menu(id: int) -> void:
	menus.erase(id)
	var count = 0
	var keys = menus.keys()
	keys.sort()
	for m in keys:
		menus[m].id = count
		menus[count] = menus[m]
		count += 1
	menus.erase(keys.back())


func exit_game():
	#save_game_settings()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game_settings()
