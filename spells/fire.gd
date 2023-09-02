extends Area2D

var level = 1
var health = 1
var speed = 500
var damage = randi_range(2, 6)
var size = 1.0

@onready var player = get_tree().get_first_node_in_group("player")

@onready var anim = $AnimatedSprite
@onready var collision = $Collision


func _ready():
	anim.play("attack")

	size = 1.0 * (1 + player.spell_size)

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * size, 1)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.play()


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
