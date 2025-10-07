extends Node2D


@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player
@onready var time_label: Label = $HUD/TimeLabel

const PLAYER_SCENE = preload("res://Scenes/player.tscn")

var time: float = 0.0

@export var level = 1

func _ready() -> void:
	player.get_node("RemoteTransform2D").remote_path = camera.get_path()
	player.connect("dead", _on_Player_dead)

func _process(delta: float) -> void:
	time += delta
	
	var min = int(time / 60)
	var sec = int(time - min*60)
	
	time_label.text = "Time: " + "%02d:%02d" % [min, sec]
	
	


func _on_Player_dead() -> void:
	player = PLAYER_SCENE.instantiate()
	player.get_node("RemoteTransform2D").remote_path = camera.get_path()
	player.connect("dead", _on_Player_dead)
	player.global_position = $PlayerSpawnPos.global_position
	add_child(player)
