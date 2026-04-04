extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 3
const 感度:float=5
var 視点回転:Vector2

func _ready() -> void:
	pass
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	rotation_degrees.y-=視点回転.x*delta*感度
	視点回転=Vector2.ZERO
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var マウス:InputEventMouseMotion=event
		視点回転=マウス.screen_relative
	
