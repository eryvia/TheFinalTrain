class_name Interactable
extends Node3D

var interaction_label: String = "Interact"
var is_enabled: bool = true

func interact(player) -> void:
	pass

func get_label() -> String:
	return interaction_label
