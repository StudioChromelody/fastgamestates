@tool
extends Control

@onready var menus_overview = $MenusOverview
@onready var menus_settings = $MenusSettings

@onready var menus_settings_menu_name = $MenusSettings/Settings_MenuName/TextEdit
@onready var menus_settings_menu_scene_path = $MenusSettings/Settings_MenuPath/TextEdit
@onready var menus_settings_menu_process_mode = $MenusSettings/Settings_MenuPausable/OptionButton
@onready var menus_settings_menu_can_pause_game = $MenusSettings/Settings_MenuPausable/CheckBox

var menus_count = 0
var current_settings_page = -1


func _ready() -> void:
	call_deferred("load_menus")


func prepare_settings_page(id: int) -> void:
	if id < 0:
		return
	current_settings_page = id
	
	menus_settings_menu_name.text = Gamestate.menus[id].name
	menus_settings_menu_scene_path.text = Gamestate.menus[id].scene_path
	menus_settings_menu_process_mode.selected = Gamestate.menus[id].process_mode
	menus_settings_menu_can_pause_game.button_pressed = Gamestate.menus[id].can_pause_game


func _on_create_new_menu() -> void:
	var menu_btn = Button.new()
	menu_btn.text = "unnamed"
	menu_btn.pressed.connect(_on_to_menu.bind(menus_count))
	menus_overview.add_child(menu_btn)
	menus_overview.move_child(menu_btn, menus_count)
	
	# create new menu
	Gamestate.menus[menus_count] = Gamestate.create_menu(menus_count, "unnamed")
	
	prepare_settings_page(menus_count)
	menus_overview.visible = false
	menus_settings.visible = true
	
	menus_count += 1


func _on_back_to_overview() -> void:
	menus_overview.visible = true
	menus_settings.visible = false
	current_settings_page = -1
	save_menus()


func _on_to_menu(id: int) -> void:
	prepare_settings_page(id)
	menus_overview.visible = false
	menus_settings.visible = true


# # # # # # # # # # # # # #
# MENU SETTINGS FUNCTIONS #
# # # # # # # # # # # # # #


func _on_menuname_changed() -> void:
	Gamestate.menus[current_settings_page].name = menus_settings_menu_name.text
	menus_overview.get_child(current_settings_page).text = menus_settings_menu_name.text


func _on_menu_scenepath_changed() -> void:
	Gamestate.menus[current_settings_page].scene_path = menus_settings_menu_scene_path.text


func _on_menu_pausable_checkbox_toggled(toggled_on: bool) -> void:
	Gamestate.menus[current_settings_page].can_pause_game = toggled_on


func _on_menu_mode_item_selected(index: int) -> void:
	Gamestate.menus[current_settings_page].process_mode = index


func _on_btn_delete_pressed() -> void:
	menus_overview.get_child(current_settings_page).queue_free()
	Gamestate.delete_menu(current_settings_page)
	
	var count = 0
	for btn in menus_overview.get_children():
		if btn == menus_overview.get_node("Btn_new") or btn.is_queued_for_deletion():
			continue
		btn.pressed.disconnect(_on_to_menu)
		btn.pressed.connect(_on_to_menu.bind(count))
		count += 1
	
	menus_count -=1
	_on_back_to_overview()


func save_menus() -> void:
	var config = ConfigFile.new()
	var menus_keys_sorted = Gamestate.menus.keys()
	menus_keys_sorted.sort() 
	for i in menus_keys_sorted:
		config.set_value(str(i), "id", Gamestate.menus[i].id)
		config.set_value(str(i), "name", Gamestate.menus[i].name)
		config.set_value(str(i), "scene_path", Gamestate.menus[i].scene_path)
		config.set_value(str(i), "process_mode", Gamestate.menus[i].process_mode)
		config.set_value(str(i), "can_pause_game", Gamestate.menus[i].can_pause_game)
	config.save(Gamestate.SETTINGS_MENUS_PATH)


func load_menus() -> void:
	Gamestate.init_menus()
	
	for m in Gamestate.menus:
		var menu = Gamestate.menus[m]
		var menu_btn = Button.new()
		menu_btn.text = menu.name
		menu_btn.pressed.connect(_on_to_menu.bind(menu.id))
		menus_overview.add_child(menu_btn)
		menus_overview.move_child(menu_btn, menu.id)
	
	menus_count = Gamestate.menus.size()


func _exit_tree() -> void:
	save_menus()
