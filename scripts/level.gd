extends Node3D

signal wave_finished

@export var enemy_scene : PackedScene
@export var weapon_scene : PackedScene

@export var dist_from_center : float = 15.0
@export var y_offset : float = 1.0
@export var spread_offset : float = 5
@export var wave_n := [1,2,2,3,3,4,5]
@export var wave_heal_amount := 100

var enemies_remaining = 0
var max_known_wave_count = wave_n.size() - 1

@onready var player = %Player
@onready var enemy_count_timer = %EnemyCountTimer
@onready var wave_timer = %WaveTimer
@onready var ui = $UI

func _ready() -> void:
	enemy_count_timer.wait_time = 0.1
	spawn_wave(wave_n[get_safe_wave_count()])
	connect("wave_finished", Callable(ui, "_on_wave_finished"))

# n will be squared
func spawn_wave(n:int) -> void:
	var x_offset = dist_from_center if GameState.current_wave % 2 == 1 else -dist_from_center
	var z_offset = dist_from_center if GameState.current_wave % 2 == 0 else -dist_from_center
	for i in n:
		for j in n:
			# Spawn enemy
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemies_remaining += 1
			enemy.global_transform.origin = Vector3(
				i * spread_offset + x_offset,
				y_offset, 
				j * spread_offset + z_offset
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
