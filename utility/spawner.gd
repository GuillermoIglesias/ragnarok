extends Node2D

@export var spawns: Array[SpawnInfo] = []

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

var time: int = 0


func _on_timer_timeout():
	time += 1
	for spawn in spawns:
		if time >= spawn.time_start and time <= spawn.time_end and spawn.enabled:
			if spawn.delay_counter < spawn.delay:
				spawn.delay_counter += 1
			else:
				spawn.delay_counter = 0
				for i in range(spawn.mob_num):
					var new_mob = spawn.mob
					var mob =  new_mob.instantiate()
					mob.global_position = get_random_position()
					add_child(mob)


func get_random_position():
	var viewport_size_x = get_viewport().content_scale_size.x
	var viewport_size_y = get_viewport().content_scale_size.y

	var viewport_size = Vector2(viewport_size_x, viewport_size_y)
	var viewport_center = Vector2(viewport_size.x / 2, viewport_size.y / 2)

	var mob_axis = ["top", "bottom", "right", "left"].pick_random()
	var mob_spawn_x = randi_range(0, viewport_size.x)
	var mob_spawn_y = randi_range(0, viewport_size.y)

	var mob_spawn = Vector2.ZERO

	match mob_axis:
		"bottom":
			mob_spawn = Vector2(mob_spawn_x, 0)
		"right":
			mob_spawn = Vector2(viewport_size.x, mob_spawn_y)
		"top":
			mob_spawn = Vector2(mob_spawn_x, viewport_size.y)
		"left":
			mob_spawn = Vector2(0, mob_spawn_y)

	var spawn_position = viewport_center.distance_to(player.global_position)
	var spawn_direction = viewport_center.direction_to(player.global_position)
	var mob_position = mob_spawn + (spawn_position * spawn_direction)

	return mob_position
