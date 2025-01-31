extends RigidBody3D

@export var damage : float = 10.0
@export var is_projectile_weapon : bool = false

# DM Note: Couldn't figure out how to check which RigidBody3D model the weapon was using, so this was the next best thing I could think of.
@export_category("Weapon Type")
@export_enum("Handgun", "Rocket", "Shotgun", "Sword", "Dagger") var weapon_type : String

@export_category("Projectile Type")
@export_enum("Bullet", "Rocket") var projectile_type : String 
@export var scatter_shot : bool = false

@onready var is_pickedup = false
@onready var hit_box = $"RBCollision/HitBox"
@onready var fire_timer = %FireTimer
@onready var fire_wait_timer = %FireWaitTimer

var _raycast:RayCast3D

# Conditional projectile weapon variables, will remain null if not projectile
var gun_barrel
var projectile_scene
var projectile

var held_by_player = false

func _ready() -> void:
	if (projectile_type and projectile_type != ''):
		projectile_scene = Items.projectiles[projectile_type]
	else: # Default if no projectile type is selected
		projectile_scene = Items.projectiles['Bullet']
	if (is_projectile_weapon):
		#can_shoot = true
		_raycast = %RayCast
		gun_barrel = _raycast
	else:
		damage = Items.weapons[weapon_type]['base_damage']
	fire_timer.connect("timeout", Callable(self,"auto_shoot"))
	fire_wait_timer.connect("timeout", Callable(self,"start_shot_fire_timer"))

func add_child_logic(_projectile) -> void:
	# Currently, when an enemy spawns with a projectile weapon, the `get_parent()` returns
	#	the enemy, making the projectile continuously follow the rotation of the enemy. So 
	#	instead we need to go a level higher to assign the world as the parent
	if ('Main' in String(get_parent().name)):
		get_parent().add_child(_projectile)
	else: 
		get_parent().get_parent().add_child(_projectile)
		
func shoot() -> void:
	get_node('ShotSound').play()
	if (scatter_shot):
		# Spawn ten bullets
		for i in range(10):
			projectile = projectile_scene.instantiate()
			projectile.position = gun_barrel.global_position
			projectile.transform.basis = gun_barrel.global_transform.basis
			projectile.fired_by_player = held_by_player
			projectile.set_damage(Items.weapons[weapon_type]['base_damage'])
			projectile.set_collision_layers(is_pickedup and get_collision_layer_value(CollisionLayers.ENEMY_DAMAGE))
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
			projectile.add_to_group("Projectile")
			add_child_logic(projectile)	
	else:
		projectile = projectile_scene.instantiate()
		projectile.position = gun_barrel.global_position
		projectile.transform.basis = gun_barrel.global_transform.basis
		projectile.fired_by_player = held_by_player
		projectile.set_type(projectile_type)
		projectile.set_damage(Items.weapons[weapon_type]['base_damage'])
		projectile.set_collision_layers(is_pickedup and get_collision_layer_value(CollisionLayers.ENEMY_DAMAGE))
		#print(get_collision_layer_value(CollisionLayers.PLAYER_DAMAGE))
		projectile.add_to_group("Projectile")
		add_child_logic(projectile)

func wait_to_fire() -> void:
	fire_wait_timer.wait_time = randf_range(0, Items.weapons[weapon_type]['base_cooldown'])
	fire_wait_timer.one_shot = true
	#add_child(fire_wait_timer)
	fire_wait_timer.start()
	
func start_shot_fire_timer() -> void:
	if(weapon_type):
		fire_timer.wait_time = Items.weapons[weapon_type]['base_cooldown']
		#fire_timer.time_left = randf_range(0.0, fire_timer.wait_time) # Randomize time on start?
		#add_child(fire_timer)
		fire_timer.start()

func enemy_pick_up() -> void:
	print('enemy pickup')
	is_pickedup = true
	set_collision_layers(true, false)
	wait_to_fire()
	
func pick_up() -> void:
	print('player pickup')
	is_pickedup = true
	set_collision_layers(false, true)
	held_by_player = true
	start_shot_fire_timer()

# DM Note: fire_timer triggered auto_shoot function with console logs for each weapon type
func auto_shoot() -> void:
	if is_pickedup && is_projectile_weapon:
		shoot()

func melee_damage():
	print('melee hit')
	if (!is_projectile_weapon):
		return Items.weapons[weapon_type]['base_damage']
	else:
		return 0

func drop() -> void:
	is_pickedup = false

func get_damage() -> float:
	return damage
	
func set_damage(num:int) -> void:
	damage = num

func set_collision_layers(is_held_by_enemy:bool, is_held_by_player:bool) -> void:
	set_collision_layer_value(CollisionLayers.COMMON, !is_held_by_enemy)
	set_collision_layer_value(CollisionLayers.PLAYER_DAMAGE, is_held_by_enemy)
	set_collision_layer_value(CollisionLayers.ENEMY_DAMAGE, is_held_by_player)
	set_collision_layer_value(CollisionLayers.PICKUP,
		!is_held_by_enemy && !is_held_by_player
	)
	
func set_weapon_type(type):
	weapon_type = type
