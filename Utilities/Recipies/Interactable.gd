class_name Interactable
extends Node3D

var name_index: String
var interaction_label: String = "Interact"
var is_enabled: bool = true
var marker: Marker3D

func interact(player) -> void:
	pass

func get_label() -> String:
	return interaction_label

func reset_label() -> void:
	interaction_label = "Interact"
