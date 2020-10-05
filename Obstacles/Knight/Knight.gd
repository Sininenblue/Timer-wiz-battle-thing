extends KinematicBody2D

var RUNFX = preload("res://Particle Effects/Run.tscn")

var velocity = Vector2.ZERO
var speed = 16 * 5
export(int) var direction = 1

var charging = false

onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var ray = $RayCast2D
onready var spear = $Spear
onready var left = $left
onready var right = $right

func _process(delta):
	velocity.y += 350 * delta
	
	if ray.is_colliding():
		charging = true
	if charging == true:
		animation.play("Run")
		velocity.x = lerp(velocity.x, speed * direction, .2)
	else:
		animation.play("idle")
	
	if left.is_colliding():
		direction = 1
	if right.is_colliding():
		direction = -1
	
	sprite.flip_h = direction < 0
	ray.cast_to.x = direction * 150
	spear.position.x = direction * 16
	
	velocity = move_and_slide(velocity, Vector2.UP)


func _spawn_run_particles():
	if is_on_floor():
		var runfx = RUNFX.instance()
		runfx.global_position = global_position
		runfx.process_material.direction.x = -direction
		get_parent().add_child(runfx)


func _on_Spear_body_entered(body):
	body.kill()
