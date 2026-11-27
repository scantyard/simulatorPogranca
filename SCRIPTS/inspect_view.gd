extends Node3D

@onready var object_holder = $ObjectHolder

var inspected_object: Node3D
var is_inspecting = false
var mouse_sensitivity = 0.01
var zoom = 1.5
