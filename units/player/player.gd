extends CharacterBody2D

@export var speed = 100
@export var health = 100
@export var enable_spells = true

var target = position
var mobs_close = []

@onready var Fire = preload("res://spells/fire.tscn")
@onready var Nova = preload("res://spells/nova.tscn")
@onready var anim = $AnimatedSprite


func _ready():
	anim.play("idle")


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


func _on_hurtbox_hurt(damage):
	health -= damage
	print(health)


func _on_detector_body_entered(body):
	if not mobs_close.has(body):
		mobs_close.append(body)


func _on_detector_body_exited(body):
	if mobs_close.has(body):
		mobs_close.erase(body)


func _on_fire_timer_timeout():
	var closest_mob = get_closest_mob()
	if closest_mob != null and enable_spells:
		var fire = Fire.instantiate()
		fire.look_at(closest_mob)
		fire.position = position
		add_child(fire)


func get_closest_mob():
	var shortest_distance = INF
	var closest_mob = null

	for mob in mobs_close:
		if not is_instance_valid(mob):
			continue

		var distance = position.distance_to(mob.position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_mob = mob

	var relative_mob_direction = null

	if shortest_distance < INF:
		relative_mob_direction = position.direction_to(closest_mob.position)

	return relative_mob_direction


func _on_nova_timer_timeout():
	var nova = Nova.instantiate()
	nova.position = position
	add_child(nova)
