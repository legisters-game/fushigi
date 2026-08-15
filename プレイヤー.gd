@icon("res://拡張リソース/アイコン/拡張ノード/レクレイス.png")
extends エンティティ
class_name プレイヤークラス
@onready var camera_pivot = get_viewport().get_camera_3d()
@export var アクセスNPCコライダー:Area3D
@export var レベル制御:レベル制御クラス
@export var メッセージボックス:メッセージボックスクラス

var 移動操作ロック:bool=true
var 操作ロック前位置:Vector3
@export var 追尾物:Node3D
#レベル制御で制御
var レベル移動中:bool
func _ready() -> void:
	super()
	#データロガー.フラグ追加("電車乗車")
	#return
	#移動操作ロック=true
	global_position.z=-692.289
	global_position.x=-374.894
	#await get_tree().create_timer(2).timeout
	#print(get_parent().get_parent().読み込み中チャンク)
	#プレイヤーロード()
	if レベル制御:
		await レベル制御.読み込み完了シグナル
	#プレイヤーロード()
	await get_tree().create_timer(2).timeout
	if 追尾物:
		global_position=追尾物.global_position
	#get_parent().force_update_cache()
	操作ロック前位置=global_position
	while true:
		await get_tree().create_timer(2).timeout
		if not 移動操作ロック:
			操作ロック前位置=global_position
		プレイヤーセーブ()
	
	return
	while global_position.x<=1258.081:
		var アニメ:Tween=get_tree().create_tween()
		アニメ.bind_node(self)
		アニメ.tween_property(self,"global_position",Vector3(global_position.x,global_position.y,761.289),10)
		await アニメ.finished
		global_position.z=-692.289
		global_position.x+=25
		
	while true:
		await get_tree().create_timer(0.1).timeout
		if not 移動操作ロック:
			操作ロック前位置=global_position
		


func _unhandled_input(_event):
	if 移動操作ロック:return
	# 例えばジャンプ処理などはPlayer固有に書ける
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = 3
		#get_node("Camera3D").current=true

func _process(_delta):
	#global_position=追尾物.global_position
	# 1. キー入力を取得 (Vector2)
	camera_pivot = get_viewport().get_camera_3d()

# 1. カメラの向きに基づいた座標軸（グローバル）を取得
	var cam_forward = -camera_pivot.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	var cam_right = camera_pivot.global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	var キー入力済:bool
	if Input.is_action_just_pressed("回転リセット"):
		var cam_z = camera_pivot.global_transform.basis.z
		# 2. atan2にカメラのXZ平面の方向を渡して、Y軸まわりの角度（float）を計算
		# ※前方向（-Z方向）を基準にするため、引数の符号を反転（-cam_z.x, -cam_z.z）させます
		var target_angle_float: float = atan2(-cam_z.x, -cam_z.z)
		回転指定(target_angle_float)
		キー入力済=true
	if 移動操作ロック: 
		move_direction =Vector3.ZERO
		return

	var input_v2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
# 2. 画面の見た目通りの「グローバルな移動方向」を計算（※ここまではあなたの最初のコードと同じです）
	var global_move_direction = (cam_forward * -input_v2.y + cam_right * input_v2.x).normalized()

# 3. ✨【修正のコア】計算した方向を「そのまま」Entity（プレイヤー）に渡す
	move_direction = global_move_direction
	if 座っている:move_direction =Vector3.ZERO
		
	if キー入力済:return
	if Input.is_action_just_pressed("会話"):
		var コライダー:Array[Node3D]=アクセスNPCコライダー.get_overlapping_bodies()
		for i in コライダー:
			if i is NPCクラス:
				i.メッセージ送信(self.顔ノード)
				var 距離差分:Vector3=i.global_position - global_position
				回転指定(atan2( 距離差分.x, 距離差分.z))
				移動操作ロック=true
				move_direction=Vector3.ZERO
				break
			elif i is レベルゲート:
				if i.アクセスレベル!="":
					レベル制御.レベル移動(i.アクセスレベル,i.アクセス番号,i.階層)
					break
			elif i is 街レベルゲート:
				レベル制御.都市戻り(i.アクセスマーカー)
				break
			elif i is ミッション進行するやつ:
				i.プラスいち()
				break
			elif i is 椅子アタッチクラス:
				i.実行(self)
			else:
				if i.has_method("実行"):
					i.実行()
					break
	elif Input.is_action_just_pressed("回転リセット"):
		var cam_z = camera_pivot.global_transform.basis.z
		# 2. atan2にカメラのXZ平面の方向を渡して、Y軸まわりの角度（float）を計算
		# ※前方向（-Z方向）を基準にするため、引数の符号を反転（-cam_z.x, -cam_z.z）させます
		var target_angle_float: float = atan2(-cam_z.x, -cam_z.z)
		回転指定(target_angle_float)
	elif Input.is_action_just_pressed("チャンク"):
		var コライダー:Object=get_node("RayCast3D").get_collider()
		if コライダー.name=="地形当たり判定":
			print(コライダー.get_parent().get_parent().get_parent().get_parent().name)
			breakpoint
	
func _on_timer_timeout() -> void:
	if (1==randi_range(0,3)):
		表情切り替え(表情オブジェクト.表情.閉)
		await get_tree().create_timer(0.1).timeout
		表情切り替え(表情オブジェクト.表情.通常)

func アニメーション中に付き重力無効(する:bool=true)->void:
	super(する)
	移動操作ロック=する
func プレイヤーセーブ()->void:
	
	super()
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.ディメンション,レベル制御.ディメンション返し())
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.ディメンション階層,レベル制御.ディメンション階層返し())
func 操作停止(する:bool=true)->void:
	if する:
		移動操作ロック=true
		レベル移動中=true
	else:
		移動操作ロック=false
		レベル移動中=false
	move_direction=Vector3.ZERO
func 座る(座標:Vector3=Vector3.ZERO)->void:
	super(座標)
	if 座標==Vector3.ZERO:
		移動操作ロック=false
	else:
		移動操作ロック=true
