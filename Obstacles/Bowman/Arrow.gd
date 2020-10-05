extends Area2D

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var speed = 16 * 20

onready var hitsfx = $AudioStreamPlayer

func start(_transform):
	global_transform = _transform
	velocity = transform.x * speed


func _physics_process(delta):
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta


func _on_Arrow_body_entered(body):
	if body.has_method('kill'):
		body.kill()
	hitsfx.play()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite.set_deferred("visible", false)
	yield(hitsfx, "finished")
	call_deferred("queue_free")
