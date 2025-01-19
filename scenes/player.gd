extends RigidBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var camera_mouse_sensitivity := 0.25
@export_range(0.0, 1.0) var camera_stick_sensitivity := 0.5
@export_range(1.0, 10.0) var camera_stick_mult := 10.0

@export_group("Movement")
@export var move_speed := 16.0
@export var acceleration := 50.0

var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot:Node3D = %CameraPivot
@onready var _camera:Camera3D = %Camera
@onready var _pickup_area:Area3D = %Pickup

func _ready() -> void:
	%CameraPivot.top_level = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * camera_mouse_sensitivity
	else: pass

func _physics_process(delta: float) -> void:
	# Camera Movement
	%CameraPivot.global_transform.origin = global_transform.origin
	
	var camera_stick_input := Input.get_vector(
		"camera_left",
		"camera_right",
		"camera_up",
		"camera_down"
	)
	
	var camera_stick_rotation = (camera_stick_input * camera_stick_mult * camera_stick_sensitivity)
	
	_camera_pivot.rotation.x -= (_camera_input_direction.y + camera_stick_rotation.y) * get_physics_process_delta_time()
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 2.01, 0.0)
	_camera_pivot.rotation.y -= (_camera_input_direction.x + camera_stick_rotation.x) * get_physics_process_delta_time()
	
	_camera_input_direction = Vector2.ZERO
	
	# RigidBody Movement
	var raw_input := Input.get_vector(
		"move_up", 
		"move_down",
		"move_right", 
		"move_left", 
	)
	
	# TODO: Check movement speed when camera is high up
	
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized() * move_direction.length()
	
	var vel = angular_velocity.move_toward(move_direction * move_speed, acceleration * delta)
	angular_velocity.x = clamp(vel.x, -move_speed, move_speed)
	angular_velocity.y = 0.0
	angular_velocity.z = clamp(vel.z, -move_speed, move_speed)
	#print(angular_velocity)

func _on_pickup_body_entered(body: Node3D) -> void:
	print(body)
	if(body.is_in_group("Pickup") && body.is_in_group("NoCollision")):
		body.reparent(self, true)
		body.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	elif(body.is_in_group("Pickup") && body.is_in_group("GroundCollision")):
		body.get_node("CollisionShape3D").reparent(self, true)
		body.queue_free()
