extends CharacterBody2D

signal cast_spell(spell_scene, target, location)

@export var speed = 100
@export var health = 100

@onready var spell_scene = preload("res://effects/fire/fire.tscn")

var target = position

func _ready():
	$AnimatedSprite.animation = "idle"
	$AnimatedSprite.play()
	$CastTimer.start()

func _process(delta):
	velocity = position.direction_to(target) * speed

	if position.distance_to(target) > 10:
#		move_and_slide()
		var _collision = move_and_collide(velocity * delta)
#		if collision:
#			print("Collision")

		$AnimatedSprite.animation = "walk"
	else:
		$AnimatedSprite.animation = "idle"

	if Input.is_action_pressed("left_click"):
		target = get_global_mouse_position()
		$AnimatedSprite.flip_h = get_local_mouse_position().x < 0

func _on_cast_timer_timeout():
	var mobs = get_tree().get_nodes_in_group("mobs")
	var shortest_distance = INF
	var closest_mob = null

	for mob in mobs:
		if not is_instance_valid(mob):
			continue

		var distance = position.distance_to(mob.position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_mob = mob

	if shortest_distance < INF:
		var relative_mob_position = position.direction_to(closest_mob.position)
		cast_spell.emit(spell_scene, relative_mob_position, position)

