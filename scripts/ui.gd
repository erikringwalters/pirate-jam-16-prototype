extends Control

@onready var black_screen := $BlackScreen
@onready var game_over_label := $BlackScreen/GameOver
@onready var new_game_label := $BlackScreen/NewGame
@onready var health_bar := $HealthBar
@onready var score_label := $Score

var screen_size:Vector2
var fade_time := 0.5

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	transform_health_bar()
	transform_game_over()
	health_bar.value = GameState.player_health


func game_over() -> Tween:
	GameState.is_game_over = true
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(black_screen, "color:a", 0.9, fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(game_over_label, "theme_override_colors/font_color:a", 1.0, fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_game_label, "theme_override_colors/font_color:a", 1.0, fade_time).set_ease(Tween.EASE_IN_OUT)

	return tween

func transform_health_bar():
	health_bar.position = Vector2(screen_size.x/30, screen_size.y * 11/12)
	health_bar.size = Vector2(screen_size.x/3, screen_size.x * 0.06)

func transform_game_over():
	#game_over_label.position.y = screen_size.y/10
	new_game_label.position.y = screen_size.y*3/4


func _on_health_changed():
	health_bar.value = GameState.player_health

func update_score():
	score_label.text = str("Score: ", GameState.score)
