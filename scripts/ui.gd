extends Control

@onready var black_screen := $BlackScreen
@onready var game_over_label := $BlackScreen/GameOver
@onready var new_game_label := $BlackScreen/NewGame


var fade_time := 0.5

func game_over() -> Tween:
	GameState.is_game_over = true
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(black_screen, "color:a", 0.9, fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(game_over_label, "theme_override_colors/font_color:a", 1.0, fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_game_label, "theme_override_colors/font_color:a", 1.0, fade_time).set_ease(Tween.EASE_IN_OUT)

	return tween
