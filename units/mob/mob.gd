extends CharacterBody2D

#signal received_hit(mob_position, damage, critical)

@export var speed = 25
@export var health = 10

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $AnimatedSprite


func _ready():
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
#	received_hit.emit(position, damage, false)
	if health <= 0:
		speed = 0
		anim.play("death")
	else:
		anim.play("damaged")


func _on_animated_sprite_animation_finished():
	if anim.animation == "death":
		queue_free()
	elif anim.animation == "damaged":
		anim.play("walk")
