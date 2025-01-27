extends Node

var max_health = 1000

# maybe turn into enum
var is_game_over = false

# player's health
var player_health = max_health

# Score/enemies killed
var score = 0

func reset():
	is_game_over = false
	player_health = max_health
	score = 0
