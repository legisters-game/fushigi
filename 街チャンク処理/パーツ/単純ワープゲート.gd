extends StaticBody3D

@export var アクセスマーカー:Marker3D
@export var 有効化:Node3D
@export var 無効化:Node3D
@export var カメラジャック:Camera3D
@export var カメラ戻す:bool=true
signal プレイヤー入った

func 実行()->void:
	if アクセスマーカー:
		get_tree().get_first_node_in_group("全体制御").単純ワープ(アクセスマーカー,true)
		if 有効化:有効化.show()
		await get_tree().create_timer(1).timeout
		if 無効化:無効化.hide()
		if カメラ戻す :
			get_tree().get_first_node_in_group("追尾カメラ").get_node("SpringArm3D/Camera3D").make_current()
		elif カメラジャック:
			カメラジャック.make_current()
		
		プレイヤー入った.emit()

func ガイド表示(オン:bool)->void:
	if オン:
		get_node("会話ガイドボタン").show()
	else:
		get_node("会話ガイドボタン").hide()
