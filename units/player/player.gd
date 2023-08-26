extends CharacterBody2D

@export var speed = 100
@export var health = 100
@export var max_health = 100

@export var level = 1
@export var experience = 0
@export var collected_exp = 0

@export var enable_spells = true

var target = position
var mobs_close = []

# Spells
@onready var Fire = preload("res://spells/fire.tscn")
@onready var Nova = preload("res://spells/nova.tscn")

# GUI
@onready var exp_bar = $GUILayer/GUI/ExpBar
@onready var level_label = $GUILayer/GUI/ExpBar/Level

@onready var anim = $AnimatedSprite


func _ready():
	level_label.text = str("Level ", level)
	set_exp_bar(experience, calc_exp_cap())
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


func _on_grab_items_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_items_area_entered(area):
	if area.is_in_group("loot"):
		var exp_points = area.collect()
		calc_exp(exp_points)

func calc_exp(exp_points):
	var exp_required = calc_exp_cap()
	collected_exp += exp_points

	# Level Up!
	if experience + collected_exp >= exp_required:
		collected_exp -= exp_required - experience
		level += 1
		experience = 0
		exp_required = calc_exp_cap()
		level_up()
	else:
		experience += collected_exp
		collected_exp = 0

	set_exp_bar(experience, exp_required)


func level_up():
	level_label.text = str("Level ", level)


func calc_exp_cap():
	var exp_cap = level

	if level < 20:
		exp_cap = level * 5
	elif level < 40:
		exp_cap = 95 * (level - 19) * 8
	else:
		exp_cap = 255 + (level - 39) * 12

	return exp_cap

func set_exp_bar(set_value, set_max_value):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value
