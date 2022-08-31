extends Panel

signal join_pressed(lobby)

var lobby : GotmLobby

func _ready():
	$Button.connect("pressed", self, "on_pressed")

func on_pressed() -> void:
	emit_signal("join_pressed", lobby)
