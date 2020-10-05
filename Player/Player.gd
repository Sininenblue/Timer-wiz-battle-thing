extends KinematicBody2D

var RUNFX = preload("res://Particle Effects/Run.tscn")
var JUMPFX = preload("res://Particle Effects/Jump.tscn")
var LANDFX = preload("res://Particle Effects/Land.tscn")
var DEATHFX = preload("res://Particle Effects/Death.tscn")

var velocity            = Vector2.ZERO
#var previous_velocity   = Vector2.ZERO
var gravity             = 400
var jump                = 150
var speed               = 16 * 5
var x_input             = 1

var state = MOVE
enum{
	MOVE,
	WALLSLIDING
}


var on_wall             = false
var right_wall          = false
var left_wall           = false
var wall_direction      = 1
var on_floor            = false
var hit_ground          = false

var recording = true
var rewinding = false
var pos = []
var rot = []
var memory = 100

onready var sprite      = $Sprite
onready var anim        = $AnimationTree.get("parameters/playback")
onready var wallfx      = $Particles/Wall
onready var coyotetimer = $"Timers/Coyote Timer"
onready var jumpbuffer  = $"Timers/Jump Buffer"
onready var upper_left  = $"Raycasts/Wall/Upper Left"
onready var lower_left  = $"Raycasts/Wall/Lower Left"
onready var upper_right = $"Raycasts/Wall/Upper Right"
onready var lower_right = $"Raycasts/Wall/Lower Right"
onready var left        = $Raycasts/Floor/Left
onready var middle      = $Raycasts/Floor/Middle
onready var right       = $Raycasts/Floor/Right
onready var camera      = $Camera2D
onready var clock       = $Clock
onready var clockanim   = $Clock/AnimationPlayer
onready var jumpsfx     = $Sounds/jump
onready var bellsfx     = $Sounds/ding


func _ready():
	pass


func _physics_process(delta):

	rewind()
	_state_transitions()
	_handle_animations()
	_ray_collisions()
	velocity.y += gravity * delta
	
	if recording:
		match state:
			MOVE:
				x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
				
				if on_floor:
					velocity.x = lerp(velocity.x, x_input * speed, .5)
				else:
					velocity.x = lerp(velocity.x, x_input * speed, .2)
				
				if on_floor:
					coyotetimer.start()
				if Input.is_action_just_pressed("ui_up"):
					jumpbuffer.start()
				
				if coyotetimer.time_left != 0 and jumpbuffer.time_left != 0:
					_spawn_jump_particles(-x_input)
					jumpbuffer.stop()
					coyotetimer.stop()
					velocity.y = -jump 
				
				if Input.is_action_just_released("ui_up") and velocity.y < -jump/2:
					velocity.y = -jump/2
			WALLSLIDING:
				x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
				velocity.x = lerp(velocity.x, x_input * speed, .2)
				
				if Input.is_action_just_pressed("ui_up"):
					_spawn_jump_particles(wall_direction)
					velocity = Vector2(jump * -wall_direction, -jump * 5)
				
				if Input.is_action_pressed("ui_down"):
					velocity.y = lerp(velocity.y, 0, .1)
				else:
					velocity.y = lerp(velocity.y, 0, .6)

	
#	previous_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)

func _state_transitions():
	match state:
		MOVE:
			if on_wall:
				state = WALLSLIDING
		WALLSLIDING:
			if !on_wall or on_floor:
				state = MOVE

func _handle_animations():
	if x_input != 0:
		sprite.flip_h = x_input < 0
	match state:
		MOVE:
			wallfx.emitting = false
			if on_floor:
				if hit_ground == false:
#					print(previous_velocity)
#					if previous_velocity.y > 230:
#						camera.add_trauma(.1)
					hit_ground = true
					anim.travel("land")
				if x_input != 0:
					anim.travel("run")
				else:
					anim.travel("idle")
			else:
				hit_ground = false
				if abs(velocity.y) < (jump / 3):
					anim.travel("air")
				else:
					if velocity.y < 0:
						anim.travel("jump")
					else:
						anim.travel("fall")
		WALLSLIDING:
			if on_wall and !on_floor:
				wallfx.emitting = true
				wallfx.position.x = wall_direction * 3
				anim.travel("wall")


func _spawn_run_particles():
	if on_floor:
		var runfx = RUNFX.instance()
		runfx.global_position = global_position
		runfx.process_material.direction.x = -x_input
		get_parent().add_child(runfx)

func _spawn_jump_particles(direction):
	var jumpfx = JUMPFX.instance()
	jumpfx.global_position = global_position
	jumpfx.process_material.direction.x = direction
	get_parent().add_child(jumpfx)

func _spawn_land_particles():
	var landfx = LANDFX.instance()
	landfx.global_position = global_position
	get_parent().add_child(landfx)

func _spawn_death_particles():
	var deathfx = DEATHFX.instance()
	deathfx.global_position = global_position
	get_parent().add_child(deathfx)


func _ray_collisions():
	if left.is_colliding() or middle.is_colliding() or right.is_colliding():
		on_floor = true
	else:
		on_floor = false
	
	if upper_left.is_colliding() or lower_left.is_colliding():
		left_wall = true
	else:
		left_wall = false
	
	if upper_right.is_colliding() or lower_right.is_colliding():
		right_wall = true
	else:
		right_wall = false
	
	if right_wall:
		wall_direction = 1
	else:
		wall_direction = -1
	
	if left_wall or right_wall:
		on_wall = true
	else:
		on_wall = false

func kill():
	clockanim.play("Pding")
	_spawn_death_particles()
	camera.add_trauma(.2)
	recording = false
	rewinding = true


func win():
	$CollisionShape2D.set_deferred("disabled", true)
	camera.add_trauma(.1)
	set_physics_process(false)


func rewind():
	if recording:
		if pos.size() > memory:
			pos.remove(0)
			rot.append(0)
	elif rewinding:
		if pos.size() > 0:
			position = pos[pos.size() - 1]
			rotation = rot[rot.size() - 1]
			pos.remove(pos.size() - 1)
			rot.remove(rot.size() - 1)
		else:
			get_tree().reload_current_scene()

func _on_Rewind_Speed_timeout():
	if recording:
		pos.append(position)
		rot.append(rotation)
