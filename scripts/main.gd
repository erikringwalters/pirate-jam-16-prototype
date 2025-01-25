extends Node3D

@export var enemy_scene : PackedScene
@export var weapon_scene : PackedScene

@export var x_offset : float = 20.0
@export var y_offset : float = 1.0
@export var z_offset : float = 20.0
@export var spread_offset : float = 5

var enemy_count = 0

@onready var enemy_count_timer = %EnemyCountTimer

func _ready() -> void:
	enemy_count_timer.wait_time = 0.1
	spawn_wave(5)

# n will be squared
func spawn_wave(n:int) -> void:
	for i in n:
		for j in n:
			# Spawn enemy
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemy_count += 1
			# Spawn weapon alone
			#var weapon = weapon_scene.instantiate()
			#add_child(weapon)
			#enemy.global_transform.origin = Vector3(
			enemy.global_transform.origin = Vector3(
				i * spread_offset + x_offset,
				y_offset, 
				j * spread_offset + z_offset
			)

func _on_enemy_died():
	enemy_count -= 1
	print(enemy_count, " enemies left")
	if enemy_count <= 0:
		enemy_count_timer.start()

		
func wave_over():
	# TODO: show game over screen
	print("wave over")
	print("new wave starting")
	spawn_wave(5)


func _on_enemy_count_timer_timeout() -> void:
	#verify enemy count in case something went wrong
	enemy_count = get_tree().get_node_count_in_group("Enemy")
	if enemy_count <= 0:
		wave_over()
