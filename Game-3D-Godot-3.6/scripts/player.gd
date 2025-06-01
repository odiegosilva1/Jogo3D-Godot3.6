extends KinematicBody

# Configurações de movimento
export var speed = 10.0
export var acceleration = 5.0
export var deceleration = 10.0
export var gravity = -24.8
export var jump_force = 12.0
export var mouse_sensitivity = 0.3

# Configurações da câmera em terceira pessoa
export var camera_distance = 8.0
export var min_camera_angle = -30.0
export var max_camera_angle = 90.0
export var camera_collision_offset = 0.5

# Variáveis de movimento
var velocity = Vector3()
var snap_vector = Vector3()

# Referências
var camera_pivot = null
var camera = null
var spring_arm = null

func _ready():
	# Configura os nós da câmera
	setup_camera_nodes()
	
	# Configuração do mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func setup_camera_nodes():
	# Cria ou obtém o CameraPivot
	if not has_node("CameraPivot"):
		camera_pivot = Spatial.new()
		camera_pivot.name = "CameraPivot"
		add_child(camera_pivot)
		camera_pivot.owner = get_tree().edited_scene_root
	else:
		camera_pivot = $CameraPivot
	
	# Cria ou obtém o SpringArm
	if not camera_pivot.has_node("SpringArm"):
		spring_arm = SpringArm.new()
		spring_arm.name = "SpringArm"
		spring_arm.spring_length = camera_distance
		spring_arm.collision_mask = 1
		camera_pivot.add_child(spring_arm)
		spring_arm.owner = get_tree().edited_scene_root
	else:
		spring_arm = $CameraPivot/SpringArm
	
	# Cria ou obtém a Camera
	if not spring_arm.has_node("Camera"):
		camera = Camera.new()
		camera.name = "Camera"
		spring_arm.add_child(camera)
		camera.owner = get_tree().edited_scene_root
	else:
		camera = $CameraPivot/SpringArm/Camera
	
	# Posiciona a câmera corretamente
	camera.transform.origin = Vector3.ZERO
	spring_arm.spring_length = camera_distance

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotação horizontal (player)
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		# Rotação vertical (câmera) com limites
		if camera_pivot:
			var new_rotation = camera_pivot.rotation_degrees.x - (event.relative.y * mouse_sensitivity)
			camera_pivot.rotation_degrees.x = clamp(new_rotation, min_camera_angle, max_camera_angle)
	
	if event.is_action_pressed("ui_cancel"):
		toggle_mouse_capture()

func toggle_mouse_capture():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("w"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("s"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("a"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("d"):
		input_dir += global_transform.basis.x
	
	input_dir = input_dir.normalized()
	
	var target_velocity = input_dir * speed
	var current_accel = acceleration if input_dir.length() > 0 else deceleration
	
	velocity.x = lerp(velocity.x, target_velocity.x, current_accel * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, current_accel * delta)
	
	velocity.y += gravity * delta
	
	if is_on_floor():
		snap_vector = -get_floor_normal()
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
			snap_vector = Vector3.ZERO
	else:
		snap_vector = Vector3.DOWN
	
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, deg2rad(45))
	
	if is_on_floor() and velocity.y < 0:
		velocity.y = 0
