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
	look_at(get_parent().get_node("Player").global_transform.origin)
	
	# Move toward player
	var move_direction := global_basis.z
	move_direction.y = 0.0
	move_direction = -move_direction.normalized() * move_direction.length()
	var vel = linear_velocity.move_toward(move_direction * move_speed, acceleration * delta)
	linear_velocity.x = clamp(vel.x, -move_speed, move_speed)
	linear_velocity.y = 0.0
	linear_velocity.z = clamp(vel.z, -move_speed, move_speed)
