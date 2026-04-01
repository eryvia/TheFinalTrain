extends Node
# action_state_machine.gd
enum ActionState { IDLE, LIGHTING, SMOKING, PUTTING_OUT }

var parent =  get_parent()
var current_state: ActionState = ActionState.IDLE
var state_timer: float = 0.0

func _process(delta):
	state_timer += delta
	match current_state:
		ActionState.IDLE:
			pass
		ActionState.LIGHTING:
			if state_timer >= 1.5:  # lighting animation duration
				_transition_to(ActionState.SMOKING)
		ActionState.SMOKING:
			if state_timer >= 4.0:  # smoking duration
				_transition_to(ActionState.PUTTING_OUT)
		ActionState.PUTTING_OUT:
			if state_timer >= 1.0:
				_transition_to(ActionState.IDLE)

func start_smoke():
	if current_state == ActionState.IDLE:
		_transition_to(ActionState.LIGHTING)

func interrupt():
	if current_state == ActionState.SMOKING:
		_transition_to(ActionState.PUTTING_OUT)

func _transition_to(new_state: ActionState):
	current_state = new_state
	state_timer = 0.0
	_on_enter_state(new_state)

func _on_enter_state(state: ActionState):
	pass


"""
func _on_enter_state(state: ActionState):
	match state:
		ActionState.LIGHTING:
			$AnimationPlayer.play("lighting_cigarette")
		ActionState.SMOKING:
			$AnimationPlayer.play("smoking_loop")
		ActionState.PUTTING_OUT:
			$AnimationPlayer.play("putting_out")
		ActionState.IDLE:
			$AnimationPlayer.play("idle")
			
"""
