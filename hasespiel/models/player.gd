extends CharacterBody3D
# Bewegungskonstanten
const SPEED := 10.0
const JUMP_VELOCITY := 12.0
const GRAVITY := 25.0
const MOUSE_SENSITIVITY := 0.003
const CAMERA_DISTANCE := 5.0

# Kamera Auto-Return
const CAMERA_RETURN_SPEED := 2.0
const CAMERA_IDLE_TIME := 1.5  # Sekunden ohne Mausbewegung

# Kamera-Referenzen
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var rotation_y := 0.0
var rotation_x := 0.0
const MAX_LOOK_ANGLE := 35.0  # Begrenzt auf 35 Grad

# Auto-Return Variablen
var mouse_idle_timer := 0.0
var mouse_moved := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.position = Vector3(0, 0, CAMERA_DISTANCE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * MOUSE_SENSITIVITY
		rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		
		# Vertikale Rotation strikt begrenzen
		rotation_x = clamp(rotation_x, -deg_to_rad(MAX_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
		
		# Maus wurde bewegt
		mouse_moved = true
		mouse_idle_timer = 0.0

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	var is_moving = direction.length() > 0.1
	
	# Mouse-Timer hochzählen
	if mouse_moved:
		mouse_idle_timer += delta
		if mouse_idle_timer >= CAMERA_IDLE_TIME:
			mouse_moved = false
	
	# Auto-Return: Kamera zurück wenn Spieler sich bewegt und Maus idle ist
	if is_moving and not mouse_moved:
		# Horizontal zurück zu 0 (hinter Spieler)
		rotation_y = lerp_angle(rotation_y, 0.0, CAMERA_RETURN_SPEED * delta)
		# Vertikal zurück zu leicht erhöhter Position
		rotation_x = lerp(rotation_x, deg_to_rad(-10.0), CAMERA_RETURN_SPEED * delta)
	
	# Bewegung
	direction = direction.rotated(Vector3.UP, rotation_y).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
	
	# Rotationen anwenden
	camera_pivot.rotation.y = rotation_y
	camera_pivot.rotation.x = rotation_x
	
	move_and_slide()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
