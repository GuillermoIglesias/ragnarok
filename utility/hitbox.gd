extends Area2D

@export var damage = 5

@onready var collision = $Collision
@onready var disable_timer = $DisableTimer

func temp_disable():
	collision.set_deferred("disabled", true)
	disable_timer.start()


func _on_disable_timer_timeout():
	collision.set_deferred("disabled", false)
