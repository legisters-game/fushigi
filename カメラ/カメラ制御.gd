extends Node3D
@export var 目標:エンティティ
@export var 速さ:float=30
@export var 感度:float=5
var 現在位置:Vector3
var 視点回転:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	現在位置=global_position
	get_node("SpringArm3D/Camera3D").make_current()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not 目標:
		return
	現在位置=lerp(現在位置,目標.カメラ基準.global_position,delta*速さ)
	global_position=現在位置
	rotation_degrees.y-=視点回転.x*delta*感度
	rotation_degrees.x=clampf(rotation_degrees.x+視点回転.y*delta*感度*0.7,-15,38)
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
