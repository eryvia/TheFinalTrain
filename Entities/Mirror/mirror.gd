class_name Mirror
extends Interactable

@onready var mirror_marker = $Mark

func _ready():
	interaction_label = "See yourself"
	name_index = "Mirror"

func interact(player) -> void:
	player.focus_camera_on(mirror_marker)
	pass
	
func get_label() -> String:
	return interaction_label
