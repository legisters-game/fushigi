@tool
extends EditorScenePostImport

func _post_import(scene: Node):
	var 関節シーン: PackedScene = load("res://街チャンク処理/チャンクルート.tscn")
	
	# get_children() はコピーを配列で取るので、ループ中の remove_child は安全です
	for child in scene.get_children():
		if child is MeshInstance3D:
			# 1. 元の親から切り離す
			scene.remove_child(child)
			
			# 2. チャンクノードを生成
			var チャンクノード: Node3D = Node3D.new()
			チャンクノード.name = child.name + "_Chunk" # 名前重複を避けるため
			
			# 3. シーンに追加
			scene.add_child(チャンクノード)
			チャンクノード.add_child(child)
			
			# 4. 【重要】owner の設定
			# scene（ルート）をownerにすることで、エディタのシーンツリーに表示・保存されます
			チャンクノード.owner = scene
			child.owner = scene 
			
	return scene
