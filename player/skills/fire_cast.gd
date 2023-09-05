extends Node

@export var enabled: bool = false
@export var cooldown: float = 1.0
@export var size: float = 1.0
@export var base_ammo: int = 1
@export var additional_spells: int = 0

@export var fire_scene: PackedScene

@onready var timer: Timer = $Timer
@onready var cast_timer: Timer = $CastTimer

var mobs_close: Array[CharacterBody2D]
var mobs_radar: Array[CharacterBody2D]
var current_ammo: int


func _ready():
	timer.wait_time = cooldown
	timer.start()


func _on_timer_timeout():
	mobs_close.clear()
	current_ammo = base_ammo + additional_spells
	cast_timer.start()


func _on_cast_timer_timeout():
	if current_ammo > 0:
		var closest_mob = get_closest_mob()

		if closest_mob != null:
			var fire = fire_scene.instantiate()
			fire.look_at(closest_mob)
			fire.global_position = owner.global_position
			add_child(fire)

			current_ammo -= 1
			if current_ammo > 0:
				cast_timer.start()


func get_closest_mob():
	var shortest_distance = INF
	var closest_mob = null

	for mob in mobs_radar:
		if not is_instance_valid(mob):
			continue

		if mobs_close.has(mob):
			continue

		var distance = owner.global_position.distance_to(mob.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_mob = mob

	var mob_direction = null

	if shortest_distance < INF:
		mobs_close.append(closest_mob)
		mob_direction = owner.global_position.direction_to(closest_mob.global_position)

	return mob_direction


func _on_detector_body_entered(body):
	if not mobs_radar.has(body):
		mobs_radar.append(body)


func _on_detector_body_exited(body):
	if mobs_radar.has(body):
		mobs_radar.erase(body)
