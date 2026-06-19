extends StaticBody3D
class_name レベルゲート
@export_file_path("*.tscn") var アクセスレベル:String
@export var アクセス番号:int
@export var 階層:int
func ガイド表示(オン:bool)->void:
	if オン:
		get_node("会話ガイドボタン").show()
	else:
		get_node("会話ガイドボタン").hide()
