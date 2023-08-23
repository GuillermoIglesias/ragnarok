extends Area2D

signal hurt(damage)

@export_enum("Cooldown", "HitOnce", "DisabledHitbox") var HurtboxTypes

@onready var collision = $Collision
@onready var disable_timer = $DisableTimer


func _on_area_entered(area):
	if area.is_in_group("attack"):
		if area.damage != null:
			match HurtboxTypes:
				0: # Cooldown
					collision.set_deferred("disabled", true)
					disable_timer.start()
				1: # HitOnce
					pass
				2: # Disabled Hitbox
					if area.has_method("temp_disable"):
						area.temp_disable()
			hurt.emit(area.damage)


func _on_disable_timer_timeout():
	collision.set_deferred("disabled", false)
