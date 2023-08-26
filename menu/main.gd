extends Control

@onready var level = "res://world/level.tscn"


func _on_start_pressed():
	var _level = get_tree().change_scene_to_file(level)


func _on_exit_pressed():
	get_tree().quit()
