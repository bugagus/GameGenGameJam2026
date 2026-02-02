extends CharacterBody3D


const SPEED = 10.0
const ACCEL = 5
const DEACCEL = 5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSIBILITY = 0.5

var cur_speed = 0

func  _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENSIBILITY

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	var direction := (transform.basis * Vector3(input_dir.x, 0, -1 * input_dir.y)).normalized()
	if direction:
		cur_speed = move_toward(cur_speed, SPEED, ACCEL * delta)
		velocity.x = direction.x * cur_speed
		velocity.z = direction.z * cur_speed
	else:
		cur_speed = 0
		velocity.x = move_toward(velocity.x, cur_speed, DEACCEL * delta)
		velocity.z = move_toward(velocity.z, cur_speed, DEACCEL * delta)

	move_and_slide()
