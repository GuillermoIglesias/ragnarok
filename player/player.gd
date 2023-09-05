extends CharacterBody2D

@export var base_speed = 60.0
@export var speed = 60.0

@export var level = 1
@export var experience = 0
@export var collected_exp = 0

var upgrade_options = []
var collected_upgrades = []

var mouse_enabled = false
var target = global_position
var clock_seconds = 0

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

@onready var health: Health = $Health


func _ready():
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)
	exp_label.text = str("Level ", level)
	set_exp_bar(experience, calc_exp_cap())
	set_health_bar(health.max_health, health.max_health)
	level_menu.visible = false
	pause_menu.visible = false
	anim.play("idle")
	clock.text = "00:00"


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


func _on_health_changed(_health_amount: int):
	set_health_bar(health.health, health.max_health)
	print("Damage: ", _health_amount)


func _on_died():
	var _level = get_tree().change_scene_to_file("res://menu/main.tscn")


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
		health.armor += 1
	elif upgrade.begins_with("speed"):
		speed += base_speed * 0.5
	elif upgrade.begins_with("tome"):
#		spell_size += 0.10
		pass
	elif upgrade.begins_with("scroll"):
#		spell_cooldown += 0.05
#		set_spell_timers()
		pass
	elif upgrade.begins_with("ring"):
#		additional_spells += 1
		pass
	elif upgrade.begins_with("food"):
		health.heal(20)

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


func _on_level_timer_timeout():
	clock_seconds += 1
	var minutes = ("0" + str(int(clock_seconds / 60.0))).right(2)
	var seconds = ("0" + str(clock_seconds % 60)).right(2)
	clock.text = minutes + ":" + seconds
