extends KinematicBody2D

export var speed : float = 1000.0
var dir : Vector2

func _physics_process(delta):
	var col = move_and_collide(dir * speed * delta)
	if col:
		queue_free()
