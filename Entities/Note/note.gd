class_name Note
extends Interactable

@export var item_id: String
var label_index := 0
var labels = ["old note","read"]
var text = ["just old sayings", "dwad", "nawdndwaaddddddddddddddddddddddddddddddddddddddd"]

func _ready():
	interaction_label = "Pick up"
	is_enabled = true

func interact(player) -> void:
	label_index += 1
	if label_index >= labels.size():
		is_enabled = false
		read(text)
		player._put_player_to_stop()

func get_label() -> String:
	if label_index >= labels.size():
		return ""
	return labels[label_index]
	
func reset_label() -> void:
	label_index = 0
	
func read(text) -> void:
	ReadingManager.recieve_text(text)
	pass
