extends Node2D

onready var left = $Left
onready var right = $Right

func _ready():
	left.emitting = true
	right.emitting = true
	yield(get_tree().create_timer(left.lifetime), "timeout")
	call_deferred("queue_free")
