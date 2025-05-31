extends KinematicBody

var speed = 10
var accel = 20
var gravity = 9.8
var jump = 5

var mousesense = 0.05
var dire = Vector3()
var vel = Vector3()
var fall = Vector3()

onready var head = $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Esconde e prende o cursor no início

func _input(event):
	if Input.is_action_just_pressed("shot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Esconde e prende o cursor

	if Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Mostra o cursor
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mousesense))
		head.rotate_x(deg2rad(-event.relative.y * mousesense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-30), deg2rad(15))

func _physics_process(delta):
	dire = Vector3()

	# Gravidade
	if not is_on_floor():
		fall.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = jump

	# Movimento
	if Input.is_action_pressed("w"):
		dire -= transform.basis.z
	if Input.is_action_pressed("a"):
		dire -= transform.basis.x
	elif Input.is_action_pressed("s"):
		dire += transform.basis.z
	elif Input.is_action_pressed("d"):
		dire += transform.basis.x

	dire = dire.normalized()
	vel = vel.linear_interpolate(dire * speed, accel * delta) 
	vel = move_and_slide(vel, Vector3.UP)
	move_and_slide(fall, Vector3.UP)
