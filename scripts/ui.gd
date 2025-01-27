extends Control

@onready var black_screen := $BlackScreen
@onready var game_over_label := $BlackScreen/GameOver
@onready var new_game_label := $BlackScreen/NewGame
@onready var health_bar := $HealthBar
@onready var score_label := $Score
@onready var damage_indicator := $DamageIndicator

var screen_size:Vector2
var game_over_fade_time := 0.5
var damage_fade_speed := 0.1

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	transform_health_bar()
	transform_game_over()
	health_bar.value = GameState.player_health

func _physics_process(_delta: float) -> void:
	damage_indicator.texture.gradient.colors[1].a = lerp(damage_indicator.texture.gradient.colors[1].a, -0.01, damage_fade_speed)


func game_over() -> Tween:
	GameState.is_game_over = true
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(black_screen, "color:a", 0.9, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(game_over_label, "theme_override_colors/font_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_game_label, "theme_override_colors/font_color:a", 1.0, game_over_fade_time).set_ease(Tween.EASE_IN_OUT)
	return tween

func transform_health_bar():
	health_bar.position = Vector2(screen_size.x/30, screen_size.y * 11/12)
	health_bar.size = Vector2(screen_size.x/3, screen_size.x * 0.06)

func transform_game_over():
	#game_over_label.position.y = screen_size.y/10
	new_game_label.position.y = screen_size.y*3/4


func _on_health_changed():
	health_bar.value = GameState.player_health
	flash_damage()

func update_score():
	score_label.text = str("Score: ", GameState.score)
	
func flash_damage():
	damage_indicator.texture.gradient.colors[1].a = 1.0
