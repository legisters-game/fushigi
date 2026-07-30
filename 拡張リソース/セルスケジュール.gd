@icon("a")
class_name セルスケジュール extends Resource

@export var 名前:String
@export_range(0,1) var 開始時間: float
@export_range(0,1) var 終了時間: float
@export var 目的置: Vector3

@export var セリフ:Array[セリフオブジェクト]
@export_subgroup("オプション")
@export_file("*.tscn") var ディメンション:String=""
@export var ディメンションオブジェクト番号:int
@export var アニメーション:String



func _auto_register_marker(marker):
	# 整合性チェックのための新規データ作成
	目的置 = marker.global_position
	
	
	# 重複排除と整合性チェック
	
	# リソースの変更を通知
	emit_changed()
	print("自動登録完了: ", marker.global_position)
	
	# 連続登録の利便性のため、一瞬だけnullに戻す等の工夫も可能
	# ターゲットマーカー = null
