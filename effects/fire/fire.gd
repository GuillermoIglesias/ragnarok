extends Area2D

@export var speed = 400
@export var damage = randi_range(2, 6)

func _ready():
	$AnimatedSprite.animation = "attack"
	$AnimatedSprite.play()

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.is_in_group("mobs"):
		body.damaged(damage)
	speed = 0
	$AnimatedSprite.animation = "damage"
	$Collision.set_deferred("disabled", true)

func _on_visible_on_screen_screen_exited():
	queue_free()

func _on_animated_sprite_animation_finished():
	if $AnimatedSprite.animation == "damage":
		queue_free()
