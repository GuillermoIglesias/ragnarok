extends Area2D

var level = 1
var health = 1
var speed = 400
var damage = randi_range(2, 6)

@onready var anim = $AnimatedSprite
@onready var collision = $Collision


func _ready():
	anim.play("attack")


func _process(delta):
	position += transform.x * speed * delta


func spell_hit(charge = 1):
	health -= charge
	if health <= 0:
		speed = 0
		anim.play("damage")
		collision.set_deferred("disabled", true)


func _on_visible_on_screen_screen_exited():
	queue_free()


func _on_animated_sprite_animation_finished():
	if anim.animation == "damage":
		queue_free()