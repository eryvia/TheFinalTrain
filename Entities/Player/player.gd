extends CharacterBody3D

@export var move_speed := 7.5
@export var accel := 18.0
@export var air_accel := 6.0
@export var friction := 22.0

@export var gravity := 24.0
@export var jump_height := 1.2
@export var run_speed := 1.6

@export var coyote_time := 0.12         
@export var jump_buffer_time := 0.12

@export var mouse_sens := 0.08

@onready var cam_pivot := $CamPivot
@onready var cam := $CamPivot/Camera3D

#Checings 
var isRunning:bool = false

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		cam_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	var input_2d := Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x

	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	var wish_dir := (right * input_2d.x + forward * input_2d.y)
	if wish_dir.length() > 0:
		wish_dir = wish_dir.normalized()

	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = max(0.0, _coyote_timer - delta)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = max(0.0, _jump_buffer_timer - delta)
		
	var speed := move_speed
	
	if Input.is_action_pressed("run"):
		speed *= run_speed

	var current_h := Vector3(velocity.x, 0, velocity.z)
	var target_h := wish_dir * speed


	var used_accel := accel if is_on_floor() else air_accel

	current_h = current_h.move_toward(target_h, used_accel * delta)

	if is_on_floor() and wish_dir == Vector3.ZERO:
		current_h = current_h.move_toward(Vector3.ZERO, friction * delta)

	velocity.x = current_h.x
	velocity.z = current_h.z

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		
		if velocity.y < 0:
			velocity.y = -1.0

	if _jump_buffer_timer > 0 and _coyote_timer > 0:
		_jump_buffer_timer = 0
		_coyote_timer = 0
		# Physics: v = sqrt(2*g*h)
		velocity.y = sqrt(2.0 * gravity * jump_height)

	move_and_slide()
