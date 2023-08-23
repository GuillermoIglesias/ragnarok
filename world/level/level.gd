extends Node2D

@export var enable_spells = true
@export var max_mobs = INF
@export var mob_scene: PackedScene
@export var damage_scene: PackedScene

@onready var mob_timer = $MobTimer
@onready var player = $Player
@onready var camera = $Player/Camera

func _ready():
	mob_timer.start()


func _on_mob_timer_timeout():
	var mobs = get_tree().get_nodes_in_group("mobs")
	if len(mobs) < max_mobs:
		spawn_mobs()


func spawn_mobs():
	var camera_zoom = camera.zoom
	var viewport_size_x = get_viewport().content_scale_size.x / camera_zoom.x
	var viewport_size_y = get_viewport().content_scale_size.y / camera_zoom.y

	var viewport_size = Vector2(viewport_size_x, viewport_size_y)
	var viewport_center = Vector2(viewport_size.x / 2, viewport_size.y / 2)

	var mob_axis = randi_range(1, 4)
	var mob_spawn_x = randi_range(0, viewport_size.x)
	var mob_spawn_y = randi_range(0, viewport_size.y)

	var mob_spawn = Vector2.ZERO

	match mob_axis:
		1: # Bottom
			mob_spawn = Vector2(mob_spawn_x, 0)
		2: # Right
			mob_spawn = Vector2(viewport_size.x, mob_spawn_y)
		3: # Top
			mob_spawn = Vector2(mob_spawn_x, viewport_size.y)
		4: # Left
			mob_spawn = Vector2(0, mob_spawn_y)

	var spawn_position = viewport_center.distance_to(player.position)
	var spawn_direction = viewport_center.direction_to(player.position)

	var mob = mob_scene.instantiate()
	mob.position = mob_spawn + (spawn_position * spawn_direction)
	add_child(mob)
#		mob.received_hit.connect(_on_received_hit)


func _on_player_spell_casted(spell_scene, target, location):
	if enable_spells:
		var spell = spell_scene.instantiate()
		add_child(spell)
		spell.look_at(target)
		spell.position = location


#func _on_received_hit(mob_position, damage, _critical):
#	var damage_label = damage_scene.instantiate()
#	add_child(damage_label)
#	damage_label.set_damage_number(damage, mob_position, 20, 20)
