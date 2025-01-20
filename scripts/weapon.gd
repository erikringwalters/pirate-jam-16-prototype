extends Node3D

@export var damage : float = 100.0
@export var is_projectile_weapon : bool = false

@export_category("Projectile Type")
@export_enum("Bullet", "Rocket") var projectile_type : String 
@export var cooldown : float = 0.8 
@export var scatter_shot : bool = false

@onready var is_pickedup = false
var _raycast:RayCast3D

# Conditional projectile weapon variables, will remain null if not projectile
var curr_cooldown
var can_shoot
var gun_barrel
var projectile_scene
var projectile


func _ready() -> void:
	if (projectile_type and projectile_type != ''):
		projectile_scene = Items.projectiles[projectile_type]
	else: # Default if no projectile type is selected
		projectile_scene = Items.projectiles['Bullet']
		
	if (is_projectile_weapon):
		curr_cooldown = cooldown
		can_shoot = true
		_raycast = %RayCast
		gun_barrel = _raycast


func _process(delta) -> void:
	if (is_projectile_weapon):
		curr_cooldown -= delta
		if (curr_cooldown <= 0):
			can_shoot = true
			curr_cooldown = cooldown


func shoot() -> void:
	if (scatter_shot):
		# Spawn five bullets
		for i in range(10):
			projectile = projectile_scene.instantiate()
			projectile.position = gun_barrel.global_position
			projectile.transform.basis = gun_barrel.global_transform.basis
			
			# Randomly rotate each axis
			var axis = Vector3(1, 0, 0)
			var rotation_amount = float((randi() % 180) - 90)/1000
			projectile.transform.basis = projectile.transform.basis.rotated(axis, rotation_amount)
			axis = Vector3(0, 1, 0)
			rotation_amount = float((randi() % 180) - 90)/1000
			projectile.transform.basis = projectile.transform.basis.rotated(axis, rotation_amount)
			axis = Vector3(0, 0, 1)
			rotation_amount = float((randi() % 180) - 90)/1000
			projectile.transform.basis = projectile.transform.basis.rotated(axis, rotation_amount)
			
			get_parent().add_child(projectile)
	else:
		projectile = projectile_scene.instantiate()
		projectile.position = gun_barrel.global_position
		projectile.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(projectile)


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
	
