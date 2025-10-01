extends CharacterBody2D
class_name Player

const MAX_SPEED = 300
const ACC = 2500
const JUMP_VELOCITY = 600
const GRAVITY = 1250

enum{IDLE, WALK, AIR, EDGE, DEAD}

var state = IDLE
var want_to_jump: bool = false
var jump_buffer: float = 0.0
var edge_input_x: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var left_ray: RayCast2D = $LeftRay
@onready var right_ray: RayCast2D = $RightRay
@onready var edge_timer: Timer = $EdgeStateTimer

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
	if up_direction.is_equal_approx(Vector2.UP) or up_direction.is_equal_approx(Vector2.DOWN):
		if input_x != 0:
			velocity.x =  move_toward(velocity.x, input_x*MAX_SPEED*(-sin(up_direction.angle())), ACC*delta)
		else:
			velocity.x = move_toward(velocity.x, 0, ACC*delta)
			
		velocity.y += -up_direction.y * GRAVITY * delta
		apply_floor_snap()
		move_and_slide()
	else:
		if input_x != 0:
			velocity.y =  move_toward(velocity.y, input_x*MAX_SPEED*(cos(up_direction.angle())), ACC*delta)
		else:
			velocity.y = move_toward(velocity.y, 0, ACC*delta)
		velocity.x += -up_direction.x * GRAVITY * delta
		apply_floor_snap()
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
	if left_ray.is_colliding() and not right_ray.is_colliding():
		return "right"
	elif not left_ray.is_colliding() and right_ray.is_colliding():
		return "left"
	else:
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
	var edge = _on_edge()
	if not is_on_floor() and edge == "left" and state != AIR:
		_enter_edge_state("left")
	elif not is_on_floor() and edge == "right" and state != AIR:
		_enter_edge_state("right")
	elif velocity.length() > 0 and state != AIR:
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
	var edge = _on_edge()
	if not is_on_floor() and edge == "left" and state != AIR:
		_enter_edge_state("left")
	elif not is_on_floor() and edge == "right" and state != AIR:
		_enter_edge_state("right")
	elif velocity.length() == 0:
		_enter_idle_state()

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
	_movement(delta, edge_input_x)

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
		velocity += up_direction*JUMP_VELOCITY

func _enter_edge_state(rotation_direction: String):
	state = EDGE
	floor_snap_length = 50
	edge_timer.start()
	var tween = get_tree().create_tween()
	if rotation_direction == "left":
		edge_input_x = -1
		up_direction = up_direction.rotated(-PI/2)
		tween.tween_property(self, "rotation", rotation - PI/2, 0.1)
	else:
		edge_input_x = 1
		up_direction = up_direction.rotated(PI/2)
		tween.tween_property(self, "rotation", rotation + PI/2, 0.1)


################ PUBLIC FUNCTIONS ################################
func enter_dead_state(dir: Vector2) -> void:
	print("DÖÖÖD")


################## SIGNALS #############################

func _on_edge_state_timer_timeout() -> void:
	_enter_walk_state()
	floor_snap_length = 5
