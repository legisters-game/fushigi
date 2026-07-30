extends CharacterBody3D
class_name エンティティ
@export var 最大体力:int
@export var SPEED = 7.0
@export var rotation_speed: float = 10.0
@export var アニメツリー:AnimationTree
#@export var 顔:MeshInstance3D
#@export var 表情データ:表情オブジェクト
@export var モデル:Node3D
@export var 攻撃判定:Area3D
@export var 通常当たり判定:Array[CollisionShape3D]
@export var 座り用当たり判定:Array[CollisionShape3D]
@export var 顔ノード:Node3D

var アニメベクター:Vector2
var カメラ基準:Marker3D
var 指定回転:bool
var 目標回転:float

var 重力無効:bool

var 体力:int
var 防御力:float

var 座っている:bool

var 簡易目的地: Vector3 = Vector3.ZERO
var 簡易移動中: bool = false
var 簡易到着許容距離: float = 0.5
var 簡易中強制歩き:bool

#var input_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	
	体力=最大体力
	カメラ基準=get_node("カメラ基準点")
	#簡易目的地へ移動(Vector3(100,20,200))

var move_direction: Vector3 = Vector3.ZERO

func _physics_process(delta: float):
	apply_movement(delta)
	apply_rotation(delta)
	move_and_slide()
	update_animations(move_direction,delta)

# 移動の計算
func apply_movement(delta:float):
	# 重力処理（簡略化）
	if not is_on_floor() :
		velocity.y -= 10 * delta
		
	if 簡易移動中:
		# 水平方向の距離を計算（高さYを無視する場合）
		var current_pos = global_transform.origin
		var target_pos = 簡易目的地
		target_pos.y = current_pos.y # 高さは無視して平面で距離判定
		
		if current_pos.distance_to(target_pos) > 簡易到着許容距離:
			# 目的地への方向ベクトルを計算
			move_direction = (target_pos - current_pos).normalized()
		else:
			# 到着した場合
			簡易移動停止()
	
	# move_direction（絶対座標系）に基づいて速度を設定
	if 簡易中強制歩き:move_direction = move_direction/2.0
	var target_vel = move_direction * SPEED#*delta*30#*70
	velocity.x = target_vel.x
	velocity.z = target_vel.z
	if 重力無効:
		velocity.y = target_vel.y

# 回転の計算（進んでいる方向を向く）
func apply_rotation(delta:float):
	if move_direction.length() > 0.1:
		# 進みたい方向への角度を計算
		var target_angle:float = atan2(move_direction.x, move_direction.z)
		# 現在の回転を目標の回転へ補完（スムーズに回転させる）
		global_rotation.y = learn_angle(global_rotation.y, target_angle, rotation_speed * delta)
		指定回転=false
	elif 指定回転:
		global_rotation.y = learn_angle(global_rotation.y, 目標回転, rotation_speed * delta*0.5)

		if abs(angle_difference(global_rotation.y,目標回転))<=0.01:
			print(angle_difference(global_rotation.y,目標回転))
			global_rotation.y=目標回転
			指定回転=false
			
func 回転指定(目標:float)->void:
	指定回転=true
	目標回転=目標


# lerp_angleのヘルパー（Godot 4標準関数ですが明示的に）
func learn_angle(from:float, to:float, weight:float):
	return lerp_angle(from, to, weight)

func update_animations(velocitys: Vector3,デルタ:float)->void:
	var local_vel = global_transform.basis.inverse() * velocitys*SPEED*2
	
	# ここで「歩きの速度」を基準にする
	# 例：walk_speed = 3.0, run_speed = 6.0 の場合
	# スティック全倒しで blend_pos は 2.0 になる

	var x_ratio:float = local_vel.x / (SPEED)
	var y_ratio:float = local_vel.z / (SPEED)
	var blend_pos:Vector2 = Vector2(x_ratio, y_ratio)
	アニメベクター=lerp(アニメベクター,blend_pos,デルタ*11)
	アニメツリー.set("parameters/動き/blend_position", アニメベクター)

func 表情切り替え(切り替え表情:表情オブジェクト.表情)->void:
	if モデル:
		モデル.表情切り替え(切り替え表情)
#	if not 顔 or not 表情データ or  not 顔.mesh:return
#	var マテリアル:StandardMaterial3D=顔.mesh.surface_get_material(0)
#	if not マテリアル:
#		return
##	if 表情データ.取得(切り替え表情):
#		上書きマテリアル.albedo_texture=表情データ.取得(切り替え表情)
#		顔.set_surface_override_material(0,上書きマテリアル)



func 攻撃する()->void:
	if 攻撃判定:
		攻撃判定.monitoring=true
		for i in 攻撃判定.get_overlapping_bodies():
			if i is エンティティ:
				var 対象:エンティティ=i

func 攻撃ヒット(被対象:エンティティ,ダメージ数:int)->void:
	if 被対象:
		被対象.ダメージ(ダメージ数)

func ダメージ(ダメージ数:int)->void:
	体力-=int(ダメージ数-(防御力*ダメージ数)/100)
	if 体力<=0:
		死亡()

func 死亡()->void:
	queue_free()

func プレイヤーセーブ()->void:
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.体力,体力)
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.最大体力,最大体力)
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.攻撃力,0)
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.防御力,0)
	#データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.ディメンション,0)
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.座標,global_position)
	データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.回転座標,global_rotation_degrees)
	
func プレイヤーロード()->void:
	体力=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.体力)
	最大体力=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.最大体力)
	#体力=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.体力)
	#体力=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.体力)
	#データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.ディメンション,0)
	global_position=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.座標,Vector3.ZERO)
	global_rotation_degrees=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.回転座標,Vector3.ZERO)

func 簡易目的地へ移動(目標地点: Vector3,歩き:bool=false) -> void:
	簡易中強制歩き=歩き
	簡易目的地 = 目標地点
	簡易移動中 = true

func 簡易移動停止() -> void:
	簡易移動中 = false
	簡易中強制歩き=false
	move_direction = Vector3.ZERO
	
func アニメーション中に付き重力無効(する:bool=true)->void:
	重力無効=する

func 座る(座標:Vector3=Vector3.ZERO)->void:
	var ステートマシーン:AnimationNodeStateMachinePlayback=アニメツリー.get("parameters/playback")
	if 座標==Vector3.ZERO:
		for i:CollisionShape3D in 通常当たり判定:
			if i: i.disabled=false
		for i:CollisionShape3D in 座り用当たり判定:
			if i: i.disabled=true
		ステートマシーン.travel("動き")
		set_collision_mask_value(1, true)
		重力無効=false
		座っている=false
		#移動操作ロック=false
	else:
		set_collision_mask_value(1, false)
		重力無効=true
		var マイマーカーの座標: Vector3 = $ケツ.global_position
		
		# 2. 「ターゲットの座標」と「自分のマーカー座標」の間のズレ（ベクトル）を計算
		var ズレ: Vector3 = 座標 - マイマーカーの座標
		
		# 3. 親（自分自身）のグローバル座標に、そのズレを足して位置を補正する
		global_position += ズレ
		for i:CollisionShape3D in 通常当たり判定:
			if i: i.disabled=true
		for i:CollisionShape3D in 座り用当たり判定:
			if i: i.disabled=false
		ステートマシーン.travel("座る")
		座っている=true
		await get_tree().create_timer(0.03).timeout
		マイマーカーの座標= $ケツ.global_position
		
		# 2. 「ターゲットの座標」と「自分のマーカー座標」の間のズレ（ベクトル）を計算
		ズレ= 座標 - マイマーカーの座標
		
		# 3. 親（自分自身）のグローバル座標に、そのズレを足して位置を補正する
		global_position += ズレ
