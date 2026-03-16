class_name Book
extends Interactable

@export var item_id: String
var label_index := 0
var labels = [
	"hello",
	"newHello"
]

func _ready():
	interaction_label = "Pick up"

func interact(player) -> void:
	label_index += 1
	if label_index < labels.len():
		queue_free()
	player.add_to_inventory(item_id)
	#queue_free()

func get_label():
	var label = labels[label_index]
	return label
	
