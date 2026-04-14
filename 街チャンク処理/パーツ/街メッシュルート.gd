@tool
extends MeshInstance3D
@export_tool_button("街全体表示","GuiVisibilityVisible")var 街表示:Variant=街切り替え

@export_tool_button("全ての設定が\n行えているかチェック","FileList")var チェック:Variant=チェック開始
@export_flags("地形判定無し","透明壁無し","高画質無し","平面で障害物無し")var メタ情報:int=0
enum {地形判定無し=1,透明壁無し=2,高画質無し=4,平面で障害物無し=8}

func _ready() -> void:
	if has_node("街全体ビュー"):
		get_node("街全体ビュー").queue_free()
	for i:StaticBody3D in find_children("地形当たり判定","StaticBody3D"):
		i.collision_mask=3
		i.collision_layer=3

func 街切り替え()->void:
	if has_node("街全体ビュー"):
		get_node("街全体ビュー").queue_free()
		return
	print_rich("[color=green]街読み込み中…[/color]")
	await  get_tree().create_timer(0.01).timeout
	var シーン:PackedScene=load("res://使わない/街全体ビュー.tscn")
	var ノード:Node=シーン.instantiate()
	add_child(ノード)
	ノード.owner=self
	print_rich("[color=green]完了！！[/color]")
	
func チェック開始()->void:
	var エラー:bool
	var 当たり判定制御ノード:チャンク当たり判定制御
	if scale!=Vector3(16,16,16):
		scale=Vector3(16,16,16)
		print_rich("[color=green]報告:[/color]  ルートのスケールに問題があったので修正しました。")
	if not メタ情報 & 地形判定無し or not メタ情報 & 平面で障害物無し:
		当たり判定制御ノード=has_type_recursive(self,チャンク当たり判定制御)
		if not 当たり判定制御ノード:
			printerr("地形当たり判定が無い")
			エラー=true

		for i:Node in get_children():
			var ヒット:Node=has_type_recursive(i,OccluderInstance3D)
			if ヒット:
				var オクルージョンカリング:OccluderInstance3D=ヒット
				オクルージョンカリング.name=name+"_oc"
				if not オクルージョンカリング.occluder:
					printerr("オクルージョンカリング、ベイクされていません")
					break
				rename_resource_keep_links(オクルージョンカリング.occluder,"res://街チャンク処理/街オクルージョン/"+name.trim_suffix(",a")+".occ")
				if 当たり判定制御ノード:
					if not 当たり判定制御ノード.オクルージョンノード==オクルージョンカリング:
						当たり判定制御ノード.オクルージョンノード=オクルージョンカリング
						print_rich("[color=green]報告:[/color]  当たり判定制御にオクルージョンカリングが\n割り当てられていなかったので割り当てました")
				else:
					printerr("オクルージョンカリングがあるなら「当たり判定制御」も必要です。")
				break
			
			else:
				printerr("オクルージョンカリングが無い")
				エラー=true
	if not メタ情報 & 透明壁無し:
		for i:Node in get_children():
			var ヒット:Node=has_type_recursive(i,透明壁コリジョン)
			if ヒット:
				break
			else:
				printerr("透明壁が無い")
				エラー=true
	if not メタ情報 & 高画質無し:
		for i:Node in get_children():
			var ヒット:Node=has_type_recursive(i,VoxelGI)
			if ヒット:
				var GI:VoxelGI=ヒット
				if GI.size==Vector3(20,20,20):
					push_warning("グローバルイルミネーション、範囲設定が初期値のままです。")
				if not GI.data:
					printerr("グローバルイルミネーション、ベイクされていない")
					break
				rename_resource_keep_links(GI.data,"res://街チャンク処理/街GI/"+name.trim_suffix(",a")+",グローバルイルミネーション_data.res")
				break
			else:
				printerr("グローバルイルミネーションが無い")
				エラー=true
	if not メタ情報 & 地形判定無し:
		for i:Node in get_children():
			var ヒット:Node=has_name_recursive(i,"地形コリジョン")
			if ヒット and ヒット is CollisionShape3D:
				var コリジョン:CollisionShape3D=ヒット
				if コリジョン.position==Vector3.ZERO:
					push_warning("街地形コリジョン、適切な位置に居ない可能性があります。")
				if not コリジョン.shape:
					printerr("生成されたコリジョンが消えている")
					エラー=true
					break
				rename_resource_keep_links(コリジョン.shape,"res://街チャンク処理/街コリジョン/"+name.trim_suffix(",a")+".tres")
				if 当たり判定制御ノード:
					if not has_name_recursive(当たり判定制御ノード,"地形コリジョン"):
						var 親スタ:Node=コリジョン.get_parent()
						if 親スタ:
							var 位置2:Vector3=コリジョン.global_position
							親スタ.remove_child(コリジョン)
							var 位置:Vector3=親スタ.global_position
							親スタ.get_parent().remove_child(親スタ)
							当たり判定制御ノード.add_child(親スタ)
							親スタ.owner=self
							親スタ.global_position=位置
							親スタ.add_child(コリジョン)
							コリジョン.owner=self
							コリジョン.global_position=位置2
							
							print_rich("[color=green]報告:[/color]  当たり判定制御に地形のノードが居ないので移動させました。")
						else:
							printerr("staticBodyノードは？消したの？？ダメだよ。")
							エラー=true
				else:
					printerr("地形の当たり判定があるなら「当たり判定制御」も必要です。")
					エラー=true
			else:
				printerr("グローバルイルミネーションが無い")
				エラー=true
	if not エラー:
		print_rich("[color=green]問題無しと判断しました！[/color]")
	
func has_type_recursive(node: Node, target_type) -> Node:
	# 指定した型に一致するか判定 (例: CollisionShape3D)
	if is_instance_of(node, target_type):
		return node
	# 子ノードをループして再帰的に探索
	for child in node.get_children():
		var a:Node=has_type_recursive(child, target_type)
		if a:
			return a
	return
# 使い方

func has_name_recursive(node: Node, target_type:String) -> Node:
	# 指定した型に一致するか判定 (例: CollisionShape3D)
	if node.name==target_type:
		return node
	# 子ノードをループして再帰的に探索
	for child in node.get_children():
		var a:Node=has_name_recursive(child, target_type)
		if a:
			return a
	return

func rename_resource_keep_links(current_res: Resource, new_path: String):
	# 1. 既存の古いパスを取得（後で削除するため）
	var old_path:String = current_res.resource_path
	
	if old_path == new_path:
		return # すでに同じなら何もしない
	
	# 2. 【最重要】リソースに「新しい住所」を教え込む
	# これにより、このリソースを参照している全ノードが
	# 「自分の参照先は new_path に変わったんだな」と認識します
	current_res.take_over_path(new_path)
	
	# 3. 内部のパス情報を手動で上書き（念のため）
	current_res.resource_path = new_path
	
	# 4. 新しい場所に保存
	# FLAG_CHANGE_PATH (4) を使うことで、このリソースの「家」を確定させます
	var flags = ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS
	var err = ResourceSaver.save(current_res, new_path, flags)
	
	if err == OK:
		print_rich("[color=green]報告:[/color]  リソースの保存先に問題があったので修正しました。", new_path)
		
		# 5. 古いファイルを削除（必要に応じて）
		if old_path != "" and FileAccess.file_exists(old_path):
			DirAccess.remove_absolute(old_path)
	else:
		printerr("リソースの保存先を修正しようとして失敗しました。: ", new_path)
