@icon("res://拡張リソース/アイコン/イベント発生.png")
extends Resource
class_name イベント実行用オブジェクト

@export var イベント発生後ミッション:ミッションデータ
@export var 識別:レベル制御クラス.発生イベント=99

func 動作保障()->bool:
	return false
