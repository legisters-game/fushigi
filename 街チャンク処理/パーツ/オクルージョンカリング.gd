@tool
extends OccluderInstance3D


@export_tool_button("設定準備","TransitionEndAuto") var 設定ボタン=設定準備
@export_tool_button("設定完了","TransitionEndAutoBig") var 設定ボタン2=設定完了
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func 設定準備()->void:
	var ルート:MeshInstance3D
	if get_parent() is MeshInstance3D:
		ルート=get_parent()
	elif get_parent().get_parent() and get_parent().get_parent()is MeshInstance3D:
		ルート=get_parent().get_parent()
	elif get_parent().get_parent().get_parent() and get_parent().get_parent().get_parent()is MeshInstance3D:
		ルート=get_parent().get_parent().get_parent()
	elif get_parent().get_parent().get_parent().get_parent() and get_parent().get_parent().get_parent().get_parent()is MeshInstance3D:
		ルート=get_parent().get_parent().get_parent().get_parent()
	else:
		printerr("MeshInstance3Dを特定できませんでした。第4親までに街のメッシュを割り当ててください。")
		return
		
	設定準備2(ルート)
		
func 設定準備2(ルートノード:MeshInstance3D)->void:
	ルートノード.position=Vector3.ZERO
	ルートノード.scale=Vector3(16,16,16)
	if has_node("一時ノード"):
		push_warning("既に実行済み。オクルーダーをベイク後,設定完了ボタンを押してください。")
		return
	var 一時ノード:MeshInstance3D=MeshInstance3D.new()
	一時ノード.name="一時ノード"
	ルートノード.add_child(一時ノード)
	一時ノード.owner=ルートノード
	一時ノード.position=Vector3.ZERO
	var 位置:Vector3=一時ノード.global_position
	if not ルートノード.mesh:
		printerr("あ、馬鹿！メッシュを空にするな！！戻せ")
		return
	一時ノード.mesh=ルートノード.mesh
	ルートノード.remove_child(一時ノード)
	add_child(一時ノード)
	一時ノード.owner=self
	一時ノード.global_position=位置
	print_rich("[color=green]セットアップ完了！\nオクルーダーをベイクで「res://街チャンク処理/街オクルージョン/」に「(チャンク名).occ」を保存してください。[/color]")
	name=ルートノード.name+"_oc"

func 設定完了()->void:
	if has_node("一時ノード"):
		get_node("一時ノード").queue_free()
		print_rich("[color=green]正常に処理できました！シーンを忘れずに上書き保存してください！[/color]")
	var ルート:MeshInstance3D
	if get_parent() is MeshInstance3D:
		ルート=get_parent()
	elif get_parent().get_parent() and get_parent().get_parent()is MeshInstance3D:
		ルート=get_parent().get_parent()
	elif get_parent().get_parent().get_parent() and get_parent().get_parent().get_parent()is MeshInstance3D:
		ルート=get_parent().get_parent().get_parent()
	elif get_parent().get_parent().get_parent().get_parent() and get_parent().get_parent().get_parent().get_parent()is MeshInstance3D:
		ルート=get_parent().get_parent().get_parent().get_parent()
	else:
		printerr("MeshInstance3Dを特定できませんでした。第4親までに街のメッシュを割り当ててください。")
		return
	var エリア3D:Node=ルート.has_type_recursive(ルート,チャンク当たり判定制御)
	if エリア3D and エリア3D is チャンク当たり判定制御:
		エリア3D.オクルージョンノード=self
	else:push_warning("シーンに当たり判定制御が存在しません\n「res://街チャンク処理/パーツ/当たり判定制御.tscn」を追加して「オクルージョンノード」に自身を割り当ててください")
	
		
