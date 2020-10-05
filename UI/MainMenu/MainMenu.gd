extends Control

export(String, FILE) var node_path

func _on_TextureButton_button_up():
	get_tree().change_scene(node_path)
	SpeedrunTimer.start()
