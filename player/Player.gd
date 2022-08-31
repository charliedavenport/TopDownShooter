extends KinematicBody2D

const projectile_scene = preload("res://projectile/Projectile.tscn")

export var speed : float = 200.0
export var friction: float = 0.05

var vel : Vector2
var move_input : Vector2

func _ready():
	vel = Vector2.ZERO

func _process(delta):
	look_at(get_global_mouse_position())
	move_input = get_move_input()
	if Input.is_action_just_pressed("shoot"):
		shoot_projectile()

func _physics_process(delta):
	if move_input.length() == 0:
		vel = vel.linear_interpolate(Vector2.ZERO, friction)
	vel += move_input * speed * delta
	if vel.length() > speed:
		vel = vel.normalized() * speed
	vel = move_and_slide(vel)

func shoot_projectile() -> void:
	var proj = projectile_scene.instance()
	proj.global_position = global_position
	proj.dir = (get_global_mouse_position() - global_position).normalized()
	get_tree().root.call_deferred("add_child", proj)

func get_move_input() -> Vector2:
	var mov = Vector2()
	if Input.is_action_pressed("move_forward"):
		mov.y -= 1.0
	if Input.is_action_pressed("move_backward"):
		mov.y += 1.0
	if Input.is_action_pressed("move_left"):
		mov.x -= 1.0
	if Input.is_action_pressed("move_right"):
		mov.x += 1.0
	return mov
