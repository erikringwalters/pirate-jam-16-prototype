extends Node3D

signal wave_finished

@export var enemy_scene : PackedScene
@export var weapon_scene : PackedScene
@export var birb_handler_scene:PackedScene

@export var dist_from_center : float = 20.0
@export var y_offset : float = 1.0
@export var spread_offset : float = 5
@export var wave_n := [1,2,2,3,3,4,5]
@export var wave_heal_amount := 100

var enemies_remaining = 0
var max_known_wave_count = wave_n.size() - 1

var wave_positions := [
	Vector2(dist_from_center, dist_from_center), 
	Vector2(dist_from_center, -dist_from_center),
	Vector2(-dist_from_center, dist_from_center), 
	Vector2(-dist_from_center, -dist_from_center), 
]
var current_wave_position := Vector2(-dist_from_center, dist_from_center);

@onready var player = %Player
@onready var enemy_count_timer = %EnemyCountTimer
@onready var wave_timer = %WaveTimer
@onready var ui = $UI

func _ready() -> void:
	enemy_count_timer.wait_time = 0.1
	spawn_wave(wave_n[get_safe_wave_count()])
	connect("wave_finished", Callable(ui, "_on_wave_finished"))
	spawn_birbs(250)

func spawn_birbs(amount:int) -> void:
	for i in amount:
		var birb_handler = birb_handler_scene.instantiate()
		add_child(birb_handler)
		birb_handler.global_transform.origin.y = randf_range(10, 50)
		birb_handler.global_rotation_degrees.y = randf_range(0, 360)

# n will be squared
func spawn_wave(n:int) -> void:
	var possible_wave_positions = wave_positions.duplicate(false)
	if GameState.current_wave != 0:
		# Randomize position
		possible_wave_positions.erase(current_wave_position)
		current_wave_position = possible_wave_positions[randi_range(0, possible_wave_positions.size() -1)]
	
	var x_offset = current_wave_position.x
	var z_offset = current_wave_position.y
	var total_wave_size = spread_offset*n

	for i in n:
		for j in n:
			# Spawn enemy
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemies_remaining += 1
			enemy.global_transform.origin = Vector3(
				i * spread_offset + x_offset - total_wave_size/2,
				y_offset,
				j * spread_offset + z_offset - total_wave_size/2
			)

func _on_enemy_died():
	enemies_remaining -= 1
	GameState.score += 1
	ui.update_score()
	print(enemies_remaining, " enemies left")
	if enemies_remaining <= 0:
		enemy_count_timer.start()

func _on_enemy_count_timer_timeout() -> void:
	#verify enemy count in case something went wrong
	enemies_remaining = get_tree().get_node_count_in_group("Enemy")
	if enemies_remaining <= 0:
		wave_over()

func wave_over():
	print("wave over")
	GameState.current_wave += 1
	wave_finished.emit()
	player.heal(wave_heal_amount)
	wave_timer.start()

func _on_wave_timer_timeout() -> void:
	print("new wave starting")
	spawn_wave(wave_n[get_safe_wave_count()])

func get_safe_wave_count() -> int:
	var wave = GameState.current_wave
	wave = wave if wave <= max_known_wave_count else max_known_wave_count
	return wave
