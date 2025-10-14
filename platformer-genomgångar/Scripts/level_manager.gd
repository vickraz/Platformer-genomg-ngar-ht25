extends Node2D


const LAST_LEVEL = 2
const LEVEL_PATH = "res://Scenes/level_"

@onready var anim: AnimationPlayer = $AnimationPlayer

func change_to_next_level(current_level:int) -> void:
	if current_level < LAST_LEVEL:
		anim.play("fade_in")
		await anim.animation_finished
		get_tree().change_scene_to_file(LEVEL_PATH + str(current_level + 1) + ".tscn")
		anim.play("fade_out")
	else:
		anim.play("fade_in")
		await anim.animation_finished
		get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
		anim.play("fade_out")
