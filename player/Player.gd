extends CharacterBody3D

@onready var camera_base: Node3D = get_node("CameraBase")
@onready var camera = camera_base.get_child(0)

var SPEED = 20.0
const JUMP_VELOCITY = 4.5
const MIN_Y_ROTATION = -90
const MAX_Y_ROTATION = 90

var move_direction: Vector3
var mouse_delta: Vector2
var fly_enabled = true
var sprint = false

@export var mouse_sensitivity = 0.03

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(event):
	
	if event is InputEventMouseMotion:
		mouse_delta += event.relative
	if Input.is_action_just_pressed('toggle_fly'):
		fly_enabled = !fly_enabled
		print(fly_enabled)
	if Input.is_action_pressed("sprint"):
		sprint = true
	else:
		sprint = false

func _physics_process(delta):
	handle_camera_rotation(delta)
	movement(delta)
	
func handle_camera_rotation(delta):
	camera_base.rotate_y(-mouse_delta.x * mouse_sensitivity * delta)
	camera.rotate_x(-mouse_delta.y * mouse_sensitivity * delta)
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, MIN_Y_ROTATION, MAX_Y_ROTATION)
	mouse_delta = Vector2()
	

func movement(delta):
	
	
	## Add the gravity.
	if not is_on_floor() and not fly_enabled:
		velocity.y -= gravity * delta
	

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var cam_basis = camera.global_transform.basis
	
	
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var input_dir: Vector3 = Vector3(input.x, 0, input.y)
	var direction = input_dir.x * cam_basis.x + input_dir.z * cam_basis.z
	
	if sprint:
		SPEED = 100.0
	else:
		SPEED = 20.0
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if fly_enabled and not direction:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
	

