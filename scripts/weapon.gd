extends Node3D

@export var damage : float = 100.0
@export var is_projectile_weapon : bool = false

@export_category("Projectile Type")
@export var projectile_object : String = "res://scenes/weapons/bullet.tscn"
@export var cooldown : float = 0.8 

@onready var is_pickedup = true
var _raycast:RayCast3D

# Conditional projectile weapon variables, will remain null if not projectile
var curr_cooldown
var can_shoot
var gun_barrel
var projectile
var instance

func _ready() -> void:
	if (is_projectile_weapon):
		curr_cooldown = cooldown
		can_shoot = true
		_raycast = %RayCast
		gun_barrel = _raycast
		projectile = load(projectile_object)

func _process(delta) -> void:
	if (is_projectile_weapon):
		curr_cooldown -= delta
		if (curr_cooldown <= 0):
			can_shoot = true
			curr_cooldown = cooldown

func shoot() -> void:
	instance = projectile.instantiate()
	instance.position = gun_barrel.global_position
	instance.transform.basis = gun_barrel.global_transform.basis
	get_parent().add_child(instance);

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("manual_shoot") \
	and is_projectile_weapon \
	and can_shoot \
	and is_pickedup:
		shoot()
		curr_cooldown = cooldown
		can_shoot = false

func pick_up() -> void:
	is_pickedup = true

func drop() -> void:
	is_pickedup = false

func get_damage() -> float:
	return damage
	
func set_damage(num) -> void:
	damage = num
	
