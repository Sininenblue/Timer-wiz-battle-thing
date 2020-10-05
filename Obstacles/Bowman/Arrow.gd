extends Area2D

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var speed = 16 * 20

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
	
	call_deferred("queue_free")
