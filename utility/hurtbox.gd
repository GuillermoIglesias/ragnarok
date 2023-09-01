extends Area2D
class_name Hurtbox

signal hurt(damage: int)

@export_enum("Cooldown", "HitOnce", "DisabledHitbox") var HurtboxTypes: int

@onready var collision: CollisionShape2D = $Collision
@onready var disable_timer: Timer = $DisableTimer


func _on_area_entered(area: Area2D):
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

			if area.has_method("spell_hit"):
				area.spell_hit(1)


func _on_disable_timer_timeout():
	collision.set_deferred("disabled", false)
