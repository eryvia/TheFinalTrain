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
var current_day = 1

func advance_day(days):
	current_day = days[current_day + 1]

func day_one() -> void:
	pass
