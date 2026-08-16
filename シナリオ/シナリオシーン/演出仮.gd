@tool
extends 演出基盤クラス
##オープニング用チャンクルートにアクセスして街の可視範囲を広げる
var シェイプ:Shape3D
var サイズ:Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	#add_child(Node3D.new())
	var 最初のチャンクルート:チャンク管理クラス
	if get_tree().get_first_node_in_group("チャンクルート") is オープンワールド管理クラス:
		for 子ノード:Node in get_tree().get_first_node_in_group("チャンクルート").get_children():
			if 子ノード is チャンク管理クラス:
				最初のチャンクルート=子ノード
				break
	if 最初のチャンクルート and 最初のチャンクルート.get_children()[0].get_children()[0]is CollisionShape3D:
		if 最初のチャンクルート.get_children()[0].get_children()[0].shape:シェイプ=最初のチャンクルート.get_children()[0].get_children()[0].shape
		if シェイプ:
			サイズ=シェイプ.size
			シェイプ.size=Vector3(シェイプ.size.x*2,シェイプ.size.y*2,シェイプ.size.z*2)
		


func _on_演出完了通知() -> void:
	if シェイプ:
		シェイプ.size=サイズ
