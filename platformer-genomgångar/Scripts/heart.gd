extends Area2D
class_name Heart

signal pickup


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("pickup")
		$AnimationPlayer.play("pickup")
