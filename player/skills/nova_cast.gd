extends Node

@export var enabled: bool = false
@export var cooldown: float = 5.0
@export var size: float = 1.0
@export var nova_scene: PackedScene

@onready var timer: Timer = $Timer


func _ready():
	timer.wait_time = cooldown
	timer.start()


func _on_timer_timeout():
	if enabled:
		var nova = nova_scene.instantiate()
		nova.position = owner.position
		nova.size = size
		add_child(nova)
