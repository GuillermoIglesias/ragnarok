extends Area2D

var level = 1
var damage = randi_range(10, 20)

@onready var anim = $AnimatedSprite


func _ready():
	anim.play("attack")


func _on_animated_sprite_animation_finished():
	queue_free()
