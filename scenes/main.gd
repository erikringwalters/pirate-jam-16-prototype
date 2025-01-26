extends Node3D

var level_instance:Node

func _ready() -> void:
	level_instance = $Level

func unload_level():
	if is_instance_valid(level_instance):
		level_instance.queue_free()
	level_instance = null;

func load_level(level_name:String):
	unload_level()
	var level_path:= "res://scenes/level/%s.tscn" % level_name
	var level_resource:=load(level_path)
	if level_resource:
		level_instance = level_resource.instantiate()
		add_child(level_instance)
	GameState.is_game_over = false
