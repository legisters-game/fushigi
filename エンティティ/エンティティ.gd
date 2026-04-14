extends CharacterBody3D
class_name エンティティ
@export var 最大体力:int
@export var SPEED = 7.0
@export var rotation_speed: float = 10.0
@export var アニメツリー:AnimationTree
@export var 顔:MeshInstance3D
@export var 表情データ:表情オブジェクト
var アニメベクター:Vector2
var カメラ基準:Marker3D




var 体力:int
#var input_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	体力=最大体力
	カメラ基準=get_node("カメラ基準点")

var move_direction: Vector3 = Vector3.ZERO

func _physics_process(delta: float):
	apply_movement(delta)
	apply_rotation(delta)
	move_and_slide()
	update_animations(move_direction,delta)

# 移動の計算
func apply_movement(delta:float):
	# 重力処理（簡略化）
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# move_direction（絶対座標系）に基づいて速度を設定
	var target_vel = move_direction * SPEED
	velocity.x = target_vel.x
	velocity.z = target_vel.z

# 回転の計算（進んでいる方向を向く）
func apply_rotation(delta:float):
	if move_direction.length() > 0.1:
		# 進みたい方向への角度を計算
		var target_angle:float = atan2(move_direction.x, move_direction.z)
		# 現在の回転を目標の回転へ補完（スムーズに回転させる）
		rotation.y = learn_angle(rotation.y, target_angle, rotation_speed * delta)

# lerp_angleのヘルパー（Godot 4標準関数ですが明示的に）
func learn_angle(from:float, to:float, weight:float):
	return lerp_angle(from, to, weight)

func update_animations(velocity: Vector3,デルタ:float):
	var local_vel = global_transform.basis.inverse() * velocity*7.0*2
	
	# ここで「歩きの速度」を基準にする
	# 例：walk_speed = 3.0, run_speed = 6.0 の場合
	# スティック全倒しで blend_pos は 2.0 になる
	
	var x_ratio:float = local_vel.x / (7.0)
	var y_ratio:float = local_vel.z / (7.0)
	var blend_pos:Vector2 = Vector2(x_ratio, y_ratio)
	アニメベクター=lerp(アニメベクター,blend_pos,デルタ*11)
	アニメツリー.set("parameters/動き/blend_position", アニメベクター)

func 表情切り替え(切り替え表情:表情オブジェクト.表情)->void:
	if not 顔 or not 表情データ or  not 顔.mesh:return
	var マテリアル:StandardMaterial3D=顔.mesh.surface_get_material(0)
	if not マテリアル:
		return
	var 上書きマテリアル:StandardMaterial3D=マテリアル.duplicate()
	if 表情データ.取得(切り替え表情):
		上書きマテリアル.albedo_texture=表情データ.取得(切り替え表情)
		顔.set_surface_override_material(0,上書きマテリアル)
func ダメージ(ダメージ数:int)->void:
	体力-=ダメージ数
	if 体力<=0:
		死亡()

func 死亡()->void:
	queue_free()
