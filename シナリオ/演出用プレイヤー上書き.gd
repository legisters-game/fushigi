extends RemoteTransform3D

class_name 演出用プレイヤーオーバーライド
var プレイヤー:プレイヤークラス
var 実行済:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	プレイヤー=get_tree().get_first_node_in_group("プレイヤー")
	while プレイヤー:
		await get_tree().create_timer(0.1).timeout 
		if 実行済:プレイヤー.global_position=global_position
		
##trueでプレイヤーを表示する
func プレイヤー位置上書き有効(プレイヤー非表示:bool=false)->void:
	if プレイヤー:
		var プレイヤー位置ノード:Node3D=get_tree().get_first_node_in_group("プレイヤー").get_parent()
		remote_path=プレイヤー位置ノード.get_path()
		プレイヤー.global_position=global_position
		プレイヤー.show()
		if プレイヤー非表示:プレイヤー.hide()
		プレイヤー.アニメーション中に付き重力無効()
		force_update_cache()
		実行済=true

func _exit_tree() -> void:
	remote_path=NodePath("")
	force_update_cache()
	if get_tree().get_first_node_in_group("プレイヤー"):
		get_tree().get_first_node_in_group("プレイヤー").アニメーション中に付き重力無効(false)
