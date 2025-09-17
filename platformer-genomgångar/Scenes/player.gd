extends CharacterBody2D

const MAX_SPEED = 300
const ACC = 2500
const JUMP_VELOCITY = 600
const GRAVITY = 1250

enum{IDLE, WALK, AIR, EDGE, DEAD}

var state = IDLE
var want_to_jump: bool = false
var jump_buffer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer



############### GAME LOOP ##############################
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		AIR:
			_air_state(delta)
		EDGE:
			_edge_state(delta)
		DEAD:
			_dead_state(delta)

############### GENERAL HELP FUNCTIONS ########################
func _movement(delta: float, input_x: float) -> void:
	if input_x != 0:
		velocity.x =  move_toward(velocity.x, input_x*MAX_SPEED, ACC*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACC*delta)
	velocity.y += GRAVITY * delta
	
	move_and_slide()

func _update_direction(input_x: float) -> void:
	if input_x > 0:
		sprite.flip_h = false
	elif input_x < 0:
		sprite.flip_h = true

"""
UPPGFT: skapa en funktion _on_edge() som kontrollerar om spelaren är på en kant
eller inte. Funktionen ska returnera "left", "right" eller "" beroende på. 
Detta med hjälp av Raycasts (LeftRay och RightRay)
"""
func _on_edge() -> String:
	return ""


############### STATE FUNCTIONS ########################
func _idle_state(delta: float) -> void:
	#1
	if Input.is_action_just_pressed("jump"):
		_enter_air_state(true)
	var input_x = Input.get_axis("move left", "move right")
	_update_direction(input_x)
	#2
	_movement(delta, input_x)
	#3
	if not is_on_floor():
		_enter_air_state(false)
	elif velocity.length() > 0:
		_enter_walk_state()

func _walk_state(delta: float) -> void:
	#1
	if Input.is_action_just_pressed("jump"):
		_enter_air_state(true)
	var input_x = Input.get_axis("move left", "move right")
	_update_direction(input_x)
	#2
	_movement(delta, input_x)
	#3
	if velocity.length() == 0:
		_enter_idle_state()
	elif not is_on_floor():
		_enter_air_state(false)

func _air_state(delta: float) -> void:
	#1
	if Input.is_action_just_pressed("jump"):
		want_to_jump = true
	var input_x = Input.get_axis("move left", "move right")
	_update_direction(input_x)
	#2
	_movement(delta, input_x)
	if want_to_jump:
		jump_buffer += delta
		if jump_buffer > 0.1:
			want_to_jump = false
			jump_buffer = 0.0
	#3
	if is_on_floor() and want_to_jump:
		_enter_air_state(true)
		print("hej hej hallå")
	elif is_on_floor() and velocity.length() == 0:
		_enter_idle_state()
	elif is_on_floor():
		_enter_walk_state()
		

func _edge_state(delta: float) -> void:
	pass

func _dead_state(delta: float) -> void:
	pass

############### ENTER STATE FUNCTION #######################
func _enter_idle_state():
	state = IDLE
	anim.play("Idle")

func _enter_walk_state():
	state = WALK
	anim.play("Walk")

func _enter_air_state(jumping: bool):
	state = AIR
	anim.play("Air")
	want_to_jump = false
	jump_buffer = 0.0
	if jumping:
		velocity.y = -JUMP_VELOCITY

func _enter_edge_state(rotation_direction: String):
	pass
	
func _enter_dead_state():
	pass
