@tool
extends EditorScript

# マテリアルが入っている親フォルダのパス
const ROOT_FOLDER = "res://マテリアル"
# テクスチャが入っているフォルダのパス
const NORMAL_FOLDER = "res://マテリアル/立体補間"
const ROUGHNESS_FOLDER = "res://マテリアル/鏡面反射"

func _run() -> void:
	var count = 0
	count = process_folder(ROOT_FOLDER)
	print("----------------------------------------")
	print("完了！ 合計 ", count, " 個の minecraft マテリアルを更新しました。")

func process_folder(folder_path: String) -> int:
	var total = 0
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = folder_path.path_join(file_name)
				
				if dir.current_is_dir():
					total += process_folder(full_path)
				elif file_name.ends_with(".tres"):
					# ファイル名に "minecraft" が含まれている場合のみ処理する
					if "minecraft" in file_name.to_lower():
						apply_pbr_settings_with_textures(full_path, file_name)
						total += 1
			
			file_name = dir.get_next()
	return total

func apply_pbr_settings_with_textures(file_path: String, file_name: String) -> void:
	var mat = ResourceLoader.load(file_path)
	if not mat is StandardMaterial3D:
		return
	
	var lower_name = file_name.to_lower()
	var base_name = file_name.trim_suffix(".tres")
	
	# 1. 基本設定
	mat.cull_mode = BaseMaterial3D.CULL_BACK
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	
	# 2. 透明・半透明の振り分け
	if "glass" in lower_name or "stained_glass" in lower_name:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	elif "leaves" in lower_name or "trapdoor" in lower_name or "iron_bars" in lower_name or "ladder" in lower_name:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	else:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	
	# 3. PBR共通設定
	mat.metallic = 1.0
	mat.roughness = 0.5
	
	# 4. 「立体補間」フォルダから _n / _a テクスチャを探して割り当て
	var normal_tex = find_specific_texture(NORMAL_FOLDER, base_name, ["_n"])
	if normal_tex:
		mat.normal_enabled = true
		mat.normal_texture = normal_tex
		mat.ao_enabled = true
		mat.ao_light_affect = 1.0
		mat.ao_texture = normal_tex
		mat.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
	
	var height_tex = find_specific_texture(NORMAL_FOLDER, base_name, ["_a"])
	if height_tex:
		mat.heightmap_enabled = true
		mat.heightmap_scale = 5.0
		mat.heightmap_deep_parallax = true
		mat.heightmap_min_layers = 1
		mat.heightmap_max_layers = 64
		mat.heightmap_texture = height_tex
	
	# 5. 「鏡面反射」フォルダからテクスチャを探して割り当て
	var spec_tex = find_specific_texture(ROUGHNESS_FOLDER, base_name, ["_n", "_s", "_roughness", "_metallic"])
	if spec_tex:
		mat.metallic_texture = spec_tex
		mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		mat.roughness_texture = spec_tex
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN

	# 変更を保存
	ResourceSaver.save(mat, file_path)
	print("設定＆テクスチャ適用完了: ", file_name)

# 指定フォルダからブロック名とサフィックスに一致するテクスチャを探す関数
func find_specific_texture(dir_path: String, base_name: String, suffixes: Array) -> Texture2D:
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if not dir.current_is_dir():
				var lower_file = file.to_lower()
				# ブロック名が含まれているかチェック
				if base_name in lower_file:
					for s in suffixes:
						# サフィックス（例: _n.png など）が含まれているか
						if s in lower_file and (lower_file.ends_with(".png") or lower_file.ends_with(".jpg") or lower_file.ends_with(".tres")):
							var tex = ResourceLoader.load(dir_path.path_join(file))
							if tex is Texture2D:
								return tex
			file = dir.get_next()
	return null
