extends RigidBody3D

@export var move_speed = 1.0
@export var acceleration := 50.0

@onready var _weapon_marker = %WeaponMarker

func _ready() -> void:
	var weapon = Items.weapons["Sword"].instantiate()
	add_child(weapon)
	weapon.global_transform.origin = _weapon_marker.global_transform.origin

func _physics_process(delta: float) -> void:
	# Look at player # TODO: Slowly look toward player to give player a chance to avoid/kite
	var look_direction = get_angle(
		global_transform.origin, 
		get_parent().get_node("Player").global_transform.origin
	)
	global_rotation.y = lerp(global_rotation.y, look_direction, 0.1)
	
	# Move toward player
	var move_direction := global_basis.z
	move_direction.y = 0.0
	move_direction = -move_direction.normalized() * move_direction.length()
	var vel = linear_velocity.move_toward(move_direction * move_speed, acceleration * delta)
	linear_velocity.x = clamp(vel.x, -move_speed, move_speed)
	linear_velocity.y = 0.0
	linear_velocity.z = clamp(vel.z, -move_speed, move_speed)

func get_angle(a:Vector3, b:Vector3) -> float:
	return -atan2((b.z - a.z), (b.x - a.x))

func _on_hit_box_area_entered(area: Area3D) -> void:
	print("ouch", area, "hit me")
