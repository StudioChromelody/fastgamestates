extends Control

@export var action_names : Array[String]

@onready var btn_container = $ScrollContainer/Btn_container


func _enter_tree() -> void:
	call_deferred("initialize")


func initialize() -> void:
	
	for a in action_names:
		
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = a.replace("_", " ").capitalize()
		label.custom_minimum_size.x = 150.0
		
		var remap_btn = RemapButton.new()
		remap_btn.action = a
		remap_btn.custom_minimum_size = Vector2(200.0, 50.0)
		
		hbox.add_child(label)
		hbox.add_child(remap_btn)
		btn_container.add_child(hbox)
