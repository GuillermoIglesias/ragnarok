extends CharacterBody2D

signal getting_hit(mob_position, damage, critical)

@export var speed = 25
@export var health = 10

var target = position

@onready var player = get_tree().get_root().get_node("/root/Level/Player")


func _ready():
	$AnimatedSprite.animation = "walk"
	$AnimatedSprite.play()


func _process(delta):
	target = player.position
	velocity = position.direction_to(target) * speed * randf_range(1, 2)

	if health > 0:
		$AnimatedSprite.flip_h = velocity.x > 0

	if position.distance_to(target) > 1:
#		move_and_slide()
		var _collision = move_and_collide(velocity * delta)


func damaged(damage):
	health -= damage
	getting_hit.emit(position, damage, false)
	if health <= 0:
		speed = 0
		$AnimatedSprite.animation = "death"
	else:
		$AnimatedSprite.animation = "damaged"


func _on_animated_sprite_animation_finished():
	if $AnimatedSprite.animation == "death":
		queue_free()
	elif $AnimatedSprite.animation == "damaged":
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.play()
