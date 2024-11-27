@tool
extends Button


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		pressed.connect(_on_quit_button_pressed)


func _on_quit_button_pressed() -> void:
	Gamestate.exit_game()
