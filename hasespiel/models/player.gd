extends RigidBody3D

# Bewegungsparameter
var movement_speed = 10.0
var jump_force = 15.0
var turn_speed = 3.0

# Sprung-Check
var can_jump_flag = false

func _ready():
	# Input Actions erstellen, falls sie nicht existieren
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var left_key = InputEventKey.new()
		left_key.keycode = KEY_A
		InputMap.action_add_event("move_left", left_key)
	
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var right_key = InputEventKey.new()
		right_key.keycode = KEY_D
		InputMap.action_add_event("move_right", right_key)
	
	if not InputMap.has_action("move_forward"):
		InputMap.add_action("move_forward")
		var forward_key = InputEventKey.new()
		forward_key.keycode = KEY_W
		InputMap.action_add_event("move_forward", forward_key)
	
	if not InputMap.has_action("move_backward"):
		InputMap.add_action("move_backward")
		var backward_key = InputEventKey.new()
		backward_key.keycode = KEY_S
		InputMap.action_add_event("move_backward", backward_key)
	
	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var jump_key = InputEventKey.new()
		jump_key.keycode = KEY_SPACE
		InputMap.action_add_event("jump", jump_key)

func _integrate_forces(state):
	var input_vector = Vector3.ZERO



	
	# Bewegungseingaben sammeln
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_forward"):
		input_vector.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_vector.z += 1
	
	# Bewegung relativ zur Kamera/Rotation anwenden
	input_vector = input_vector.normalized()
	if input_vector != Vector3.ZERO:
		var move_force = transform.basis * input_vector * movement_speed
		state.apply_central_force(move_force)
	
	# Sprung
	if Input.is_action_just_pressed("jump") and can_jump(state):
		state.apply_central_impulse(Vector3.UP * jump_force)

func can_jump(state):
	# Raycast nach unten um Boden zu prüfen
	var space_state = state.get_space_state()
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * 1.2
	)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	return not result.is_empty()
	
