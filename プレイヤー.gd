extends エンティティ

@onready var camera_pivot = get_viewport().get_camera_3d()


func _unhandled_input(_event):
	# 例えばジャンプ処理などはPlayer固有に書ける
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = 4.5
		#get_node("Camera3D").current=true
func _process(_delta):
	# 1. キー入力を取得 (Vector2)
	var input_v2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. カメラの向きに基づいた座標軸を取得
	# カメラの正面方向（Y軸を無視した水平面のみ）
	var cam_forward = -camera_pivot.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()
	
	# カメラの右方向
	var cam_right = camera_pivot.global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	
	# 3. 入力をワールド座標系（絶対方向）のベクトルに変換してEntityに渡す
	move_direction = (cam_forward * -input_v2.y + cam_right * input_v2.x).normalized()
