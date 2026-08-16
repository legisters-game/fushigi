@icon("res://拡張リソース/アイコン/拡張ノード/NPCノード.png")
extends エンティティ
class_name NPCクラス

@export var nav_agent:NavigationAgent3D
@export var 位置:エンティティ
@export var デフォルトセリフ:Array[セリフオブジェクト]
@export var キャラ:スケジュール管理クラス.NPC
@export var アクションポイント:Sprite3D

##目的の位置に到着していないといけない場合true
var 待機:bool
##先行で到着してもtrue
var 到着:bool
##プレイヤーインタラクト時true
var 停止:bool
##目標到着位置
var 到着位置:Vector3

signal メッセージ送信した

#会話終了時元の回転に戻すため
var 会話前回転値保持:float


func _ready() -> void:
	super()
	重力無効 = true#NPCはナビゲーションにより移動を制御するため
	# スケジュールループ（NPC管理）
	スケジュールループスタート()

func スケジュールループスタート()->void:
	while get_parent() is スケジュール管理クラス:
		var NPC管理: スケジュール管理クラス = get_parent()
		if not NPC管理.全体スケジュール.has(キャラ) :
			到着位置=global_position #到着位置を上書き
			break
		await get_tree().create_timer(0.2).timeout
		#{"目的地": Vector3, "強制到着":bool,"ディメンション":String}
		var 辞書: Dictionary = NPC管理.目的地取得(キャラ)
		
		#まだ目的地に到着していない、会話などで停止していない
		if 辞書["強制到着"] and not 待機 and not 停止:
			#歩ける状態なら目的地にワープ↓
			if not 座っている:global_position = 辞書["目的地"]
			move_direction = Vector3.ZERO
			待機 = true#目的地に到着してないといけないを通知、入力はZEROに↑
		#まだ到着する予定ではない
		elif not 辞書["強制到着"]:
			待機 = false#到着はまだしていないから
			到着 = false#到着はまだしていないから2
			# 目的地の更新（後述の移動制御へ）
			到着位置 = 辞書["目的地"]#目標到着位置を上書き
		#辞書ディメンション シーンパスが入る
		var 辞書ディメンション:String
		if 辞書["ディメンション"]!="":#目的の位置が建物内の場合↓
			#レベルシーンの保存パスが入る
			辞書ディメンション=ResourceUID.uid_to_path(辞書["ディメンション"])
		#プレイヤーがいる位置がNPC目的のディメンションと異なる場合↓オーバーワールド時は""になる為通る
		if get_tree().get_first_node_in_group("全体制御").ディメンション!=辞書ディメンション:
			#プレイヤーがいる位置と目的の位置が両方オーバーワールド↓
			if 辞書["ディメンション"]=="" and (get_tree().get_first_node_in_group("全体制御").ディメンション=="オープンワールド"):
				show()
			else:
				hide()
		#同じディメンションにいる場合↓
		else:
			show()
			#NPCがオブジェクトにアクセスする場合、ルートがレベルルートを保持しているか↓
			if 辞書["ディメンション"]!="" and 辞書["ディメンションオブジェクト番号"] and get_tree().get_first_node_in_group("全体制御").レベルルート:
				#ディメンション側にオブジェクトが登録されている場合↓
				if get_tree().get_first_node_in_group("全体制御").レベルルート.NPC用オブジェクト[辞書["ディメンションオブジェクト番号"]]:
					get_tree().get_first_node_in_group("全体制御").レベルルート.NPC用オブジェクト[辞書["ディメンションオブジェクト番号"]].実行(self)
					到着=true#到着はさせておく

##プレイヤーは引数の方向を向く
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

##到着位置を基準に移動する
func _process(delta: float) -> void:
	if 待機 or 停止: return
	
	#移動制御ロジック
	var マップRID:RID = get_world_3d().navigation_map
	var 現在位置:Vector3 = global_position
	var 最も近い地点:Vector3 = NavigationServer3D.map_get_closest_point(マップRID, 現在位置)
	var ゴールに最も近い点:Vector3 = NavigationServer3D.map_get_closest_point(マップRID, 到着位置)
	
	var ナビメッシュの外にいる:bool = Vector2(現在位置.x, 現在位置.z).distance_to(Vector2(最も近い地点.x, 最も近い地点.z)) > 0.5
	
	# ゴール自体がNavMeshの外にあるか
	var ゴールがナビメッシュの外である:bool = Vector2(到着位置.x, 到着位置.z).distance_to(Vector2(ゴールに最も近い点.x, ゴールに最も近い点.z)) > 0.5
	
	# 範囲外スタートかつゴールも範囲外の場合のみ即ワープ
	if ナビメッシュの外にいる and ゴールがナビメッシュの外である:
		if not 座っている:global_position = 到着位置
		到着 = true
		move_direction = Vector3.ZERO
		return
	
	var closest_point:Vector3 = NavigationServer3D.map_get_closest_point(マップRID, 到着位置)
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
