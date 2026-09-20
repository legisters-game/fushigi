@icon("res://拡張リソース/アイコン/拡張ノード/チャンクルート.png")
@tool
extends Node3D
class_name チャンク管理クラス
@export var マテリアル:StandardMaterial3D
@export var デバッグあり:bool
@export var ナビメッシュ:NavigationMesh

##出現が完了したらtrue
var 出現済み:bool
##街が解放されたらtrue
var 解放された:bool=true
##ディレクトリ無し。名前だけ
var 保存パス:String
##内部パス:res
var 内部保存パス:String
##スレッドで読んでいる街のデータが保存されているパス
var ロード中パス: String = ""
##ロード中にtrue
var ロード中: bool = false
##ナビメッシュが入る条件式で使う
var ナビ生成済み:NavigationMesh
##強制表示中にtrue
var 強制表示中:bool
##論理的に表示されていることならばtrue
var 理論表示中:bool
signal 強制表示解除シグナル

func _ready() -> void:
	#自分の名前に依存する↓
	内部保存パス = "res://街チャンク処理/街シーン/"+name.replace("_Chunk", "")+".tscn"
	#すでに外部保存されている場合は子のメッシュをもといナビがルートのノードを消去する
	#実行中に参照するため
	if ResourceLoader.exists(内部保存パス,"PackedScene"):
		for 子ノード:Node in get_children():
			if 子ノード is NavigationRegion3D:
				子ノード.queue_free()
	if Engine.is_editor_hint():
		return
		#おじさん、編集中にナビゲーションを反映する時代はもう終わりましたよ。。
#		for 子ノード:Node in get_children():
#			if 子ノード is NavigationRegion3D:
#				子ノード.navigation_mesh.border_size=0
#				子ノード.navigation_mesh.cell_size=0.25
#				子ノード.navigation_mesh.cell_height=0.01
#				子ノード.navigation_mesh.agent_max_climb=0.55
#				子ノード.navigation_mesh.border_size=0
#				子ノード.navigation_mesh.agent_height=2
				#await get_tree().create_timer(randi_range(1,60)).tim
				#i.bake_navigation_mesh()
#				子ノード.navigation_mesh=null
#		return

	#for i in get_children():
		#if i is NavigationRegion3D:
			#保持=i
			#remove_child(保持)
			#break
	hide()#一応非表示
	デバッグ(true)#なぜ？
	保存パス = name.replace(",a_Chunk", "")+".tscn"
	
	#ディレクトリがあるか確認する、無かったら生成
	var ディレクトリパス:String = "user://nv/"
	if not DirAccess.dir_exists_absolute(ディレクトリパス):
		DirAccess.make_dir_recursive_absolute(ディレクトリパス)
		print("ディレクトリを作成しました: ", ディレクトリパス)
	var ディレクトリシーンパス:String = "user://sen/"
	#ロード中パス=ディレクトリシーンパス+保存パス
	if not DirAccess.dir_exists_absolute(ディレクトリシーンパス):
		DirAccess.make_dir_recursive_absolute(ディレクトリシーンパス)
		print("ディレクトリを作成しました: ", ディレクトリシーンパス)
	
	#初回版、街のメッシュを外部シーンに保存する。
	var シーンパック:PackedScene = PackedScene.new()
	for 子ノード:Node in get_children():
		if 子ノード is NavigationRegion3D:
			シグナル切断(子ノード)
			オーナー回帰セット(子ノード,子ノード)
			var 結果:Error = シーンパック.pack(子ノード)
			if 結果 == OK:
				# 4. ファイルとして保存
				var 保存結果:Error = ResourceSaver.save(シーンパック, ディレクトリシーンパス+保存パス)
				if 保存結果 == OK:
					print("シーンを保存しました: ", ディレクトリシーンパス+保存パス)
					子ノード.queue_free()
				else:
					print("保存エラーコード: ", 保存結果)
			else:
				print("パックに失敗しました（恐らくroot_nodeが不正）")
			break
	
	
func _on_area_3d_body_entered(体: Node3D) -> void:
	if 体 and 体.name=="当たり判定有効範囲":
		show()
		デバッグ(false)
		#処理有無制御(true)
		真処理有無制御(true)
		理論表示中=true
		#add_child(保持)
		

##プレイヤーが離れた瞬間
func _on_area_3d_body_exited(体: Node3D) -> void:
	if 体 and 体.name=="当たり判定有効範囲":
		if not 強制表示中:
			真処理有無制御(false)
		#処理有無制御(false)
		#デバッグ(true)
		#何がなんであれ、この変数が正になる為↓
		理論表示中=false
		#remove_child(保持)
		#hide()アニメーションの都合上処理有無制御で制御

##街の表示と非表示を引数を用いて実装しています。
func 真処理有無制御(有無:bool)->void:
	if 有無:
		#表示側
		var ディレクトリシーンパス:String = "user://sen/"
		var フルパス:String = ディレクトリシーンパス + 保存パス
		
		#グローバル変数にて記録しておくことで、消えた時、の遅延(アニメーション)で、
		#その最中に表示が来たらアニメーション終了時 街を非表示するのを無効にする為利用する。
		出現済み=true
		#街が既にロード済ならスキップする。
		if ロード中:
			return
		elif not 解放された:#まだ解放されていない場合、
			var アニメーション用ナビ変数:NavigationRegion3D
			#アニメーション用のナビノードを取得↓
			for 子ノード:Node in get_children():
				if 子ノード is NavigationRegion3D:
					アニメーション用ナビ変数=子ノード
					break
			
			#ナビノードがあった場合↓
			if アニメーション用ナビ変数:
				var メッシュノード:MeshInstance3D
				#アニメーション用のノードを取得↓
				for アニメーション暫定ノード:Node3D in アニメーション用ナビ変数.get_children():
					if アニメーション暫定ノード is MeshInstance3D:
						メッシュノード=アニメーション暫定ノード
						break
				
				#アニメーション用のノードがあるのと 透明でない場合↓
				if メッシュノード and メッシュノード.transparency!=0:
					var アニメ:Tween=get_tree().create_tween()
					メッシュノード.transparency=1
					アニメ.bind_node(メッシュノード)
					アニメ.tween_property(メッシュノード,"transparency",0,1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
					await アニメ.finished
					if get_tree().get_first_node_in_group("全体制御") is レベル制御クラス:
						get_tree().get_first_node_in_group("全体制御").読み込み完了(name)
			#アニメーションの指示を出して終了
			return
		#街のデータは無く、読み直す
		elif ResourceLoader.exists(内部保存パス,"PackedScene"):
			#スレッドで読み込み命令開始↓
			var エラー:Error = ResourceLoader.load_threaded_request(内部保存パス)
			if エラー == OK:
				ロード中パス = 内部保存パス
				ロード中 = true
				get_tree().get_first_node_in_group("全体制御").読み込み追加(name)
				return
		else:#ゲーム内部にシーンが保存されていない場合↓
			var err:Error = ResourceLoader.load_threaded_request(フルパス)
			if err == OK:
				ロード中パス = フルパス
				ロード中 = true
				# print("別スレッドでロード開始: ", name)
	else:
		#非表示側
		if get_tree().get_first_node_in_group("全体制御") is レベル制御クラス:
			get_tree().get_first_node_in_group("全体制御").読み込み完了(name)
		
		# ロード中のフラグを下ろすだけで、完了時の add_child をスキップさせる
		if ロード中:
			ロード中 = false
			ロード中パス = ""
			# print("ロード中に範囲外に出たためキャンセル: ", name)
		
		#街メッシュのルートノード取得↓
		var ルート:NavigationRegion3D
		for 子ノード:Node3D in get_children():
			if 子ノード is NavigationRegion3D:
				ルート=子ノード
				break
		#ルートを取得出来た場合↓
		if ルート:
			#出現したことをリセットする
			出現済み=false
			#ここで真のメッシュノードを取得する↓
			var メッシュノード:MeshInstance3D
			for 子ノード:Node3D in ルート.get_children():
				if 子ノード is MeshInstance3D:
					メッシュノード=子ノード
					break
			#メッシュノード取得できた場合↓
			if メッシュノード:
				var アニメ:Tween=get_tree().create_tween()
				アニメ.bind_node(メッシュノード)
				アニメ.tween_property(メッシュノード,"transparency",1,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				await アニメ.finished
				if 出現済み:#もし、消えている最中にプレイヤーが入ってきたら消すのをやめる
					return
				#メッシュノード.process_mode=Node.PROCESS_MODE_DISABLED
				ナビ生成済み=ルート.navigation_mesh#ナビメッシュを変数保持する。2度目は外部から読み込まない。
				
				ルート.get_parent().remove_child(ルート)#自身を消す。
				ルート.queue_free()
				#解放されたことを変数で保持する。
				解放された=true
				await get_tree().create_timer(10).timeout
				ナビ生成済み=null#十秒以内だけナビメッシュは保持される。

##街のメッシュをオーバーライドして視覚的にデバッグする[br]子がいないと機能しない
func デバッグ(ブール:bool)->void:
	if not デバッグあり:
		return
	for 子ノード:Node in get_children():
		if 子ノード is MeshInstance3D:
			if ブール:
				子ノード.material_override=マテリアル
			else:
				子ノード.material_override=null
				
##何が何であれ表示する。
func 強制表示():
	show()
	真処理有無制御(true)
	強制表示中=true

##何が何であれ表示するを解除[br]強制表示中をfalseにする
func 強制表示解除()->void:
	強制表示中=false
	if not 理論表示中:
		真処理有無制御(false)
	強制表示解除シグナル.emit()

##外部シーンとして保存させあるためオーナーを書き換える。[br]ノード:から下の子全て対象
func オーナー回帰セット(ノード: Node, ルート: Node)->void:
	for 子ノード:Node in ノード.get_children():
		子ノード.owner = ルート # これをしないと PackedScene に含まれない
		オーナー回帰セット(子ノード, ルート)

##外部シーンと保存するときにシグナルが邪魔になるのでこの関数を使用する
func シグナル切断(ノード: Node)->void:
	# そのノードが持っているすべてのシグナルのリストを取得
	for シグナル:Dictionary in ノード.get_signal_list():
		# そのシグナルの接続情報を取得
		var 接続達:Array[Dictionary] = ノード.get_signal_connection_list(シグナル.name)
		for 接続:Dictionary in 接続達:
			# 接続を解除
			ノード.disconnect(シグナル.name, 接続.callable)
	
	# 子供たちに対しても同じ処理を繰り返す
	for 子ノード:Node in ノード.get_children():
		シグナル切断(子ノード)


func _process(_delta: float) -> void:
	if ロード中:
		var ステータス = ResourceLoader.load_threaded_get_status(ロード中パス)
		
		match ステータス:
			ResourceLoader.THREAD_LOAD_LOADED:
				# ロード完了
				#print("台無し")
				var シーンパッケージ:PackedScene = ResourceLoader.load_threaded_get(ロード中パス) as PackedScene
				if ロード中: # 待機中に 有無:false が走っていないか最終チェック
					_ロード完了処理(シーンパッケージ)
					print("読み込み完了")
				
				ロード中 = false
				ロード中パス = ""
				
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				ロード中 = false
				ロード中パス = ""

func _ロード完了処理(シーンパッケージ: PackedScene)->void:
	if シーンパッケージ and 解放された:
		var インスタンス:Node = シーンパッケージ.instantiate()
		add_child(インスタンス)
		解放された = false
		セットアップ完了通知(インスタンス)

func セットアップ完了通知(_instance)->void:
	var アニメーション用ナビ変数:NavigationRegion3D
	
	for 子ノード:Node in get_children():
		if 子ノード is NavigationRegion3D:
			#アニメーション用ナビ変数を取りに行く↓
			アニメーション用ナビ変数=子ノード
			#ナビが外部保存されているか
			if not ナビ生成済み:
				var パス:String="user://nv/"+str(name)+".res"
				var ロードナビゲーションメッシュ:NavigationMesh = ResourceLoader.load(パス) as NavigationMesh
				#内部リソースを参照しに行って、使用されていることを把握して、使用する↓
				if ロードナビゲーションメッシュ:
					#されてたら読み込み
					子ノード.navigation_mesh=ロードナビゲーションメッシュ
				else:
					#されてなければ、ベイク書き込み、そして外部に保存する。
					子ノード.navigation_mesh=ナビメッシュ.duplicate()#空のリソースとしてコピーを作成する。
					#子ノード.navigation_mesh.border_size=0
					#子ノード.navigation_mesh.cell_size=0.25
					#子ノード.navigation_mesh.cell_height=0.01
					#子ノード.navigation_mesh.agent_max_climb=0.55
					#子ノード.navigation_mesh.border_size=0
					子ノード.navigation_mesh.agent_height=2.1
					#await get_tree().create_timer(randi_range(1,60)).tim
					子ノード.bake_navigation_mesh()
					
					var error:Error = ResourceSaver.save(子ノード.navigation_mesh, パス)
					if error == OK:
						pass
						#print("ナビメッシュの保存に成功しました: ", path)
					else:
						print("保存エラー: ", error)
			
			elif ナビ生成済み:
				子ノード.navigation_mesh=ナビ生成済み
			else:
				#これを移動
				ナビ生成済み=子ノード.navigation_mesh
				子ノード.navigation_mesh=null
				await get_tree().create_timer(10).timeout
				ナビ生成済み=null
			break
	#アニメーション用ナビ変数を取得できていた場合↓
	if アニメーション用ナビ変数:
		var メッシュノード:MeshInstance3D
		#メッシュノード取得↓
		for アニメーション用暫定ノード:Node3D in アニメーション用ナビ変数.get_children():
			if アニメーション用暫定ノード is MeshInstance3D:
				メッシュノード=アニメーション用暫定ノード
				break
		#メッシュノードを取得できていた場合↓
		if メッシュノード:
			var アニメ:Tween=get_tree().create_tween()
			メッシュノード.transparency=1
			アニメ.bind_node(メッシュノード)
			アニメ.tween_property(メッシュノード,"transparency",0,1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			await アニメ.finished
			if get_tree().get_first_node_in_group("全体制御") is レベル制御クラス:
				get_tree().get_first_node_in_group("全体制御").読み込み完了(name)
