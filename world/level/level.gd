extends Node2D

@export var enable_spells = true
@export var damage_scene: PackedScene


func _on_player_spell_casted(spell_scene, target, location):
	if enable_spells:
		var spell = spell_scene.instantiate()
		add_child(spell)
		spell.look_at(target)
		spell.position = location


#		mob.received_hit.connect(_on_received_hit)
#func _on_received_hit(mob_position, damage, _critical):
#	var damage_label = damage_scene.instantiate()
#	add_child(damage_label)
#	damage_label.set_damage_number(damage, mob_position, 20, 20)
