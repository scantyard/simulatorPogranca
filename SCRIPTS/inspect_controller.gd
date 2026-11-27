
extends Node3D

@onready var player = get_parent()
@onready var camera: Camera3D = $"../Node3D/Camera3D"
@onready var inspect_point: Marker3D = $"../Node3D/Camera3D/Marker3D"
@onready var ray: RayCast3D = $"../Node3D/Camera3D/RayCast3D"
@onready var crosshair: Control = $"../Node3D/Control"

var inspecting := false
var inspected_object: Node3D

var mouse_sensitivity := 0.01
var zoom := 1.5
var min_zoom := 0.6
var max_zoom := 3.0

var old_mouse_mode: Input.MouseMode
var old_player_physics := true
var old_player_input := true
var old_player_unhandled_input := true


func _input(event):
	if event.is_action_pressed("inspect") and not inspecting:
		start_inspection()

	if event.is_action_pressed("exit") and inspecting:
		stop_inspection()

	if inspecting:
		if event is InputEventMouseMotion:
			inspected_object.rotate_y(-event.relative.x * mouse_sensitivity)
			inspected_object.rotate_x(-event.relative.y * mouse_sensitivity)
			inspected_object.rotation.x = clamp(inspected_object.rotation.x, -1.5, 1.5)

		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom = max(min_zoom, zoom - 0.15)
				inspect_point.position.z = -zoom

			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom = min(max_zoom, zoom + 0.15)
				inspect_point.position.z = -zoom


func start_inspection():
	ray.force_raycast_update()

	if not ray.is_colliding():
		return

	var target = ray.get_collider()

	if not target is Node3D:
		return

	inspected_object = target.duplicate() as Node3D

	if inspected_object == null:
		return

	inspecting = true

	old_mouse_mode = Input.mouse_mode
	old_player_physics = player.is_physics_processing()
	old_player_input = player.is_processing_input()
	old_player_unhandled_input = player.is_processing_unhandled_input()

	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	crosshair.hide()

	zoom = 1.5
	inspect_point.position.z = -zoom

	inspect_point.add_child(inspected_object)
	inspected_object.transform = Transform3D.IDENTITY

	disable_object_collisions(inspected_object)


func disable_object_collisions(node: Node):
	if node is CollisionObject3D:
		node.collision_layer = 0
		node.collision_mask = 0

		if node is RigidBody3D:
			node.freeze = true

	node.set_process(false)
	node.set_physics_process(false)

	for child in node.get_children():
		disable_object_collisions(child)


func stop_inspection():
	if not inspecting:
		return

	inspecting = false

	inspected_object.queue_free()
	inspected_object = null

	crosshair.show()

	player.set_physics_process(old_player_physics)
	player.set_process_input(old_player_input)
	player.set_process_unhandled_input(old_player_unhandled_input)

	Input.mouse_mode = old_mouse_mode
