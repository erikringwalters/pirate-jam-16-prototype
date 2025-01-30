extends Control

@onready var black_screen := $BlackScreen
@onready var game_over_label := $BlackScreen/GameOver
@onready var new_game_label := $BlackScreen/NewGame
@onready var wave_count_label := $BlackScreen/WaveCount
@onready var health_bar := $HealthBar
@onready var score_label := $Score
@onready var damage_indicator := $DamageIndicator
@onready var wave_finished_timer := $WaveFinishedTimer
@onready var wave_count_timer := $WaveCountTimer
@onready var heal_label := $HealLabel

var screen_size:Vector2
var game_over_fade_time := 0.5
var damage_fade_speed := 0.05
var heal_label_move_time := 0.5

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	transform_health_bar()
	transform_game_over()
	health_bar.value = GameState.player_health
	wave_finished_timer.wait_time = 1.5
	wave_count_timer.wait_time = 1.0

func _physics_process(_delta: float) -> void:
	damage_indicator.texture.gradient.colors[1].a = lerp(damage_indicator.texture.gradient.colors[1].a, -0.01, damage_fade_speed)

func game_over() -> Tween:
	GameState.is_game_over = true
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(black_screen, "color:a", 0.9, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(game_over_label, "theme_override_colors/font_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(game_over_label, "theme_override_colors/font_outline_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_game_label, "theme_override_colors/font_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_game_label, "theme_override_colors/font_outline_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)

	return tween

func transform_health_bar():
	health_bar.position = Vector2(screen_size.x/30, screen_size.y * 11/12)
	health_bar.size = Vector2(screen_size.x/3, screen_size.x * 0.06)

func transform_game_over():
	#game_over_label.position.y = screen_size.y/10
	new_game_label.position.y = screen_size.y*0.6

func _on_health_changed(is_healing:bool) -> void:
	health_bar.value = GameState.player_health
	if is_healing:
		show_heal_label()
	else:
		flash_damage()

func update_score():
	score_label.text = str("Score: ", GameState.score)
	
func flash_damage():
	damage_indicator.texture.gradient.colors[1].a = 1.0

func _on_wave_finished():
	wave_count_label.text = str("Wave ", GameState.current_wave)
	wave_finished_timer.start()

func show_wave_count() -> Tween:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(black_screen, "color:a", 0.4, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(wave_count_label, "theme_override_colors/font_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(wave_count_label, "theme_override_colors/font_outline_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	return tween

func hide_wave_count() -> Tween:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(black_screen, "color:a", 0.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(wave_count_label, "theme_override_colors/font_color:a", 0.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(wave_count_label, "theme_override_colors/font_outline_color:a", 0.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	return tween

func _on_wave_finished_timer_timeout() -> void:
	await show_wave_count().finished
	wave_count_timer.start()

func _on_wave_count_timer_timeout() -> void:
	hide_wave_count()

func show_heal_label() -> void:
	heal_label.position = Vector2(health_bar.position.x, health_bar.position.y + 200)
	heal_label.show()
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(heal_label, "theme_override_colors/font_outline_color:a", 1.0, 0.01).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(heal_label, "theme_override_colors/font_color:a", 1.0, 0.01).set_ease(Tween.EASE_IN_OUT)
	await move_heal_label().finished
	await hide_heal_label().finished
	heal_label.hide()

func move_heal_label() -> Tween:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(heal_label, "position:y", health_bar.position.y - 250, heal_label_move_time).set_ease(Tween.EASE_IN_OUT)
	return tween

func hide_heal_label() -> Tween:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(heal_label, "theme_override_colors/font_outline_color:a", 0.0, heal_label_move_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(heal_label, "theme_override_colors/font_color:a", 0.0, heal_label_move_time).set_ease(Tween.EASE_IN_OUT)
	return tween
