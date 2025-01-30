extends RigidBody3D

signal health_changed

@export_group("Camera")
# Mouse sensitivity should be low because on browser sensitivity is way higher
@export_range(0.0, 1.0) var camera_mouse_sensitivity := 0.25
@export_range(0.0, 1.0) var camera_stick_sensitivity := 0.5
@export_range(1.0, 10.0) var camera_stick_mult := 10.0

@export_group("Movement")
@export var move_speed := 12.0
@export var acceleration := 50.0

var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot:Node3D = %CameraPivot
@onready var _camera:Camera3D = %Camera

func _ready() -> void:
	%CameraPivot.top_level = true
	connect("health_changed", Callable(get_parent().get_node("UI"), "_on_health_changed"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("restart") && GameState.is_game_over:
		get_parent().get_parent().load_level("level")

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
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 2.5, 0.0)
	_camera_pivot.rotation.y -= (_camera_input_direction.x + camera_stick_rotation.x) * get_physics_process_delta_time()
	
	_camera_input_direction = Vector2.ZERO
	
	if !GameState.is_game_over:
		# RigidBody Movement
		var raw_input := Input.get_vector(
			"move_up", 
			"move_down",
			"move_right", 
			"move_left", 
		)
		
		var forward := _camera.global_basis.z
		var right := _camera.global_basis.x
		
		var move_direction := forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized() * move_direction.length()
		
		var vel = angular_velocity.move_toward(move_direction * move_speed, acceleration * delta)
		angular_velocity.x = clamp(vel.x, -move_speed, move_speed)
		angular_velocity.y = 0.0
		angular_velocity.z = clamp(vel.z, -move_speed, move_speed)

func _on_pickup_body_entered(body: Node3D) -> void:
	var collision = body.get_node_or_null("RBCollision")
	if(body.is_in_group("Pickup") and collision != null):
		collision.reparent(self, true)
		collision.get_node("HitBox").connect("body_entered", Callable(self, "_on_pickup_body_entered"))
		collision.get_node("HitBox").connect("area_entered", Callable(self, "_on_pickup_area_entered"))
		body.set_deferred("disabled", false)
		body.set_deferred("freeze", true)
		body.pick_up()
	# initiate hitting an enemy with a melee weapon
	if (body.has_method('enemy_process_melee_damage')):
		body.enemy_process_melee_damage(Items.weapons['Sword']['base_damage'])

func _on_pickup_area_entered(area: Node3D) -> void:
	take_hit(area)
	
#func _on_hit_box_area_entered(area: Area3D) -> void:
	#take_hit(area)

func full_heal():
	GameState.player_health = GameState.max_health
	health_changed.emit(true)

func heal(amount):
	GameState.player_health = clamp(GameState.player_health + amount, 0, GameState.max_health)
	health_changed.emit(true)

func player_process_explosion_damage(damage):
	GameState.player_health -= damage/3
	health_changed.emit(false)
	print("player splosion")
	if GameState.player_health <= 0:
		get_parent().get_node("UI").game_over()

func player_process_melee_damage(dmg):
	GameState.player_health -= dmg
	health_changed.emit(false)
	print("player health: ", GameState.player_health)
	if GameState.player_health <= 0:
		get_parent().get_node("UI").game_over()
	
# Despawn the projectile and create explosion if a rocket
func handle_projectile_despawn(area:Node3D):
	if area.has_method("projectile_damage"):
		if (area.type=="Rocket" or area.type=="rocket"):
			var expl = Items.explosion.instantiate()
			get_parent().add_child(expl)
			expl.fired_by_player = area.fired_by_player
			expl.global_transform.origin = area.global_transform.origin
		area.queue_free()

func take_hit(area:Node3D):
	if area.is_in_group("Projectile"):
		if (!area.fired_by_player):
			GameState.player_health -= area.projectile_damage() if area.has_method("projectile_damage") else 0
			health_changed.emit(false)
			handle_projectile_despawn(area)
			print("player health: ", GameState.player_health)
			if GameState.player_health <= 0:
				get_parent().get_node("UI").game_over()
