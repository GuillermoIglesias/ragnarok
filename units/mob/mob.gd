extends CharacterBody2D

@export var speed = 25
@export var health = 10
@export var attack = 5
@export var exp_points = 1

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot = get_tree().get_first_node_in_group("loot")
@onready var anim = $AnimatedSprite
@onready var hitbox = $Hitbox

@onready var exp_gem = preload("res://items/experience.tscn")

func _ready():
	hitbox.damage = attack
	anim.play("walk")


func _process(_delta):
	var target = player.global_position
	var direction = global_position.direction_to(target)
	velocity = direction * speed

	if health > 0:
		anim.flip_h = velocity.x > 0

	if position.distance_to(target) > 1:
		move_and_slide()


func _on_hurtbox_hurt(damage):
	damaged(damage)


func damaged(damage):
	health -= damage
	if health <= 0:
		death()
	else:
		anim.play("damaged")


func death():
	speed = 0
	anim.play("death")
	drop_exp()


func _on_animated_sprite_animation_finished():
	if anim.animation == "death":
		queue_free()
	elif anim.animation == "damaged":
		anim.play("walk")


func drop_exp():
	var gem = exp_gem.instantiate()
	gem.global_position = global_position
	gem.exp_points = exp_points
	loot.call_deferred("add_child", gem)
