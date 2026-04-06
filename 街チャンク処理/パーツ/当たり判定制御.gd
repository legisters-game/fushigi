@tool
extends Area3D
class_name チャンク当たり判定制御
@export_tool_button("処理範囲を設定する","3D") var 設定ボタン=範囲コリジョン生成
@export_tool_button("街の当たり判定を設定する","ConcavePolygonShape3D") var 設定ボタン2=地形当たり判定生成
# Called when the node enters the scene tree for the first time.
@export var オクルージョンノード:OccluderInstance3D
func _ready() -> void:
	プロセス制御(false)




func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		プロセス制御(true)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		プロセス制御(false)
		
func プロセス制御(ブール:bool)->void:
	for i:Node3D in get_children():
		if ブール:
			i.process_mode=Node.PROCESS_MODE_INHERIT
			if オクルージョンノード:オクルージョンノード.process_mode=Node.PROCESS_MODE_INHERIT
		else:
			i.process_mode=Node.PROCESS_MODE_DISABLED
			if オクルージョンノード:オクルージョンノード.process_mode=Node.PROCESS_MODE_DISABLED
			

func ルート特定()->Variant:
	var ルート:Node=self
	for i:int in range(3):
		ルート=ルート.get_parent()
		if ルート is MeshInstance3D:
			return ルート
	return


func 範囲コリジョン生成():
	var ルートノード:MeshInstance3D=ルート特定()
	if not ルートノード:
		printerr("MeshInstance3Dを特定できませんでした。第三親までに街のメッシュを割り当ててください。")
		return
	if has_node("処理範囲内"):
		push_warning("既に実行済み。")
		return
	# 1. メッシュからAABBを取得
	var aabb: AABB = ルートノード.mesh.get_aabb()
	
	# 2. BoxShape3Dを作成し、サイズをメッシュに合わせる
	var box_shape:BoxShape3D = BoxShape3D.new()
	box_shape.size = aabb.size
	
	# 3. CollisionShape3Dを作成してShapeを割り当て
	var collision_node:CollisionShape3D = CollisionShape3D.new()
	collision_node.shape = box_shape
	# 4. 重要：AABBの中心座標に合わせて位置をオフセットする
	# これにより、メッシュの原点が足元にあっても判定が正しく重なる
	
	# 5. 親となるStaticBody3Dを作成してシーンに追加
	var static_body:StaticBody3D = StaticBody3D.new()
	ルートノード.add_child(static_body)
	static_body.position = aabb.get_center()
	static_body.owner=ルートノード
	static_body.add_child(collision_node)
	collision_node.owner=ルートノード
	var 位置:Vector3=collision_node.global_position
	static_body.remove_child(collision_node)
	add_child(collision_node)
	collision_node.owner=ルートノード
	collision_node.global_position=位置
	collision_node.name="処理範囲内"
	static_body.queue_free()
	
	print_rich("[color=green]当たり判定制御の範囲設定が完了しました！[/color]")

func 地形当たり判定生成()->void:
	var ルートノード:MeshInstance3D=ルート特定()
	var コリジョン親:StaticBody3D
	if not ルートノード:
		printerr("MeshInstance3Dを特定できませんでした。第三親までに街のメッシュを割り当ててください。")
		return
	if has_node("地形当たり判定"):
		コリジョン親=get_node("地形当たり判定")
	for ノード:Node in get_children():
		if コリジョン親:break
		if ノード is StaticBody3D:
			コリジョン親=ノード
			break
		for 階層2:Node in ノード.get_children():
			if 階層2 is StaticBody3D:
				コリジョン親=階層2
				break
		
	if not コリジョン親:
		コリジョン親=StaticBody3D.new()
		add_child(コリジョン親)
		コリジョン親.owner=ルートノード
		コリジョン親.name="地形当たり判定"
	else:
		if コリジョン親.has_node("地形コリジョン"):
			push_warning("既に実行済み。")
			return
	var collision_node:CollisionShape3D = CollisionShape3D.new()
	ルートノード.add_child(collision_node)
	collision_node.owner=ルートノード
	collision_node.shape = ルートノード.mesh.create_trimesh_shape()
	var 保存先:String="res://街チャンク処理/街コリジョン/"+ルートノード.name.trim_suffix(",a")+".tres"
	#collision_node.shape.take_over_path(保存先)
	var final_resource: ConcavePolygonShape3D
	if FileAccess.file_exists(保存先):
		# --- パターンA: すでにファイルがある場合 ---
		# 既存のリソースをメモリに呼び出す（これが「リンクの本体」）
		var existing_res:Resource = load(保存先)
		
		# 【重要】生成した new_shape の「頂点データ」だけを移植する
		# ConcavePolygonShape3D の中身は .data (Vector3配列) に詰まっています
		existing_res.data = collision_node.shape.data
		
		# 移植が終わった「既存のリソース」を保存対象にする
		final_resource = existing_res
	else:
		# --- パターンB: 初めて作る場合 ---
		final_resource = collision_node.shape
		final_resource.take_over_path(保存先)
	collision_node.shape=final_resource
	# 保存（FLAG_CHANGE_PATH を使うことでパスを確定）
	var flags = ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS
	ResourceSaver.save(final_resource,保存先, flags)
	
	
	var 位置:Vector3=collision_node.global_position
	ルートノード.remove_child(collision_node)
	コリジョン親.add_child(collision_node)
	collision_node.global_position=位置
	collision_node.owner=ルートノード
	collision_node.name="地形コリジョン"
	print_rich("[color=green]街の当たり判定を設定しました！[/color]")
	
	
