extends CharacterBody2D

@export var base_speed = 60.0
@export var speed = base_speed
@export var health = 100
@export var max_health = 100
@export var armor = 0

@export var spell_size = 0
@export var spell_cooldown = 0

@export var level = 1
@export var experience = 0
@export var collected_exp = 0

@export var enable_spells = true
@export var additional_spells = 0

var fire_base_ammo = 1
var fire_ammo = 0

var upgrade_options = []
var collected_upgrades = []

var mouse_enabled = false
var target = global_position
var mobs_close = []
var mobs_radar = []
var clock_seconds = 0

# Spells
@onready var Fire = preload("res://spells/fire.tscn")
@onready var Nova = preload("res://spells/nova.tscn")

# Upgrades
@onready var Option = preload("res://menu/option.tscn")

# GUI
@onready var health_bar = $GUILayer/GUI/HealthBar
@onready var exp_bar = $GUILayer/GUI/ExpBar
@onready var exp_label = $GUILayer/GUI/ExpBar/Level
@onready var level_menu = $GUILayer/GUI/LevelUp
@onready var level_title = $GUILayer/GUI/LevelUp/Title
@onready var level_options = $GUILayer/GUI/LevelUp/Options
@onready var pause_menu = $GUILayer/GUI/Pause
@onready var clock = $GUILayer/GUI/Clock

@onready var anim = $AnimatedSprite
@onready var fire_timer = $FireTimer
@onready var nova_timer = $NovaTimer
@onready var fire_cast_timer = $FireCastTimer



func _ready():
	exp_label.text = str("Level ", level)
	set_exp_bar(experience, calc_exp_cap())
	set_health_bar(health, max_health)
	level_menu.visible = false
	pause_menu.visible = false
	anim.play("idle")
	clock.text = "00:00"
	set_spell_timers()


func _process(_delta):
	movement()
	pause()


func movement():
	if Input.is_action_just_pressed("left_click"):
		mouse_enabled = true

	if mouse_enabled:
		velocity = global_position.direction_to(target) * speed

		if global_position.distance_to(target) > 10:
			move_and_slide()
			anim.play("walk")
		else:
			anim.play("idle")

		if Input.is_action_pressed("left_click"):
			target = get_global_mouse_position()
			var mouse_x = get_viewport().get_mouse_position().x
			var center_x = get_viewport_rect().get_center().x
			anim.flip_h = mouse_x < center_x

		if Input.is_action_just_pressed("keyboard_movement"):
			mouse_enabled = false

	else:
		var mov = Input.get_vector("left", "right", "up", "down")
		velocity = mov.normalized() * speed

		move_and_slide()

		if mov.length() != 0:
			anim.flip_h = mov.x < 0
			anim.play("walk")
		else:
			anim.play("idle")


func set_spell_timers():
	fire_timer.wait_time *= (1 - spell_cooldown)
	nova_timer.wait_time *= (1 - spell_cooldown)


func pause():
	if Input.is_action_just_pressed("pause"):
		var tween = pause_menu.create_tween()
		tween.tween_property(pause_menu, "position", Vector2(220, 50), 0.2)
		tween.set_trans(Tween.TRANS_QUINT)
		tween.set_ease(Tween.EASE_IN)
		tween.play()

		get_tree().paused = true
		pause_menu.visible = true


func _on_continue_pressed():
	if pause_menu.visible:
		pause_menu.position = Vector2(220, -300)
		pause_menu.visible = false
		get_tree().paused = false


func _on_hurtbox_hurt(damage):
	health -= clamp(damage - armor, 1, 999)
	set_health_bar(health, max_health)
	if health <= 0:
		death()


func _on_detector_body_entered(body):
	if not mobs_radar.has(body):
		mobs_radar.append(body)


func _on_detector_body_exited(body):
	if mobs_radar.has(body):
		mobs_radar.erase(body)


func _on_fire_timer_timeout():
	if enable_spells:
		mobs_close.clear()
		fire_ammo = fire_base_ammo + additional_spells
		fire_cast_timer.start()


func _on_fire_cast_timer_timeout():
	if fire_ammo > 0:
		var closest_mob = get_closest_mob()

		if closest_mob != null:
			var fire = Fire.instantiate()
			fire.look_at(closest_mob)
			fire.position = position
			add_child(fire)

			fire_ammo -= 1
			if fire_ammo > 0:
				fire_cast_timer.start()


func get_closest_mob():
	var shortest_distance = INF
	var closest_mob = null

	for mob in mobs_radar:
		if not is_instance_valid(mob):
			continue

		if mobs_close.has(mob):
			continue

		var distance = position.distance_to(mob.position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_mob = mob

	var relative_mob_direction = null

	if shortest_distance < INF:
		mobs_close.append(closest_mob)
		relative_mob_direction = position.direction_to(closest_mob.position)

	return relative_mob_direction


func _on_nova_timer_timeout():
	if enable_spells:
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
	exp_label.text = str("Level ", level)

	var tween = level_menu.create_tween()
	tween.tween_property(level_menu, "position", Vector2(220, 50), 0.2)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN)
	tween.play()

	level_menu.visible = true
	var max_options = 3

	for i in range(max_options):
		var option_choice = Option.instantiate()
		option_choice.item = get_random_option()
		level_options.add_child(option_choice)

	get_tree().paused = true


func get_random_option():
	var dblist = []

	for up in UpgradeDB.UPGRADES:
		# Check if Upgrade already collected
		if up in collected_upgrades:
			continue

		# Check if Upgrade is already an option
		if up in upgrade_options:
			continue

		# Check if Upgrade is not an item (ie. Food)
		if UpgradeDB.UPGRADES[up]["type"] == "item":
			continue

		# Check if PreRequisites are fullfil
		if UpgradeDB.UPGRADES[up]["requires"].size() > 0:
			var to_add = true
			for requisite in UpgradeDB.UPGRADES[up]["requires"]:
				if not requisite in collected_upgrades:
					to_add = false
			if not to_add:
				continue

		dblist.append(up)

	if dblist.size() > 0:
		var random_option = dblist.pick_random()
		upgrade_options.append(random_option)
		return random_option

	return null


func set_upgrade(upgrade):
	if upgrade.begins_with("armor"):
		armor += 1
	elif upgrade.begins_with("speed"):
		speed += base_speed * 0.5
	elif upgrade.begins_with("tome"):
		spell_size += 0.10
	elif upgrade.begins_with("scroll"):
		spell_cooldown += 0.05
		set_spell_timers()
	elif upgrade.begins_with("ring"):
		additional_spells += 1
	elif upgrade.begins_with("food"):
		health += 20
		clamp(health, 0, max_health)
		set_health_bar(health, max_health)

	var options = level_options.get_children()
	for option in options:
		option.queue_free()

	collected_upgrades.append(upgrade)
	upgrade_options.clear()

	level_menu.visible = false
	level_menu.position = Vector2(800, 50)
	get_tree().paused = false

	calc_exp(0)


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

func set_health_bar(set_value, set_max_value):
	health_bar.value = set_value
	health_bar.max_value = set_max_value


func death():
	var _level = get_tree().change_scene_to_file("res://menu/main.tscn")


func _on_level_timer_timeout():
	clock_seconds += 1
	var minutes = ("0" + str(int(clock_seconds / 60.0))).right(2)
	var seconds = ("0" + str(clock_seconds % 60)).right(2)
	clock.text = minutes + ":" + seconds
