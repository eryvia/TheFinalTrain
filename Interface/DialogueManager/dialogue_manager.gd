extends Control

signal dialogue_ended

@onready var dialogue_text = $Panel/TextDialogue

var dialogue_lines: Array = []
var dialogue_index: int = 0
var is_active: bool = false

func _ready() -> void:
	self.visible = false

func start_dialogue(lines, name): 
	dialogue_lines = lines
	dialogue_index = 0
	is_active = true
	self.visible = true
	#dialogue_text.visible = true
	_show_current_line()
	
func _show_current_line() -> void:
	dialogue_text.text = dialogue_lines[dialogue_index]
	
func _advance() -> void:
	dialogue_index += 1
	if dialogue_index >= dialogue_lines.size():
		_end_dialogue()
	else:
		_show_current_line()

func _end_dialogue() -> void:
	is_active = false
	dialogue_lines = []
	dialogue_index = 0
	self.visible = false
	dialogue_ended.emit()
	
func _process(delta: float) -> void:
	if not is_active:
		return
	if Input.is_action_just_pressed("advance_dialogue"):
		_advance()
