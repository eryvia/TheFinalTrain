class_name Book
extends Interactable

@export var item_id: String
var label_index := 0
var labels = ["just a old book", "probably filled with random bs","pick up"]

func _ready():
	interaction_label = "Pick up"
	is_enabled = true

func interact(player) -> void:
	label_index += 1
	if label_index >= labels.size():
		player.add_to_inventory(item_id)
		queue_free()

func get_label() -> String:
	return labels[label_index]

func reset_label() -> void:
	label_index = 0
