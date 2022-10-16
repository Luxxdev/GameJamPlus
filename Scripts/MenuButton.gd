extends Button

export var reference_path = ""

func _on_Button_pressed():
	match reference_path:
		"Play":
			get_tree().change_scene("res://Scenes/TestScene.tscn")
		"Replay":
			get_tree().change_scene("res://Scenes/TestScene.tscn")
		"Credits":
			get_tree().change_scene("res://Scenes/TitleScreen.tscn")
		"Quit":
			get_tree().quit()
