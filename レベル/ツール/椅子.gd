extends StaticBody3D
class_name 椅子アタッチクラス
var ターゲット:エンティティ
var 当たり判定:CollisionShape3D
@export var 戻り位置マーカー:Marker3D
@export var 回転上書き:bool
@export_range(0,360) var 初期回転:float
signal 座られた
func _ready() -> void:
	当たり判定=当たり判定取得()

func 実行(生き物:エンティティ)->void:
	if ターゲット==null:
		ターゲット=生き物
		生き物.座る($"マーカー".global_position)
		if 当たり判定: 当たり判定.disabled=true
		if 回転上書き: ターゲット.global_rotation_degrees.y=初期回転
		座られた.emit()
		#await get_tree().create_timer(0.02).timeout
		#ターゲット.global_position=$"マーカー".global_position
		
		

func 降りる()->void:
	ターゲット.座る()
	if 戻り位置マーカー:ターゲット.global_position=戻り位置マーカー.global_position
	ターゲット=null
	if 当たり判定: 当たり判定.disabled=false
	

func 当たり判定取得()->CollisionShape3D:
	var 返値:CollisionShape3D
	for i:Node in get_children():
		if i is CollisionShape3D:
			return i
	return 返値

func ガイド表示(する:bool)->void:
	$"会話ガイドボタン".visible=する


func _unhandled_input(_event: InputEvent) -> void:
	if ターゲット is プレイヤークラス:
		if Input.is_action_just_pressed("降りる"):
			降りる()
