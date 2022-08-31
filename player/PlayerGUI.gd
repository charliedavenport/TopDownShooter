extends Control

onready var player = get_parent()

func _ready():
	set_as_toplevel(true)

func _process(delta):
	rect_global_position = player.global_position + Vector2(-36, -60)
