@icon("res://拡張リソース/アイコン/イベント発生ムービー.png")
extends イベント実行用オブジェクト
class_name イベント実行ムービー

@export_file("*.tscn") var ムービーシーン:String

func 動作保障()->bool:
	return ムービーシーン!=""
