extends Node

#name, file path, base_damage, damage_mult, base_cooldown, cooldown_mult, model_scale
@onready var weapons : Dictionary = {
	"Dagger" : {
		"path":"res://assets/weapons/Dagger.fbx",
		"weapon_instance": ResourceLoader.load("res://assets/weapons/Dagger.fbx"),
		"base_damage": 100.0,
		"damage_mult": 1.0,
		"base_cooldown": 0.25,
		"cooldown_mult": 1.0,
		"model_rotation": 1,
	}, 
	"Sword" : {
		"path":"res://assets/weapons/Sword.fbx",
		"weapon_instance": ResourceLoader.load("res://assets/weapons/Sword.fbx"),
		"base_damage": 100.0,
		"damage_mult": 1.0,
		"base_cooldown": 0.25,
		"cooldown_mult": 1.0,
		"model_rotation": 1,
	}, 
	"Handgun" : {
		"path":"res://assets/weapons/Handgun.fbx",
		"weapon_instance": ResourceLoader.load("res://assets/weapons/Handgun.fbx"),
		"base_damage": 100.0,
		"damage_mult": 1.0,
		"base_cooldown": 0.25,
		"cooldown_mult": 1.0,
		"model_rotation": 1,
	}, 
	"Shotgun" : {
		"path":"res://assets/weapons/Shotgun.fbx",
		"weapon_instance": ResourceLoader.load("res://assets/weapons/Shotgun.fbx"),
		"base_damage": 100.0,
		"damage_mult": 1.0,
		"base_cooldown": 0.25,
		"cooldown_mult": 1.0,
		"model_rotation": 1,
	}, 
	"Rocket" : {
		"path":"res://assets/weapons/Rocket.fbx",
		"weapon_instance": ResourceLoader.load("res://assets/weapons/Rocket.fbx"),
		"base_damage": 100.0,
		"damage_mult": 1.0,
		"base_cooldown": 0.25,
		"cooldown_mult": 1.0,
		"model_rotation": 1,
	}
}

@onready var projectiles : Dictionary = {
	"Bullet" : ResourceLoader.load("res://scenes/weapons/bullet.tscn"),
	"Rocket" : ResourceLoader.load("res://scenes/weapons/rocket_projectile.tscn"),
}

func _ready() -> void:
	pass
