extends エンティティ
class_name プレイヤークラス
@onready var camera_pivot = get_viewport().get_camera_3d()
@export var アクセスNPCコライダー:Area3D
@export var レベル制御:レベル制御クラス
@export var メッセージボックス:メッセージボックスクラス

var 移動操作ロック:bool

func _unhandled_input(_event):
	if 移動操作ロック:return
	# 例えばジャンプ処理などはPlayer固有に書ける
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = 3
		#get_node("Camera3D").current=true
func _process(_delta):
	
	# 1. キー入力を取得 (Vector2)
	camera_pivot=get_viewport().get_camera_3d()
	# 2. カメラの向きに基づいた座標軸を取得
	# カメラの正面方向（Y軸を無視した水平面のみ）
	var cam_forward = -camera_pivot.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()
	
	# カメラの右方向
	var cam_right = camera_pivot.global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	
	if 移動操作ロック:return
	
	var input_v2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# 3. 入力をワールド座標系（絶対方向）のベクトルに変換してEntityに渡す
	move_direction = (cam_forward * -input_v2.y + cam_right * input_v2.x).normalized()
	
	#if Input.is_action_just_pressed("W"):
		#pass
	if Input.is_action_just_pressed("会話"):
		var コライダー:Array[Node3D]=アクセスNPCコライダー.get_overlapping_bodies()
		for i in コライダー:
			if i is NPCクラス:
				i.メッセージ送信(self)
				var 距離差分:Vector3=i.global_position - global_position
				回転指定(atan2( 距離差分.x, 距離差分.z))
				移動操作ロック=true
				move_direction=Vector3.ZERO
				break
			elif i is レベルゲート:
				if i.アクセスレベル!="":
					レベル制御.レベル移動(i.アクセスレベル,i.アクセス番号)
					break
			elif i is 街レベルゲート:
				レベル制御.都市戻り(i.アクセスマーカー)

	
func _on_timer_timeout() -> void:
	if (1==randi_range(0,3)):
		表情切り替え(表情オブジェクト.表情.閉)
		await get_tree().create_timer(0.1).timeout
		表情切り替え(表情オブジェクト.表情.通常)



	
