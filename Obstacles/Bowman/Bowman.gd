extends Sprite

var ARROW = preload("res://Obstacles/Bowman/Arrow.tscn")

var shooting = false
var target

onready var weapon_pivot = $"Weapon Pivot"
onready var ray = $"Weapon Pivot/RayCast2D"
onready var sprite = self
onready var anim = $AnimationPlayer
onready var bowanim = $"Bow Animation"
onready var fire_timer = $FireRate

func _ready():
	fire_timer.start()

func _process(delta):
	if target != null:
		weapon_pivot.look_at(target.global_position + (Vector2(0, -7)))
	
	sprite.flip_h = abs(weapon_pivot.rotation_degrees) > 90
	
	if shooting:
		anim.play("shooting")
	else:
		anim.play("idle")

func _shoot():
	shooting = false
	
	var arrow = ARROW.instance()
	arrow.global_position = $"Weapon Pivot/Weapon Offset".global_position
	arrow.start($"Weapon Pivot".global_transform)
	get_parent().add_child(arrow)


func _on_Detection_Zone_body_entered(body):
	target = body


func _on_FireRate_timeout():
	fire_timer.start()
	if ray.is_colliding() and ray.get_collider().name == "Player":
		shooting = true
		bowanim.play("shoot")

