extends Node

var max_health = 1000
var player_health = max_health
var is_game_over = false
var score = 0
var current_wave = 0

func reset():
	player_health = max_health
	is_game_over = false
	score = 0
	current_wave = 0
