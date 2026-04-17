extends CharacterBody3D

#signal left_raycast

# --- Movement ---
@export var move_speed      := 4.5      # Slower, heavier feel
@export var run_speed_mult  := 3.2
@export var accel           := 14.0
@export var air_accel       := 4.0
@export var friction        := 20.0
@export var gravity         := 28.0
@export var jump_height     := 0.95     # Lower jumps feel grittier
@export var crouch_height  	:= -0.6
@export var coyote_time     := 0.12
@export var jump_buffer_time := 0.12
@export var crouch_buffer_time  := 0.23

# --- Mouse Look ---
@export var mouse_sens      := 0.08
@export var cam_v_min       := -80.0
@export var cam_v_max       := 75.0

# --- Head Bob (Puppet Combo style: heavy, rhythmic) ---
@export var bob_freq_walk   := 1.9      # Steps per second
@export var bob_freq_run    := 2.8
@export var bob_amp_y       := 0.055    # Vertical
@export var bob_amp_x       := 0.025    # Side sway
@export var bob_lerp        := 8.0      # How fast bob fades in/out
 
# --- Camera Effects ---
@export var tilt_amount     := 3.5      # Roll on strafe
@export var tilt_lerp       := 7.0
@export var land_dip        := 0.12     # Camera punch-down on landing
@export var land_recover    := 6.0
@export var breathe_amp     := 0.003    # Idle breathing
@export var breathe_speed   := 0.6

@onready var cam_pivot : Node3D   = $CamPivot
@onready var cam       : Camera3D = $CamPivot/Camera3D
@onready var ray = $CamPivot/Camera3D/RayCast3D
@onready var label_crosshair: Label = $CanvasLayer/CenterContainer/VBoxContainer/Label

var raycast_marker: Marker3D
var current_target = null 

#Checkings
var isPlayerInteracting = false
var isPlayerStoppedOverControl = false
var isPlayerStopped = false
var rayIsColliding = false
var dialogueState = false
var _camera_locked := false
var cig_state := false
var _original_basis: Basis

var Tasks = [
		
]

var _coyote_timer       := 0.0
var _jump_buffer_timer  := 0.0
var _crouch_buffer_timer  := 0.0
var _bob_timer          := 0.0
var _bob_current        := Vector3.ZERO
var _bob_target         := Vector3.ZERO
var _was_on_floor       := true
var _land_dip_current   := 0.0
var _cam_base_y         := 0.0          # Original cam local Y
var _breathe_timer      := 0.0
var _input_dir          := Vector2.ZERO  # Cached for tilt

var Items = []

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(release_camera)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_cam_base_y = cam.position.y
	
func _put_player_to_stop() -> void:
	isPlayerStopped = true
	pass
	
func realese_movement() -> void:
	if isPlayerStopped:
		isPlayerStopped = false
	pass
	
func check_movement_checkings():
	if isPlayerStopped || _camera_locked:
		return true

func _display() -> void: 
	pass
	
func add_to_inventory(item_id):
	Items.append(item_id)

func get_raycast_target():
	if ray.is_colliding():
		var new_target = ray.get_collider()
		if current_target != null and current_target != new_target:
			current_target.reset_label()
		current_target = new_target
		return ray.get_collider()
	else:
		if current_target != null:
			current_target.reset_label()
			current_target = null
	return null
		
func _show_label(label_text):
	label_crosshair.text = label_text
	
func _process_interaction():
	var target = get_raycast_target()
	if target is Interactable and target.is_enabled:
		if target.has_method("get_pointer"):
			raycast_marker = target.get_pointer()
			print("got marker, %s" % raycast_marker)
		_show_label(target.get_label())
		if Input.is_action_just_pressed("interact"):
			target.interact(self)
	else:
		_show_label("")

func _process(delta: float) -> void:
	_process_interaction()
	
func focus_camera_on(marker: Marker3D) -> void:
	
	_camera_locked = true
	_original_basis = cam.global_basis

	var tween = create_tween()
	tween.tween_method(_look_toward.bind(marker), 0.0, 1.0, 0.4)

func _look_toward(weight: float, marker: Marker3D) -> void:
	var target_dir = (marker.global_position - cam.global_position).normalized()
	var target_basis = Basis.looking_at(target_dir, Vector3.UP)
	cam.global_basis = _original_basis.slerp(target_basis, weight)

func release_camera() -> void:
	#var tween = create_tween()	
	cam.global_basis = _original_basis
	_camera_locked = false

func _input(event: InputEvent) -> void:
	if check_movement_checkings():
		return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		cam_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		cam_pivot.rotation.x = clamp(
			cam_pivot.rotation.x,
			deg_to_rad(cam_v_min),
			deg_to_rad(cam_v_max)
		)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)
		
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("end"):
		release_camera() 
		realese_movement()
	
	if check_movement_checkings():
		return
		
	_input_dir = Input.get_vector("move_left", "move_right", "move_back", "move_forward")

	# --- Wish direction ---
	var forward := (-global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	var right   := (global_transform.basis.x  * Vector3(1, 0, 1)).normalized()
	var wish_dir := (right * _input_dir.x + forward * _input_dir.y)
	if wish_dir.length_squared() > 0.001:
		wish_dir = wish_dir.normalized()

	# --- Timers ---
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = max(0.0, _coyote_timer - delta)

	# --- ExitCameralock ---
		
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = max(0.0, _jump_buffer_timer - delta)

	if Input.is_action_just_pressed("crouch"):
		_crouch_buffer_timer = crouch_buffer_time
	else: 
		_crouch_buffer_timer = max(0.0, _crouch_buffer_timer - delta)
		
	# --- Speed ---
	var speed := move_speed
	if Input.is_action_pressed("run"):
		speed *= run_speed_mult

	# --- Horizontal movement ---
	var h_vel    := Vector3(velocity.x, 0.0, velocity.z)
	var h_target := wish_dir * speed
	var used_acc := accel if is_on_floor() else air_accel
	h_vel = h_vel.move_toward(h_target, used_acc * delta)

	if is_on_floor() and wish_dir == Vector3.ZERO:
		h_vel = h_vel.move_toward(Vector3.ZERO, friction * delta)

	velocity.x = h_vel.x
	velocity.z = h_vel.z

	# --- Vertical ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0.0:
			velocity.y = -2.0   # Keep grounded firmly

	# --- Jump ---
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		_jump_buffer_timer = 0.0
		_coyote_timer      = 0.0
		velocity.y = sqrt(2.0 * gravity * jump_height)

	if _crouch_buffer_timer > 0.0:
		_crouch_buffer_timer = 0.0
		velocity.y = sqrt(2.0 * gravity * crouch_height)
		pass
		
	# --- Landing impact ---
	var just_landed := not _was_on_floor and is_on_floor()
	if just_landed:
		_land_dip_current = -land_dip   # Punch cam down
	_was_on_floor = is_on_floor()

	move_and_slide()

	# --- Camera FX (after move so we have floor state) ---
	_update_camera_fx(delta, speed)

# ── Camera effects: bob, tilt, landing dip, breathing ───────────────────────
func _update_camera_fx(delta: float, speed: float) -> void:
	if check_movement_checkings():
		return
	var is_moving := _input_dir.length_squared() > 0.01 and is_on_floor()
	var is_running := Input.is_action_pressed("run")

	# Head bob
	var freq := bob_freq_run if is_running else bob_freq_walk
	if is_moving:
		_bob_timer += delta * freq * TAU          # Full cycle in 1/freq seconds
	# Smoothly zero out bob when idle
	_bob_target = Vector3.ZERO
	if is_moving:
		_bob_target = Vector3(
			sin(_bob_timer * 0.5) * bob_amp_x,
			abs(sin(_bob_timer))  * bob_amp_y,
			0.0
		)
	_bob_current = _bob_current.lerp(_bob_target, bob_lerp * delta)

	# Landing dip recovery
	_land_dip_current = lerp(_land_dip_current, 0.0, land_recover * delta)

	# Breathing (only prominent when still)
	_breathe_timer += delta * breathe_speed * TAU
	var breathe_idle: float = 1.0 - clamp(_input_dir.length() * 3.0, 0.0, 1.0)
	
	var breathe_y: float = sin(_breathe_timer) * breathe_amp * breathe_idle

	# Apply all to cam local position
	cam.position.y = _cam_base_y + _bob_current.y + _land_dip_current + breathe_y
	cam.position.x = _bob_current.x

	# Strafe tilt (roll on the pivot)
	# _input_dir.x: positive = right strafe → tilt left (negative Z roll)
	var tilt_target := deg_to_rad(-_input_dir.x * tilt_amount)
	cam_pivot.rotation.z = lerp(cam_pivot.rotation.z, tilt_target, tilt_lerp * delta)
