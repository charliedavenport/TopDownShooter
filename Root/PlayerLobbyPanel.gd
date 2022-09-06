extends Panel

func set_name(name: String) -> void:
	$NameLabel.text = name

func enable_ready_btn(value : bool) -> void:
	$Button.disabled = !value
	$Button.visible = value
