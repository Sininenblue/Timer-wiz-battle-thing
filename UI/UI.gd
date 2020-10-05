extends CanvasLayer

onready var label = $Label
var characters_visible = 1

func _process(delta):
	label.visible_characters = characters_visible


func _on_TextSpeed_timeout():
	if characters_visible <= label.get_total_character_count():
		characters_visible += 1
