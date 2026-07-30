extends エンティティ
class_name NPCクラス

@export var nav_agent:NavigationAgent3D
@export var 位置:エンティティ
@export var デフォルトセリフ:Array[セリフオブジェクト]
@export var キャラ:スケジュール管理クラス.NPC
@export var アクションポイント:Sprite3D

var 待機:bool
var 到着:bool
var 停止:bool
var 到着位置:Vector3

signal メッセージ送信した

var 会話前回転値保持:float


func _ready() -> void:
	super()
	重力無効 = true
	# スケジュールループ（NPC管理）
	_start_schedule_loop()

func _start_schedule_loop():
	while get_parent() is スケジュール管理クラス:
		var NPC管理: スケジュール管理クラス = get_parent()
		if not NPC管理.全体スケジュール.has(キャラ) :
			到着位置=global_position
			break
		await get_tree().create_timer(0.2).timeout
		var 辞書: Dictionary = NPC管理.目的地取得(キャラ)
		
		if 辞書["強制到着"] and not 待機 and not 停止:
			if not 座っている:global_position = 辞書["目的地"]
			move_direction = Vector3.ZERO
			待機 = true
		elif not 辞書["強制到着"]:
			待機 = false
			到着 = false
			# 目的地の更新（後述の移動制御へ）
			到着位置 = 辞書["目的地"]
		if get_tree().get_first_node_in_group("全体制御").ディメンション!=ResourceUID.uid_to_path(辞書["ディメンション"]):
			if 辞書["ディメンション"]=="" and (get_tree().get_first_node_in_group("全体制御").ディメンション=="オープンワールド"):
				show()
			else:
				hide()
		else:
			show()
			if 辞書["ディメンション"]!="" and 辞書["ディメンションオブジェクト番号"] and get_tree().get_first_node_in_group("全体制御").レベルルート:
				if get_tree().get_first_node_in_group("全体制御").レベルルート.NPC用オブジェクト[辞書["ディメンションオブジェクト番号"]]:
					get_tree().get_first_node_in_group("全体制御").レベルルート.NPC用オブジェクト[辞書["ディメンションオブジェクト番号"]].実行(self)
					到着=true

func メッセージ送信(向くターゲット:Node3D=null)->void:
	メッセージ送信した.emit()
	if get_parent() is スケジュール管理クラス:
		#メッセージボックスで停止をfalseにする
		停止=true
		move_direction = Vector3.ZERO
		var NPC管理: スケジュール管理クラス = get_parent()
		var メッセージリスト:Array[セリフオブジェクト]= NPC管理.メッセージ取得(キャラ)
		NPC管理.メッセージボックス.相手NPC=self
		if 到着 and メッセージリスト:
			NPC管理.メッセージボックス.表示(NPC管理.NPC.find_key(キャラ),メッセージリスト)
		else:
			NPC管理.メッセージボックス.表示(NPC管理.NPC.find_key(キャラ),デフォルトセリフ)
		if 向くターゲット and not 座っている:
			var 距離差分:Vector3=向くターゲット.global_position - global_position
			回転指定(atan2( 距離差分.x, 距離差分.z))
		会話前回転値保持=global_rotation.y
		if モデル.顔ボーン:
			モデル.顔ボーン.target_node=向くターゲット.get_path()



func 会話前回転戻し()->void:

	回転指定(会話前回転値保持)
	会話前回転値保持=0

#到着位置を基準に移動する
func _process(delta: float) -> void:
	if 待機 or 停止: return
	
	# --- 【重要】移動制御ロジック ---
	var map_rid:RID = get_world_3d().navigation_map
	var current_pos:Vector3 = global_position
	var closest_point_to_me:Vector3 = NavigationServer3D.map_get_closest_point(map_rid, current_pos)
	var closest_point_to_goal:Vector3 = NavigationServer3D.map_get_closest_point(map_rid, 到着位置)
	
	var is_out_of_navmesh:bool = Vector2(current_pos.x, current_pos.z).distance_to(Vector2(closest_point_to_me.x, closest_point_to_me.z)) > 0.5
	
	# ゴール自体がNavMeshの外にあるか
	var is_goal_out_of_navmesh:bool = Vector2(到着位置.x, 到着位置.z).distance_to(Vector2(closest_point_to_goal.x, closest_point_to_goal.z)) > 0.5
	
	# 範囲外スタートかつゴールも範囲外の場合のみ即ワープ
	if is_out_of_navmesh and is_goal_out_of_navmesh:
		if not 座っている:global_position = 到着位置
		到着 = true
		move_direction = Vector3.ZERO
		return
	
	var closest_point:Vector3 = NavigationServer3D.map_get_closest_point(map_rid, 到着位置)
	# 高さを無視した2D平面での距離判定
	var dist_2d_to_goal:float = Vector2(global_position.x, global_position.z).distance_to(Vector2(到着位置.x, 到着位置.z))
	var dist_2d_to_edge:float = Vector2(global_position.x, global_position.z).distance_to(Vector2(closest_point.x, closest_point.z))
	
	# 1. 目的地に十分近い（到達済み）
	if dist_2d_to_goal < 0.1:
		move_direction = Vector3.ZERO
		到着 = true
		return
		
	# 2. NavMeshの端まで到達している（これ以上歩けない）ならワープ
	# かつ、プレイヤーの可視範囲外ならワープ許可（可視範囲内ならその場に留まるなど工夫可）
	if dist_2d_to_edge < 0.5:
		if not 座っている:global_position = 到着位置
		到着 = true
		move_direction = Vector3.ZERO
		return

	# 3. ナビゲーション移動（端を目指す or 目的地を目指す）
	# 歩けるならclosest_pointへ、ゴールが見えているならそのまま目的地へ
	nav_agent.target_position = closest_point if dist_2d_to_edge > 0.5 else 到着位置
	
	var next_path_position:Vector3 = nav_agent.get_next_path_position()
	move_direction = global_position.direction_to(next_path_position)
	move_direction.y = 0
	
	# 回転処理（既存）
	if move_direction.length() > 0.1:
		var target_dir:float = Vector2(move_direction.x, move_direction.z).angle()
		var target_rotation:float = -target_dir + PI/2
		rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta)
