extends Node
class_name DayManager

enum GameLoopState { MORNING, INTERMISSION, EVENING }
var monolog_lines = [
	"how long was I asleep for..",
	"should make some food."
]

var days = {
	1 : "first",
	2 : "second",
	3 : "third",
	4 : "fourth",
	5 : "sedawd",
	6 : "thidw",
}

var current_day_index = 1
var current_day = days[current_day_index]
var current_hour = 0

func advance_day():
	if current_day_index >= days.size():
		return  
	current_day_index += 1
	current_day = days[current_day_index]
	get_tree().change_scene_to_file(Global.GAME_SCENES["NextDayTransition"])

func day_one() -> void:
	pass
