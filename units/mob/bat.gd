extends CharacterBody2D

@export var speed: int = 30

var alive: bool = true

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var anim: AnimatedSprite2D = $AnimatedSprite
@onready var collision: CollisionShape2D = $Collision
@onready var health: Health = $Health


func _ready():
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)
	anim.play("walk")


func _process(_delta):
	var target = player.global_position
	var direction = global_position.direction_to(target)
	velocity = direction * speed

	if alive:
		anim.flip_h = velocity.x > 0

	if position.distance_to(target) > 1:
		move_and_slide()


func _on_died():
	speed = 0
	alive = false
	anim.play("death")
	collision.set_deferred("disabled", true)


func _on_health_changed(health_amount: int):
	if health_amount < 0:
		anim.play("damaged")


func _on_animated_sprite_animation_finished():
	if anim.animation == "death":
		queue_free()
	elif anim.animation == "damaged":
		anim.play("walk")
