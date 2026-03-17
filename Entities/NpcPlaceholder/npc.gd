class_name God
extends Interactable

const DIALOGUE = [
	"Hey, you shouldn't be here.",
	"I'm warning you...",
    "Last chance."
]
var label = ["just a old dude", "talk to"]

func _ready():
	interaction_label = "Talk to"
	name_index = "God"

func interact(player) -> void:
	DialogueManager.start_dialogue(DIALOGUE, name_index)
	#SignalBus.start_dialogue.emit(self, player)
	pass

func get_label() -> String:
	return interaction_label
