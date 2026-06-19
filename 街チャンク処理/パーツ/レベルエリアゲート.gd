extends Area3D

class_name レベルエリアゲート
@export_file_path("*.tscn") var アクセスレベル:String
@export var アクセス番号:int
@export var 階層:int
@export var 移動時間:float

func _ready() -> void:
	if アクセスレベル=="":
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is プレイヤークラス:
		if not body.レベル制御 or body.レベル移動中:return
		body.移動操作ロック=true
		var 位置マーカー:Marker3D
		for i in get_children():
			if i is Marker3D:
				位置マーカー=i
				break
		if 位置マーカー:
			var 上書きプレイヤー復帰位置:Vector3
			body.簡易目的地へ移動(位置マーカー.global_position,true)
			if 0.02<移動時間:
				await get_tree().create_timer(移動時間).timeout
			body.レベル制御.レベル移動(アクセスレベル,アクセス番号,階層)
			上書きプレイヤー復帰位置=body.操作ロック前位置
			body.レベル制御.都市プレイヤー座標=上書きプレイヤー復帰位置
			#body.簡易移動停止()
			#レベル制御で常に発火せせる
			
		else:
			body.レベル制御.レベル移動(アクセスレベル,アクセス番号,階層)
		データロガー.プレイヤーステート保存(データロガー.プレイヤーデータ.座標,body.操作ロック前位置)
