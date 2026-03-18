class_name God
extends Interactable

@onready var npc_marker = $Mark

const DIALOGUE = [
	"Hey, you shouldn't be here.",
	"I'm warning you...",
    "Last chance."
]
var label = ["just a old dude", "talk to"]

func _ready():
	interaction_label = "Talk to"
	name_index = "God"
	marker = npc_marker

func interact(player) -> void:
	player.focus_camera_on(npc_marker)
	DialogueManager.start_dialogue(DIALOGUE, name_index)
	#SignalBus.start_dialogue.emit(self, player)
	pass
	
func get_label() -> String:
	return interaction_label
