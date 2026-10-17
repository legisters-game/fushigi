extends イベント実行会話
class_name イベント実行会話相手

@export var カメラ上書き:カメラオーバーライド
@export var 相手名前:String
@export var キャラ指定有効:bool
@export var キャラ:スケジュール管理クラス.NPC

func 動作保障()->bool:
	if super() and カメラ上書き:
		return true
	else:
		return false
