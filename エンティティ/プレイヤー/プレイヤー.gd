@icon("res://拡張リソース/アイコン/拡張ノード/レクレイス.png")
extends エンティティ
class_name プレイヤークラス
@onready var camera_pivot = get_viewport().get_camera_3d()
@export var アクセスNPCコライダー:Area3D
@export var レベル制御:レベル制御クラス
@export var メッセージボックス:メッセージボックスクラス
@export var 追尾物:Node3D
@export_file("*.tscn") var 変身後シーン:String
@export_file("*.tscn") var 変身演出シーン:String

var 戦闘モード:bool
var 移動操作ロック:bool=true
var 操作ロック前位置:Vector3
var 街非表示防止:bool


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
	#街非表示防止=false
	#get_parent().force_update_cache()
	操作ロック前位置=global_position
	set_physics_process(true)
	while true:
		await get_tree().create_timer(2).timeout
		if not 移動操作ロック:
			操作ロック前位置=global_position
		if not レベル制御.演出中():
			プレイヤーセーブ()
	
	return
	##デバッグ用プレイヤー街全体移動処理
#	while global_position.x<=1258.081:
#		var アニメ:Tween=get_tree().create_tween()
#		アニメ.bind_node(self)
#		アニメ.tween_property(self,"global_position",Vector3(global_position.x,global_position.y,761.289),10)
#		await アニメ.finished
#		global_position.z=-692.289
#		global_position.x+=25
		
#	while true:
#		await get_tree().create_timer(0.1).timeout
#		if not 移動操作ロック:
#			操作ロック前位置=global_position
		


func _unhandled_input(_event)->void:
	if 移動操作ロック:return
	# 例えばジャンプ処理などはPlayer固有に書ける
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = 3
		#get_node("Camera3D").current=true

func _process(_delta)->void:
	#global_position=追尾物.global_position
	# 1. キー入力を取得 (Vector2)
	camera_pivot = get_viewport().get_camera_3d()

# 1. カメラの向きに基づいた座標軸（グローバル）を取得
	var cam_forward:Vector3 = -camera_pivot.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	var cam_right:Vector3 = camera_pivot.global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	var キー入力済:bool
	if Input.is_action_just_pressed("回転リセット") and not 寝ている:
		var cam_z:Vector3 = camera_pivot.global_transform.basis.z
		# 2. atan2にカメラのXZ平面の方向を渡して、Y軸まわりの角度（float）を計算
		# ※前方向（-Z方向）を基準にするため、引数の符号を反転（-cam_z.x, -cam_z.z）させます
		var target_angle_float: float = atan2(-cam_z.x, -cam_z.z)
		回転指定(target_angle_float)
		キー入力済=true
	if 移動操作ロック: 
		move_direction =Vector3.ZERO
		return

	var input_v2:Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
# 2. 画面の見た目通りの「グローバルな移動方向」を計算（※ここまではあなたの最初のコードと同じです）
	var global_move_direction:Vector3 = (cam_forward * -input_v2.y + cam_right * input_v2.x).normalized()

# 3. ✨【修正のコア】計算した方向を「そのまま」Entity（プレイヤー）に渡す
	move_direction = global_move_direction
	if 座っている:move_direction =Vector3.ZERO
		
	if キー入力済:return
	if Input.is_action_just_pressed("会話"):
		var コライダー:Array[Node3D]=アクセスNPCコライダー.get_overlapping_bodies()
		for 衝突物体:Node3D in コライダー:
			if 衝突物体 is NPCクラス:
				衝突物体.メッセージ送信(self.顔ノード)
				var 距離差分:Vector3=衝突物体.global_position - global_position
				回転指定(atan2( 距離差分.x, 距離差分.z))
				移動操作ロック=true
				move_direction=Vector3.ZERO
				break
			elif 衝突物体 is レベルゲート:
				if 衝突物体.アクセスレベル!="":
					衝突物体.実行()
					break
			elif 衝突物体 is 街レベルゲート:
				レベル制御.都市戻り(衝突物体.アクセスマーカー)
				break
			elif 衝突物体 is ミッション進行するやつ:
				衝突物体.プラスいち()
				break
			elif 衝突物体 is 椅子アタッチクラス:
				衝突物体.実行(self)
				break
			else:
				if 衝突物体.has_method("実行"):
					衝突物体.実行()
					break
	elif Input.is_action_just_pressed("回転リセット") and not 寝ている:
		var cam_z:Vector3 = camera_pivot.global_transform.basis.z
		# 2. atan2にカメラのXZ平面の方向を渡して、Y軸まわりの角度（float）を計算
		# ※前方向（-Z方向）を基準にするため、引数の符号を反転（-cam_z.x, -cam_z.z）させます
		var target_angle_float: float = atan2(-cam_z.x, -cam_z.z)
		回転指定(target_angle_float)
	elif Input.is_action_just_pressed("チャンク"):
		var コライダー:Object=get_node("RayCast3D").get_collider()
		if コライダー.name=="地形当たり判定":
			print(コライダー.get_parent().get_parent().get_parent().get_parent().name)
			breakpoint
	elif Input.is_action_just_pressed("変身"):
		変身()
func _on_timer_timeout() -> void:
	if (1==randi_range(0,3)):
		表情切り替え(表情オブジェクト.表情.閉)
		await get_tree().create_timer(0.1).timeout
		表情切り替え(表情オブジェクト.表情.通常)

	#戦闘切り替え(!戦闘モード)
	
func プレイヤーチェンジ(引き継ぎ元:プレイヤークラス)->void:
	var 位置:Vector3= 引き継ぎ元.global_position
	var 回転:Vector3= 引き継ぎ元.global_rotation_degrees
	var 追従関係:Marker3D=引き継ぎ元.ターゲットマーカー
	var toメッセージボックス:メッセージボックスクラス=引き継ぎ元.メッセージボックス
	var toレベル制御:レベル制御クラス=引き継ぎ元.レベル制御
	var to体力:int=引き継ぎ元.体力
	var to防御力:float=引き継ぎ元.防御力
	
	var 親:Node3D=引き継ぎ元.get_parent()
	 
	var シナリオ:演出基盤クラス= await toレベル制御.シナリオ演出実行(引き継ぎ元.変身演出シーン)
	await シナリオ.演出完了通知
	
	
	引き継ぎ元.街非表示防止=true
	親.remove_child(引き継ぎ元)
	引き継ぎ元.queue_free()
	
	ターゲットマーカー=追従関係
	メッセージボックス=toメッセージボックス
	レベル制御=toレベル制御
	体力=to体力
	防御力=to防御力
	
	移動操作ロック=false
	
	
	親.add_child(self)
	global_position=位置
	global_rotation_degrees=回転
	
	レベル制御.カメラ返し().目標=self
	

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

func 戦闘切り替え(オン:bool)->void:
	戦闘モード=オン
	var ステートマシーン:AnimationNodeStateMachinePlayback=アニメツリー.get("parameters/playback")
	if 戦闘モード:
		ステートマシーン.travel("戦闘動き")
		視点固定ターゲット指定(追尾物)
		if モデル.顔ボーン:
			モデル.顔ボーン.target_node=追尾物.get_path()

	else:
		ステートマシーン.travel("動き")
		視点固定ターゲット指定()
		if モデル.顔ボーン:
			モデル.顔ボーン.target_node=NodePath()


func 変身()->void:
	if ResourceLoader.load_threaded_request(変身後シーン)!=OK:
		return
	while is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		var 進捗:Array = []
		var 状態 = ResourceLoader.load_threaded_get_status(変身後シーン,進捗)
		match 状態:
			ResourceLoader.THREAD_LOAD_LOADED:
				break
			ResourceLoader.THREAD_LOAD_FAILED:
				return
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				return
	var 変身後:プレイヤークラス=ResourceLoader.load_threaded_get(変身後シーン).instantiate()
	変身後.プレイヤーチェンジ(self)
	街非表示防止=true
	

func 座る(座標:Vector3=Vector3.ZERO)->void:
	super(座標)
	if 座標==Vector3.ZERO:
		移動操作ロック=false
	else:
		移動操作ロック=true

func 寝る(座標:Vector3=Vector3.ZERO)->void:
	super(座標)
	if 座標==Vector3.ZERO:
		移動操作ロック=false
		レベル制御.GUI.フェードGUI.フェードイン()
		
	else:
		移動操作ロック=true
		await  get_tree().create_timer(0.2).timeout
		レベル制御.GUI.フェードGUI.フェードアウト()
		await  get_tree().create_timer(2).timeout
		レベル制御.時間の太陽.現時間=レベル制御.時間の太陽.時間辞書[時間太陽.時間.朝]
		レベル制御.時間の太陽.朝()
		レベル制御.GUI.フェードGUI.フェードイン()


func update_animations(velocitys: Vector3,デルタ:float)->void:
	var local_vel:Vector3 = global_transform.basis.inverse() * velocitys*SPEED*2
	
	# ここで「歩きの速度」を基準にする
	# 例：walk_speed = 3.0, run_speed = 6.0 の場合
	# スティック全倒しで blend_pos は 2.0 になる

	var x_ratio:float = local_vel.x / (SPEED)
	var y_ratio:float = local_vel.z / (SPEED)
	var blend_pos:Vector2 = Vector2(x_ratio, y_ratio)
	アニメベクター=lerp(アニメベクター,blend_pos,デルタ*11)
	if 戦闘モード:
		アニメツリー.set("parameters/戦闘動き/blend_position", アニメベクター)
	else:
		アニメツリー.set("parameters/動き/blend_position", アニメベクター)
