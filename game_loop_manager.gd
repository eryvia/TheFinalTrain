extends Node
class_name DayManager

enum GameLoopState { MORNING, INTERMISSION, EVENING }
var days = {
	1 : "first",
	2 : "second",
	3 : "third",
}
var current_day = 1

func advance_day(days):
	current_day = days[current_day + 1]
