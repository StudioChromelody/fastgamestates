@tool
extends Button

enum PauseButtonType {RESUME_GAME, BACK_TO_MAIN_MENU}
@export var action: PauseButtonType


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		pressed.connect(_on_exit_pause_button_pressed)


func _on_exit_pause_button_pressed() -> void:
	match action:
		PauseButtonType.RESUME_GAME:
			Gamestate.unload_menu()
		PauseButtonType.BACK_TO_MAIN_MENU:
			Gamestate.reset_game()
			Gamestate.load_menu(Gamestate.startup_menu_name)
