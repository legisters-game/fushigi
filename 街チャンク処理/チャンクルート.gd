@tool
extends Node3D
class_name チャンク管理クラス
@export var マテリアル:StandardMaterial3D
@export var デバッグあり:bool
@export var ナビメッシュ:NavigationMesh
var 保持:Node3D
#@export var dssa:NavigationRegion3D
var 出現済み:bool
var 解放された:bool=true
var 保存パス:String
var 内部保存パス:String

var ロード中パス: String = ""
var ロード中: bool = false

var ナビ生成済み:NavigationMesh

func _ready() -> void:
	内部保存パス = "res://街チャンク処理/街シーン/"+name.replace("_Chunk", "")+".tscn"
	if ResourceLoader.exists(内部保存パス,"PackedScene"):
		for i in get_children():
			if i is NavigationRegion3D:
				i.queue_free()
	if Engine.is_editor_hint():
		return
		for i in get_children():
			if i is NavigationRegion3D:
				i.navigation_mesh.border_size=0
				i.navigation_mesh.cell_size=0.25
				i.navigation_mesh.cell_height=0.01
				i.navigation_mesh.agent_max_climb=0.55
				i.navigation_mesh.border_size=0
				i.navigation_mesh.agent_height=2
				#await get_tree().create_timer(randi_range(1,60)).tim
				#i.bake_navigation_mesh()
				i.navigation_mesh=null
		return

	#for i in get_children():
		#if i is NavigationRegion3D:
			#保持=i
			#remove_child(保持)
			#break
	hide()
	#処理有無制御(false)
	デバッグ(true)
	保存パス = name.replace(",a_Chunk", "")+".tscn"
	var dir_path = "user://nv/"
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
		print("ディレクトリを作成しました: ", dir_path)
	var dir_senpath = "user://sen/"
	#ロード中パス=dir_senpath+保存パス
	if not DirAccess.dir_exists_absolute(dir_senpath):
		DirAccess.make_dir_recursive_absolute(dir_senpath)
		print("ディレクトリを作成しました: ", dir_senpath)
	
	var packed_scene = PackedScene.new()
	for i in get_children():
		if i is NavigationRegion3D:
			disconnect_all_signals_recursive(i)
			set_owner_recursive(i,i)
			var result = packed_scene.pack(i)
			if result == OK:
				# 4. ファイルとして保存
				var save_result = ResourceSaver.save(packed_scene, dir_senpath+保存パス)
				if save_result == OK:
					print("シーンを保存しました: ", dir_senpath+保存パス)
					i.queue_free()
				else:
					print("保存エラーコード: ", save_result)
			else:
				print("パックに失敗しました（恐らくroot_nodeが不正）")
			break
	
	
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body and body.name=="当たり判定有効範囲":
		show()
		デバッグ(false)
		#処理有無制御(true)
		真処理有無制御(true)
		#add_child(保持)
		


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body and body.name=="当たり判定有効範囲":
		真処理有無制御(false)
		#処理有無制御(false)
		デバッグ(true)
		#remove_child(保持)
		#hide()アニメーションの都合上処理有無制御で制御


func 真処理有無制御(有無:bool)->void:
	if 有無:
		var dir_senpath = "user://sen/"
		var full_path = dir_senpath + 保存パス
		出現済み=true
		if ロード中:
			return
		elif not 解放された:
			var アニメーション用ナビ変数:NavigationRegion3D
			for i in get_children():
				if i is NavigationRegion3D:
					アニメーション用ナビ変数=i
					break
			if アニメーション用ナビ変数:
				var メッシュノード:MeshInstance3D
				for e:Node3D in アニメーション用ナビ変数.get_children():
					if e is MeshInstance3D:
						メッシュノード=e
						break
				if メッシュノード:
					var アニメ:Tween=get_tree().create_tween()
					メッシュノード.transparency=1
					アニメ.bind_node(メッシュノード)
					アニメ.tween_property(メッシュノード,"transparency",0,1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			return
			
			
			
		if ResourceLoader.exists(内部保存パス,"PackedScene"):
			var err = ResourceLoader.load_threaded_request(内部保存パス)
			if err == OK:
				ロード中パス = 内部保存パス
				ロード中 = true
				print("内部から")
				return
			

			
		var err = ResourceLoader.load_threaded_request(full_path)
		if err == OK:
			ロード中パス = full_path
			ロード中 = true
			# print("別スレッドでロード開始: ", name)
	else:
		if ロード中:
			# ロード中のフラグを下ろすだけで、完了時の add_child をスキップさせる
			ロード中 = false
			ロード中パス = ""
			# print("ロード中に範囲外に出たためキャンセル: ", name)
		
		var ルート:NavigationRegion3D
		for i:Node3D in get_children():
			if i is NavigationRegion3D:
				ルート=i
				break
		if ルート:
			出現済み=false
			var メッシュノード:MeshInstance3D
			for e:Node3D in ルート.get_children():
				if e is MeshInstance3D:
					メッシュノード=e
					break
			if メッシュノード:
				var アニメ:Tween=get_tree().create_tween()
				アニメ.bind_node(メッシュノード)
				アニメ.tween_property(メッシュノード,"transparency",1,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				await アニメ.finished
				if 出現済み:
					return
				#メッシュノード.process_mode=Node.PROCESS_MODE_DISABLED
				ナビ生成済み=ルート.navigation_mesh
				
				
				ルート.get_parent().remove_child(ルート)
				ルート.queue_free()
				解放された=true
				await get_tree().create_timer(10).timeout
				ナビ生成済み=null


func 処理有無制御(有無:bool)->void:
	var 親:NavigationRegion3D
	for a in get_children():
		if a is NavigationRegion3D:
			親=a
			break
	if not 親:return
	for i:Node in 親.get_children():
		if i is MeshInstance3D:
			var ノード:MeshInstance3D=i
			if 有無:
				ノード.process_mode=Node.PROCESS_MODE_INHERIT
				ノード.transparency=1
				var アニメ:Tween=get_tree().create_tween()
				アニメ.bind_node(ノード)
				アニメ.tween_property(ノード,"transparency",0,1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
				出現済み=true
			else:
				出現済み=false
				var アニメ:Tween=get_tree().create_tween()
				アニメ.bind_node(ノード)
				アニメ.tween_property(ノード,"transparency",1,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				await アニメ.finished
				if 出現済み:
					return
				ノード.process_mode=Node.PROCESS_MODE_DISABLED
				hide()
	for i in get_children():
			if i is NavigationRegion3D:
				if 有無 and not ナビ生成済み:
					#外部保存されているか
					var path="user://nv/"+str(name)+".res"
					var nav_mesh = ResourceLoader.load(path) as NavigationMesh
					if nav_mesh:
						#されてたら読み込み
						i.navigation_mesh=nav_mesh
					else:
						#されてなければ、ベイク書き込み
						i.navigation_mesh=ナビメッシュ.duplicate()
					#i.navigation_mesh.border_size=0
					#i.navigation_mesh.cell_size=0.25
					#i.navigation_mesh.cell_height=0.01
					#i.navigation_mesh.agent_max_climb=0.55
					#i.navigation_mesh.border_size=0
						i.navigation_mesh.agent_height=2.1
				#await get_tree().create_timer(randi_range(1,60)).tim
						i.bake_navigation_mesh()
						
						var error = ResourceSaver.save(i.navigation_mesh, path)
						if error == OK:
							pass
							#print("ナビメッシュの保存に成功しました: ", path)
						else:
							print("保存エラー: ", error)
						
					
				elif 有無 and ナビ生成済み:
					i.navigation_mesh=ナビ生成済み
				else:
					ナビ生成済み=i.navigation_mesh
					i.navigation_mesh=null
					await get_tree().create_timer(10).timeout
					ナビ生成済み=null

func デバッグ(ブール:bool)->void:
	if not デバッグあり:
		return
	for i:Node in get_children():
		if i is MeshInstance3D:
			if ブール:
				i.material_override=マテリアル
			else:
				i.material_override=null
				
func 強制表示():
	show()


func set_owner_recursive(node: Node, root: Node):
	for child in node.get_children():
		child.owner = root # これをしないと PackedScene に含まれない
		set_owner_recursive(child, root)


func disconnect_all_signals_recursive(node: Node):
	# そのノードが持っているすべてのシグナルのリストを取得
	for sig in node.get_signal_list():
		# そのシグナルの接続情報を取得
		var connections = node.get_signal_connection_list(sig.name)
		for con in connections:
			# 接続を解除
			node.disconnect(sig.name, con.callable)
	
	# 子供たちに対しても同じ処理を繰り返す
	for child in node.get_children():
		disconnect_all_signals_recursive(child)


func _process(_delta: float) -> void:
	if ロード中:
		var status = ResourceLoader.load_threaded_get_status(ロード中パス)
		
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				# ロード完了
				print("台無し")
				var packed_scene = ResourceLoader.load_threaded_get(ロード中パス) as PackedScene
				if ロード中: # 待機中に 有無:false が走っていないか最終チェック
					_ロード完了処理(packed_scene)
					print("読み込み完了")
				
				ロード中 = false
				ロード中パス = ""
				
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				ロード中 = false
				ロード中パス = ""

				
func _ロード完了処理(packed_scene: PackedScene):
	if packed_scene and 解放された:
		var instance = packed_scene.instantiate()
		add_child(instance)
		解放された = false
		
		# ナビメッシュの設定やアニメーション開始
		# （元の「for i in get_children():」以降のナビベイク・Tween処理をここに移動）
		セットアップ完了通知(instance)

func セットアップ完了通知(_instance):
	var アニメーション用ナビ変数:NavigationRegion3D
	
	for i in get_children():
		if i is NavigationRegion3D:
			アニメーション用ナビ変数=i
			if not ナビ生成済み:
				#外部保存されているか
				var path="user://nv/"+str(name)+".res"
				var nav_mesh = ResourceLoader.load(path) as NavigationMesh
				if nav_mesh:
					#されてたら読み込み
					i.navigation_mesh=nav_mesh
				else:
					#されてなければ、ベイク書き込み
					i.navigation_mesh=ナビメッシュ.duplicate()
					#i.navigation_mesh.border_size=0
					#i.navigation_mesh.cell_size=0.25
					#i.navigation_mesh.cell_height=0.01
					#i.navigation_mesh.agent_max_climb=0.55
					#i.navigation_mesh.border_size=0
					i.navigation_mesh.agent_height=2.1
					#await get_tree().create_timer(randi_range(1,60)).tim
					i.bake_navigation_mesh()
						
					var error = ResourceSaver.save(i.navigation_mesh, path)
					if error == OK:
						pass
						#print("ナビメッシュの保存に成功しました: ", path)
					else:
						print("保存エラー: ", error)
						
			elif ナビ生成済み:
				i.navigation_mesh=ナビ生成済み
			else:
				#これを移動
				ナビ生成済み=i.navigation_mesh
				i.navigation_mesh=null
				await get_tree().create_timer(10).timeout
				ナビ生成済み=null
			break
	if アニメーション用ナビ変数:
		var メッシュノード:MeshInstance3D
		for e:Node3D in アニメーション用ナビ変数.get_children():
			if e is MeshInstance3D:
				メッシュノード=e
				break
		if メッシュノード:
			var アニメ:Tween=get_tree().create_tween()
			メッシュノード.transparency=1
			アニメ.bind_node(メッシュノード)
			アニメ.tween_property(メッシュノード,"transparency",0,1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
