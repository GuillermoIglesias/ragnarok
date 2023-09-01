extends Node
class_name Loot

@export var exp_points: float = 1.0
@export_range(0, 1) var bonus_chance: float = 0.05
@export var bonus_amount: float = 2.0
@export var health: Health
@export var exp_scene: PackedScene


func _ready():
	health.died.connect(_on_died)


func _on_died():
	if exp_scene == null:
		return

	if not owner is Node2D:
		return

	if bonus_chance >= randf():
		exp_points *= bonus_amount

	var spawn_position = (owner as Node2D).global_position
	var exp_instance = exp_scene.instantiate() as Node2D
	exp_instance.global_position = spawn_position
	exp_instance.exp_points = exp_points
	owner.get_parent().add_child(exp_instance)
