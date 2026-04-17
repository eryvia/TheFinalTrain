class_name Bed
extends Interactable

func _ready():
	SignalBus.SleepToNextDay.connect(on_sleep_to_next_day)
	interaction_label = "go sleep?"
	name_index = "Bed"

func interact(player) -> void:
	SignalBus.SleepToNextDay.emit()
	#player.focus_camera_on(mirror_marker)
	pass
	
func get_label() -> String:
	return interaction_label

func on_sleep_to_next_day() -> void:
	GameLoopManager.advance_day()
	pass
