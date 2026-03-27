extends Control

@onready var VBOXc = $Panel/VBoxContainer
@onready var selections = []
var selection_index = 0
var current_selection = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selections = VBOXc.get_children()
	
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		_get_game_scene(current_selection)
	
	if Input.is_action_just_pressed("ui_down"):
		selection_index + 1
		if selection_index > selections.len():
			selection_index = 0
		current_selection = [selection_index]
		
	if Input.is_action_just_pressed("ui_up"):
		selection_index - 1 
		current_selection = [selection_index]
		
func _process(delta: float) -> void:
	pass

func _get_game_scene(selected): 
	if selected in selections:
		selections[selected]
