@tool
extends Node3D
class_name チャンク管理クラス
@export var マテリアル:StandardMaterial3D
@export var デバッグあり:bool
var 出現済み:bool
var 保存パス:String
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	hide()
	#処理有無制御(false)
	デバッグ(true)
	保存パス = name.replace("_Chunk", "")+".tscn"
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body and body.name=="当たり判定有効範囲":
		show()
		デバッグ(false)
		処理有無制御(true)
		


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body and body.name=="当たり判定有効範囲":
		処理有無制御(false)
		デバッグ(true)
		#hide()アニメーションの都合上処理有無制御で制御



func 処理有無制御(有無:bool)->void:
	for i:Node in get_children():
		if i is MeshInstance3D:
			var ノード:MeshInstance3D=i
			if 有無:
				ノード.process_mode=Node.PROCESS_MODE_INHERIT
				ノード.transparency=1
				var アニメ:Tween=get_tree().create_tween()
				アニメ.bind_node(ノード)
				アニメ.tween_property(ノード,"transparency",0,1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
				出現済み=true
			else:
				出現済み=false
				var アニメ:Tween=get_tree().create_tween()
				アニメ.bind_node(ノード)
				アニメ.tween_property(ノード,"transparency",1,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				await アニメ.finished
				if 出現済み:
					return
				ノード.process_mode=Node.PROCESS_MODE_DISABLED
				hide()

func デバッグ(ブール:bool)->void:
	if not デバッグあり:
		return
	for i:Node in get_children():
		if i is MeshInstance3D:
			if ブール:
				i.material_override=マテリアル
			else:
				i.material_override=null
				
func 強制表示():
	show()
