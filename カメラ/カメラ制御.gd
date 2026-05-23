extends Node3D
class_name 追尾カメラクラス
@export var 目標:エンティティ
@export var 速さ:float=30
@export var 感度:float=5
var 現在位置:Vector3
var 視点回転:Vector2
var 角最大変数:float=38
const 角最大:float=38
const 角最大ロック:float=15
var 角最小変数:float=-15
const 角最小:float=-15


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	現在位置=global_position
	get_node("SpringArm3D/Camera3D").make_current()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not 目標:
		return
		
	var local_current = get_parent().to_local(global_position)
	var local_target = get_parent().to_local(目標.カメラ基準.global_position)
	
	# ローカル空間の中でだけ、なめらかに追従させる
	var local_next = lerp(local_current, local_target, delta * 速さ)
	
	# 最終的な位置をグローバルに変換して適用
	global_position = get_parent().to_global(local_next)
	
	
	#現在位置=lerp(現在位置,目標.カメラ基準.global_position,delta*速さ)
	#global_position=現在位置
	rotation_degrees.y-=視点回転.x*delta*感度
	rotation_degrees.x=clampf(rotation_degrees.x-視点回転.y*delta*感度*0.7,角最小変数,角最大変数)
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
		
func 会話中視点角ロック(有効:bool,対象:エンティティ=null)->void:
	if 有効:
		角最大変数=角最大ロック
		if 対象:
			look_at(対象.get_node("カメラ基準点").global_position)
			match randi_range(0,1):
				0:
					rotation_degrees.y-=70
				1:
					rotation_degrees.y+=70
			rotation_degrees.x=角最大ロック
	else:
		角最大変数=角最大
