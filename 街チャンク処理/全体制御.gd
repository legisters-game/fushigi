extends Node3D
class_name レベル制御クラス
var 都市プレイヤー座標:Vector3
var 全体都市:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func レベル移動(レベル:String, 番号:int=0)->void:
	#シーンの演出
	get_node("プレイヤー").移動操作ロック=true
	get_node("プレイヤー").move_direction=Vector3.ZERO
	get_node("Control/画面フェード").フェードアウト()
	await get_tree().create_timer(1).timeout
	都市プレイヤー座標=get_node("プレイヤー").global_position
	var レベルシーン:PackedScene=load(レベル)
	var レベルルート:レベル基礎クラス=レベルシーン.instantiate()
	for i in get_node("レベル").get_children():
		i.queue_free()
	get_node("レベル").add_child(レベルルート)
	if has_node("都市3d仮"):
		全体都市=get_node("都市3d仮")
		remove_child(全体都市)
	単純ワープ(レベルルート.テレポート先[番号])
	get_node("Control/画面フェード").フェードイン()
	await get_tree().create_timer(2).timeout
	get_node("プレイヤー").移動操作ロック=false
	
func 単純ワープ(ワープ先マーカー:Marker3D)->void:
	get_node("プレイヤー").global_position=ワープ先マーカー.global_position


func 都市戻り(プレイヤー座標マーカー:Marker3D=null)->void:
	get_node("プレイヤー").移動操作ロック=true
	get_node("プレイヤー").move_direction=Vector3.ZERO
	get_node("Control/画面フェード").フェードアウト()
	await get_tree().create_timer(1).timeout
	if プレイヤー座標マーカー:
		都市プレイヤー座標=プレイヤー座標マーカー.global_position
	for i in get_node("レベル").get_children():
		i.queue_free()
	add_child(全体都市)
	get_node("プレイヤー").global_position=都市プレイヤー座標
	await get_tree().create_timer(0.9).timeout
	get_node("Control/画面フェード").フェードイン()
	await get_tree().create_timer(2).timeout
	get_node("プレイヤー").移動操作ロック=false
	
	
