extends Camera3D

var mouse_sensitivity = 0.002
var camera_distance = 5.0
var camera_height = 2.0
var follow_speed = 10.0

var yaw = 0.0
var pitch = 0.0
var min_pitch = -60.0
var max_pitch = 60.0

var player: RigidBody3D

func _ready():
	player = get_parent() as RigidBody3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if not player:
		return
	
	var target_position = player.global_position
	
	var offset = Vector3.ZERO
	offset.x = camera_distance * sin(yaw) * cos(pitch)
	offset.y = camera_height + camera_distance * sin(pitch)
	offset.z = camera_distance * cos(yaw) * cos(pitch)
	
	var desired_position = target_position + offset
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	
	look_at(target_position + Vector3.UP * 1.0, Vector3.UP)
