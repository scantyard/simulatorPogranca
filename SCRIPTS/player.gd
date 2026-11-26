extends CharacterBody3D

const SPEED = 2
const SPRINT_SPEED = 6
const JUMP_VELOCITY = 6
var sens = 0.002

@onready var head = $Node3D
@onready var camera = $Node3D/Camera3D

const FOV_BASE = 90.0
const FOV_SPRINT = 100.0
const FOV_LERP_SPEED = 8.0

const BOB_FREQ = 3
const BOB_AMP = 0.06
var bob_time = 0.0
var camera_start_pos: Vector3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_start_pos = camera.position
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sens)
		camera.rotate_x(-event.relative.y * sens)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var target_speed: float
	var target_fov: float
	
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("forward (W)"):
		target_speed = SPRINT_SPEED
		target_fov = FOV_SPRINT
	else:
		target_speed = SPEED
		target_fov = FOV_BASE
		
	camera.fov = lerp(camera.fov, target_fov, FOV_LERP_SPEED * delta)
		
	var input_dir = Input.get_vector("left (A)", "right (D)", "forward (W)", "backward (S)")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed)
		velocity.z = move_toward(velocity.z, 0, target_speed)

	if is_on_floor() and direction.length() > 0:
		bob_time += delta * velocity.length() * BOB_FREQ
		
		var new_pos = camera.position
		new_pos.y = camera_start_pos.y + sin(bob_time * 2.0) * BOB_AMP
		new_pos.x = camera_start_pos.x + cos(bob_time) * BOB_AMP * 0.5
		
		camera.position = new_pos
	else:
		bob_time = 0.0
		camera.position.y = lerp(camera.position.y, camera_start_pos.y, delta * 10.0)
		camera.position.x = lerp(camera.position.x, camera_start_pos.x, delta * 10.0)

	move_and_slide()
