extends Area2D

@export var exp_points = 1

var exp_green = preload("res://assets/textures/items/exp_green.png")
var exp_blue = preload("res://assets/textures/items/exp_blue.png")
var exp_red = preload("res://assets/textures/items/exp_red.png")

var target = null
var speed = -1

@onready var sprite = $Sprite
@onready var collision = $Collision

func _ready():
	if exp_points < 5:
		return
	elif exp_points < 25:
		sprite.texture = exp_blue
	else:
		sprite.texture = exp_red

func _process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta

func collect():
	collision.set_deferred("disabled", true)
	queue_free()
	return exp_points
