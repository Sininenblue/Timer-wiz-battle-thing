extends Area2D

export(String, FILE) var node_path
onready var anim = $Transitions/AnimationPlayer

func _on_LevelComplete_body_entered(body):
	body.win()
	anim.play("Ding")
	yield(anim, "animation_finished")
	get_tree().change_scene(node_path)
