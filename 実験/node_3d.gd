@tool
extends Node3D

var dist_to_back_point: float
var dist_to_joint_point: float

func _ready() -> void:
	if has_node("BackPoint"):
		dist_to_back_point = $BackPoint.position.length()
	if has_node("JointPoint"):
		dist_to_joint_point = $JointPoint.position.length()

func _physics_process(_delta: float) -> void:
	# 1. 先頭車両(PathFollow3D)と、そこからの累積距離を動的に計算
	var data = _get_leader_and_total_offset()
	var leader = data["leader"]
	var total_offset = data["offset"]
	
	if not leader: return
	
	var path_node = leader.get_parent()
	var curve = path_node.curve
	var curve_len = curve.get_baked_length()
	
	# --- 反転対策：ここから ---
	# 自身の物理位置(global_position)が、パス上のどの進捗(offset)に相当するかを逆算する
	# これにより「今の自分の位置」をパス上の数値として確定させる
	var current_actual_offset = curve.get_closest_offset(path_node.to_local(global_position))
	
	# 後点の位置を「自分の今の進捗」から車両の長さ分、確実に引いた位置にする
	# これで後点が自分を追い越す(diffが逆転する)物理的要因を排除する
	var my_back_progress = fposmod(current_actual_offset - dist_to_back_point, curve_len)
	var ideal_back_pos = path_node.to_global(curve.sample_baked(my_back_progress, true))
	# --- 反転対策：ここまで ---
	
	# 3. 向きの計算（自身の物理原点を軸に、確定した後点を見る）
	var diff = global_position - ideal_back_pos
	
	if diff.length() > 0.001:
		var forward = -diff.normalized()
		
		# 捻れ防止のUpガイド
		var up_guide = get_parent().global_basis.y
		var right = up_guide.cross(forward).normalized()
		var actual_up = forward.cross(right).normalized()
		
		global_basis = Basis(right, actual_up, forward)

# 前の車両の連結点(JointPoint)を辿って、先頭までの距離を合計する
func _get_leader_and_total_offset() -> Dictionary:
	var current_node = get_parent() 
	var total_dist = 0.0
	
	while current_node:
		if "dist_to_joint_point" in current_node:
			if current_node is PathFollow3D:
				return {"leader": current_node, "offset": total_dist}
			total_dist += current_node.dist_to_joint_point
				
		current_node = current_node.get_parent()
	return {"leader": null, "offset": 0.0}
