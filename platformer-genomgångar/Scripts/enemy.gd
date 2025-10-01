extends CharacterBody2D
class_name Enemy

const SPEED = 100
const GRAVITY = 1200

@onready var left_ray: RayCast2D = $LeftRay
@onready var right_ray: RayCast2D = $RightRay
@onready var turn_cooldown_timer: Timer = $TurnCooldownTimer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var dir: int = 1
var can_turn = true

func _on_edge() -> bool:
	if left_ray.is_colliding() and not right_ray.is_colliding():
		return true
	elif not left_ray.is_colliding() and right_ray.is_colliding():
		return true
	else:
		return false


func _physics_process(delta: float) -> void:
	velocity = up_direction.rotated(PI/2) * dir * SPEED
	velocity += -up_direction*GRAVITY*delta
	move_and_slide()
	
	if _on_edge() and can_turn:
		dir *= -1
		can_turn = false
		turn_cooldown_timer.start()
		anim.flip_h = not anim.flip_h



func _on_turn_cooldown_timer_timeout() -> void:
	can_turn = true


func _on_player_detect_area_body_entered(body: Node2D) -> void:
	if body is Player:
		var direction_to_player = global_position.direction_to(body.global_position)
		body.enter_dead_state(direction_to_player)
		
