extends Node
class_name Health

signal died
signal health_changed(amount: int)

@export var max_health: int = 10
@export var hurtbox: Hurtbox

var health: int


func _ready():
	hurtbox.hurt.connect(_on_hurt)
	health = max_health


func damage(damage_amount: int):
	health = max(health - damage_amount, 0)
	if health == 0:
		Callable(death).call_deferred()
	else:
		health_changed.emit(- damage_amount)


func heal(heal_amount: int):
	health = min(health + heal_amount, max_health)


func death():
	died.emit()
#		owner.queue_free()


func _on_hurt(damage_amount: int):
	damage(damage_amount)
