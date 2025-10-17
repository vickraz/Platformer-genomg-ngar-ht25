extends Node2D

const SAVE_PATH = "user://gravityplatformer_savefile.data"
const PLAYER_SCENE = preload("res://Scenes/player.tscn")

@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player
@onready var time_label: Label = $HUD/TimeLabel
@onready var heart: Heart = $Heart
@onready var hearts_container: HBoxContainer = $HUD/HeartsContainer
@onready var highscore_label: Label = $HUD/HighscoreLabel

var time: float = 0.0
var level_completed: bool = false
var highscores: Dictionary = {}

@export var level = 1

func _ready() -> void:
	player.get_node("RemoteTransform2D").remote_path = camera.get_path()
	player.connect("dead", _on_Player_dead)
	heart.connect("pickup", _on_Heart_pickup)
	_get_highscores()
	if name in highscores:
		var time_string = _from_seconds_to_time(highscores[name])
		highscore_label.text = "Best: " + time_string
	else:
		highscore_label.text = ""
	_update_heart_symbols()
	#print(highscores)

func _process(delta: float) -> void:
	if not level_completed:
		time += delta
		
		var time_string = _from_seconds_to_time(time)
		
		time_label.text = "Time: " + time_string


func _on_Player_dead() -> void:
	Globals.lives -= 1
	_update_heart_symbols()
	if Globals.lives > 0:
		player = PLAYER_SCENE.instantiate()
		player.get_node("RemoteTransform2D").remote_path = camera.get_path()
		player.connect("dead", _on_Player_dead)
		player.global_position = $PlayerSpawnPos.global_position
		add_child(player)
	else:
		print("Game over")

func _on_Heart_pickup():
	level_completed = true
	LevelManager.change_to_next_level(level)
	
	if name in highscores:
		#Ett befintligt highscore finns
		if time < highscores[name]:
			_save_highscore(name)
	else:
		#Om den inte finns i highscores är det första gången leveln klaras -> highscore
		_save_highscore(name)

func _get_highscores() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		highscores = file.get_var() #Hämtar den sparade variabeln
		file.close()
	

func _save_highscore(level_name: String) -> void:
	highscores[level_name] = time #Ändrar på värdet om det finns eller lägger till om det inte finns
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE) #Finns ej filen skapas den automatiskt
	file.store_var(highscores)
	file.close()

func _update_heart_symbols() -> void:
	var lives_lost = 3 - Globals.lives
	var deactivates_hearts = 0
	for child in hearts_container.get_children():
		if deactivates_hearts < lives_lost:
			child.hide()
			deactivates_hearts += 1

func _from_seconds_to_time(seconds: float) -> String:
	var min = int(seconds / 60)
	var sec = int(seconds - min*60)
	return "%02d:%02d" % [min, sec]
