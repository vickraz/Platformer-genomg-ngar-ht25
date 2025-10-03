extends Node2D


@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player

const PLAYER_SCENE = preload("res://Scenes/player.tscn")

func _ready() -> void:
	player.get_node("RemoteTransform2D").remote_path = camera.get_path()
	player.connect("dead", _on_Player_dead)
	

func _on_Player_dead() -> void:
	player = PLAYER_SCENE.instantiate()
	player.get_node("RemoteTransform2D").remote_path = camera.get_path()
	player.connect("dead", _on_Player_dead)
	player.global_position = $PlayerSpawnPos.global_position
	add_child(player)
