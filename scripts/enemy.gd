extends RigidBody3D

@onready var _weapon_marker = %WeaponMarker

func _ready() -> void:
	var weapon = Items.weapons["Sword"].instantiate()
	add_child(weapon)
	weapon.global_transform.origin = _weapon_marker.global_transform.origin

func _physics_process(_delta: float) -> void:
	pass
