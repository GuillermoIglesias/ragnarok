extends Area2D
class_name Nova

var level = 1
var damage = randi_range(8, 15)
var size = 1.0

@onready var player = get_tree().get_first_node_in_group("player")

@onready var anim = $AnimatedSprite


func _ready():
	anim.play("attack")

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * size, 1)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.play()


func _on_animated_sprite_animation_finished():
	queue_free()
