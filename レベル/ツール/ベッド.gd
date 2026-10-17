extends 椅子アタッチクラス
class_name ベッドアタッチクラス

@export var 実行オブジェクト:イベント実行用オブジェクト
@export var 条件発生ミッションフラグ:String
func 実行(生き物:エンティティ)->void:
	if ターゲット==null:
		ターゲット=生き物
		生き物.寝る($"マーカー".global_position)
		if 当たり判定: 当たり判定.disabled=true
		ターゲット.global_rotation_degrees.y=初期回転
		座られた.emit()
		if ターゲット is プレイヤークラス:
			降りる()
			await ターゲット.レベル制御.GUI.フェードGUI.画面現る

func 降りる()->void:
	if ターゲット is プレイヤークラス:
		ターゲット.レベル制御.移動後実行予約(実行オブジェクト)
		await ターゲット.レベル制御.GUI.フェードGUI.画面現る
		
	if not ターゲット:return
	ターゲット.寝る()
	if 戻り位置マーカー:ターゲット.global_position=戻り位置マーカー.global_position
	var 全体制御:レベル制御クラス=ターゲット.レベル制御
	ターゲット=null
	if 当たり判定: 当たり判定.disabled=false
	await get_tree().create_timer(0.2).timeout
	全体制御.移動完了.emit()
	
