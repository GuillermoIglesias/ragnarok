extends Node2D

@export var mob_scene: PackedScene
@export var damage_scene: PackedScene


func _ready():
	$MobTimer.start()


func _on_mob_timer_timeout():
	var camera_zoom = $Player/Camera.zoom
	var viewport_size_x = get_viewport().size.x / camera_zoom.x
	var viewport_size_y = get_viewport().size.y / camera_zoom.y

	var viewport_size = Vector2(viewport_size_x, viewport_size_y)
	var viewport_center = Vector2(viewport_size.x / 2, viewport_size.y / 2)

	var mob_axis = randi_range(1, 4)
	var mob_spawn_x = randi_range(0, viewport_size.x)
	var mob_spawn_y = randi_range(0, viewport_size.y)

	var mob_spawn = Vector2.ZERO

	match mob_axis:
		1:
			mob_spawn = Vector2(mob_spawn_x, 0)
		2:
			mob_spawn = Vector2(viewport_size.x, mob_spawn_y)
		3:
			mob_spawn = Vector2(mob_spawn_x, viewport_size.y)
		4:
			mob_spawn = Vector2(0, mob_spawn_y)

	var spawn_position = viewport_center.distance_to($Player.position)
	var spawn_direction = viewport_center.direction_to($Player.position)

	var mob = mob_scene.instantiate()
	mob.position = mob_spawn + (spawn_position * spawn_direction)
	add_child(mob)
#	mob.getting_hit.connect(_on_getting_hit)


func _on_player_cast_spell(spell_scene, target, location):
	var spell = spell_scene.instantiate()
	add_child(spell)
	spell.look_at(target)
	spell.position = location


#func _on_getting_hit(mob_position, damage, _critical):
#	var damage_label = damage_scene.instantiate()
#	add_child(damage_label)
#	damage_label.set_damage_number(damage, mob_position, 20, 20)
