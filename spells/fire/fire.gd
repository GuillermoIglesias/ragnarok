extends Area2D

@export var speed = 400
@export var damage = randi_range(2, 6)

@onready var anim = $AnimatedSprite
@onready var collision = $Collision


func _ready():
	anim.play("attack")


func _process(delta):
	position += transform.x * speed * delta


func _on_body_entered(body):
	if body.is_in_group("mobs") and speed > 0:
		spell_hit(body)


func spell_hit(body):
	speed = 0
	body.damaged(damage)
	anim.play("damage")
	collision.set_deferred("disabled", true)


func _on_visible_on_screen_screen_exited():
	queue_free()


func _on_animated_sprite_animation_finished():
	if anim.animation == "damage":
		queue_free()