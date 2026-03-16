class_name NPC
extends Interactable

func _ready():
	interaction_label = "Talk"

func interact(player) -> void:
	#SignalBus.start_dialogue.emit(self, player)
	pass
