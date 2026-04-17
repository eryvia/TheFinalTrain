extends Control

@onready var bg = $ColorRect
@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("fade_in")	
	pass 
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		anim.play("fade_out")
		if !anim.is_playing():
			get_tree().change_scene_to_file(Global.GAME_SCENES["TheBathroom"])
