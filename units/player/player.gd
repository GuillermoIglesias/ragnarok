extends CharacterBody2D

signal spell_casted(spell_scene, target, location)

@export var speed = 100
@export var health = 100

var target = position

@onready var FireScene = preload("res://spells/fire/fire.tscn")
@onready var anim = $AnimatedSprite
@onready var cast_timer = $CastTimer


func _ready():
	anim.play("idle")
	cast_timer.start()


func _process(_delta):
	movement()


func movement():
	velocity = position.direction_to(target) * speed

	if position.distance_to(target) > 10:
		move_and_slide()

		anim.play("walk")
	else:
		anim.play("idle")

	if Input.is_action_pressed("left_click"):
		target = get_global_mouse_position()
		anim.flip_h = get_local_mouse_position().x < 0


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
		spell_casted.emit(FireScene, relative_mob_position, position)


func _on_hurtbox_hurt(damage):
	health -= damage
	print(health)
