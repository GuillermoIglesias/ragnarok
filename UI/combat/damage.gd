extends Node2D


func set_damage_number(value, start_pos, height, spread):
	$LabelContainer/Label.text = str(value)
	$AnimationPlayer.play("rise_and_fade")

	var tween = create_tween()
	var end_pos = Vector2(randf_range(-spread, spread), -height) + start_pos
	var tween_length = $AnimationPlayer.get_animation("rise_and_fade").length

	tween.tween_property($LabelContainer, "position", end_pos, tween_length).from(start_pos)


func remove():
	if is_inside_tree():
		get_parent().remove_child(self)
