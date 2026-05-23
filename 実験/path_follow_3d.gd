@tool
extends PathFollow3D

@export var speed: float = 10.0
var dist_to_back_point: float   # 原点から赤丸(後点)までの距離
var dist_to_joint_point: float  # 原点から緑丸(連結点)までの距離

func _ready() -> void:
	
	# 子ノード BackPoint と JointPoint がある前提
	if has_node("BackPoint"):
		dist_to_back_point = $BackPoint.position.length()
	if has_node("JointPoint"):
		dist_to_joint_point = $JointPoint.position.length()
	
	# PathFollow3Dの回転制御はスクリプトで行うため無効化
	rotation_mode = ROTATION_NONE

func _physics_process(delta: float) -> void:
	if not has_node("BackPoint"): return
	if not get_parent()or not get_parent() is Path3D:return
	progress += (speed*1000/60/60) * delta
	# 1. 進行 (PathFollow3Dの progress を更新)
	# ※外部から progress を動かす場合はこの処理は不要
	
	# 2. 向きの更新 (原点からパス上の後点を見る)
	var curve = get_parent().curve
	var curve_len = curve.get_baked_length()
	
	var back_progress = fposmod(progress - dist_to_back_point, curve_len)
	var global_back = get_parent().to_global(curve.sample_baked(back_progress, true))
	
	var diff = global_position - global_back
	if diff.length() > 0.01:
		var forward = -diff.normalized()
		var right = Vector3.UP.cross(forward).normalized()
		var actual_up = forward.cross(right).normalized()
		global_basis = Basis(right, actual_up, forward)


func _on_ドア制御右_全部閉まった() -> void:
	print("右側扉しまった")


func _on_ドア制御右_全部開いた() -> void:
	print("右側扉開いた")




func _on_ドア制御左_全部閉まった() -> void:
	print("左側扉しまった")


func _on_ドア制御左_全部開いた() -> void:
	print("左側扉開いた")
