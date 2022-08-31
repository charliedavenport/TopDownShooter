extends Control

onready var text_edit = get_node("TextEdit")
onready var btn = get_node("Button")

signal text_entered(text)

func _ready():
	btn.connect("pressed", self, "on_btn_pressed")

func on_btn_pressed() -> void:
	var text = text_edit.text
	if len(text) > 0:
		emit_signal("text_entered", text)
