extends StaticBody3D
class_name レベルゲート
@export_file_path("*.tscn") var アクセスレベル:String
@export var アクセス番号:int
@export var 階層:int

signal プレイヤーインタラクト
func ガイド表示(オン:bool)->void:
	if オン:
		get_node("会話ガイドボタン").show()
	else:
		get_node("会話ガイドボタン").hide()
		
func 実行()->void:
	var レベル制御:レベル制御クラス=get_tree().get_first_node_in_group("全体制御")
	var フェード画面:画面フェードクラス
	var UI:コントロールルート= get_tree().get_first_node_in_group("UI")
	if UI:
		フェード画面=UI.get_node_or_null("画面フェード")
		
	if レベル制御:
		プレイヤーインタラクト.emit()
		レベル制御.レベル移動(アクセスレベル,アクセス番号,階層)
		if フェード画面 and フェード画面.消え中:
			await フェード画面.画面消えた
