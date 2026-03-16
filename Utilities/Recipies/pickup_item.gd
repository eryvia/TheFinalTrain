class_name PickupItem
extends Interactable

@export var item_id: String

func _ready():
	interaction_label = "Pick up"

func interact(player) -> void:
	player.add_to_inventory(item_id)
	queue_free()
