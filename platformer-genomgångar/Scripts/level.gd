extends Node2D


@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player
@onready var time_label: Label = $HUD/TimeLabel
@onready var heart: Heart = $Heart

const PLAYER_SCENE = preload("res://Scenes/player.tscn")

var time: float = 0.0
var level_completed: bool = false

@export var level = 1

func _ready() -> void:
	player.get_node("RemoteTransform2D").remote_path = camera.get_path()
	player.connect("dead", _on_Player_dead)
	heart.connect("pickup", _on_Heart_pickup)

func _process(delta: float) -> void:
	if not level_completed:
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

func _on_Heart_pickup():
	level_completed = true
	LevelManager.change_to_next_level(level)
