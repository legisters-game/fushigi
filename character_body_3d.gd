extends CharacterBody3D

@export var 飛行:bool
@export var キー:InputEventKey
const SPEED = 7
const JUMP_VELOCITY = 3
const 感度:float=5
var 視点回転:Vector2

func _ready() -> void:
	if Engine.is_editor_hint():return
	pass
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():return
	# Add the gravity.
	if not is_on_floor()and not 飛行:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var 速度:float=13
	if Input.is_action_pressed("アップ"):
		direction.y=速度*delta
	elif Input.is_action_pressed("ダウン"):
		direction.y=-速度*delta
	else:
		direction.y=0
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if 飛行:
			velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		#velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
	rotation_degrees.y-=視点回転.x*delta*感度
	視点回転=Vector2.ZERO
	
	
	
func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():return
	if event is InputEventMouseMotion:
		var マウス:InputEventMouseMotion=event
		視点回転=マウス.screen_relative
	elif event is InputEventKey:
		var イベント:InputEventKey=event
		if イベント.keycode==4194305 and イベント.pressed:
			マウスチェンジ()
	
func マウスチェンジ()->void:
	if Input.mouse_mode==Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
