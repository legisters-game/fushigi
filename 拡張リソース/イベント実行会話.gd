@icon("res://拡張リソース/アイコン/イベント発生会話.png")
extends イベント実行用オブジェクト
class_name イベント実行会話
@export var 会話:Array[セリフオブジェクト]

func 動作保障()->bool:
	for セリフ単品:セリフオブジェクト in 会話:
		if not セリフ単品:
			return  false
	if 会話.is_empty():return false
	return true
