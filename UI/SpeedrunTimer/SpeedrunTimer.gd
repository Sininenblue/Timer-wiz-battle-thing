extends Control

onready var label = $CanvasLayer/Label

var ms = 0
var s = 0
var m = 0

func start():
	$ms.start()
	$AudioStreamPlayer.play()

func stop():
	$ms.stop()

func _process(delta):
	if ms > 9:
		s += 1
		ms = 0
	
	if s > 59:
		m += 1
		s = 0
	
	label.text = str(m,":",s,":",ms)


func _on_Timer_timeout():
	ms += 1
