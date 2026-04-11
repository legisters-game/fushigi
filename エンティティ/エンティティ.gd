extends CharacterBody3D
class_name エンティティ
@export var 最大体力:int
@export var SPEED = 7.0
@export var rotation_speed: float = 10.0
var カメラ基準:Marker3D
const JUMP_VELOCITY = 3.0
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

# 移動の計算
func apply_movement(delta):
	# 重力処理（簡略化）
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# move_direction（絶対座標系）に基づいて速度を設定
	var target_vel = move_direction * SPEED
	velocity.x = target_vel.x
	velocity.z = target_vel.z

# 回転の計算（進んでいる方向を向く）
func apply_rotation(delta):
	if move_direction.length() > 0.1:
		# 進みたい方向への角度を計算
		var target_angle = atan2(move_direction.x, move_direction.z)
		# 現在の回転を目標の回転へ補完（スムーズに回転させる）
		rotation.y = learn_angle(rotation.y, target_angle, rotation_speed * delta)

# lerp_angleのヘルパー（Godot 4標準関数ですが明示的に）
func learn_angle(from, to, weight):
	return lerp_angle(from, to, weight)


func ダメージ(ダメージ数:int)->void:
	体力-=ダメージ数
	if 体力<=0:
		死亡()

func 死亡()->void:
	queue_free()
