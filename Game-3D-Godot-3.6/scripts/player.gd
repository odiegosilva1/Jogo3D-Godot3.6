extends KinematicBody

func _ready() ->void:
	pass
	
func _physics_process(delta: float) -> void:
	var input = Input.get_action_strength("w")
	applay_central_force(input * Vector3.FORWARD * 1.200.0 * delta)	
	pass

