@tool
extends Node3D
class_name チャンク管理クラス
@export var マテリアル:StandardMaterial3D
@export var デバッグあり:bool
@export var ナビメッシュ:NavigationMesh
var 保持:Node3D
#@export var dssa:NavigationRegion3D
var 出現済み:bool
var 保存パス:String
var ナビ生成済み:NavigationMesh
func _ready() -> void:
	if Engine.is_editor_hint():
		return
		for i in get_children():
			if i is NavigationRegion3D:
				i.navigation_mesh.border_size=0
				i.navigation_mesh.cell_size=0.25
				i.navigation_mesh.cell_height=0.01
				i.navigation_mesh.agent_max_climb=0.55
				i.navigation_mesh.border_size=0
				i.navigation_mesh.agent_height=2
				#await get_tree().create_timer(randi_range(1,60)).tim
				#i.bake_navigation_mesh()
				i.navigation_mesh=null
		return

	#for i in get_children():
		#if i is NavigationRegion3D:
			#保持=i
			#remove_child(保持)
			#break
	hide()
	#処理有無制御(false)
	デバッグ(true)
	保存パス = name.replace("_Chunk", "")+".tscn"
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body and body.name=="当たり判定有効範囲":
		show()
		デバッグ(false)
		処理有無制御(true)
		#add_child(保持)
		


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body and body.name=="当たり判定有効範囲":
		処理有無制御(false)
		デバッグ(true)
		#remove_child(保持)
		#hide()アニメーションの都合上処理有無制御で制御



func 処理有無制御(有無:bool)->void:
	var 親:NavigationRegion3D
	for a in get_children():
		if a is NavigationRegion3D:
			親=a
			break
	if not 親:return
	for i:Node in 親.get_children():
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
	for i in get_children():
			if i is NavigationRegion3D:
				if 有無 and not ナビ生成済み:
					i.navigation_mesh=ナビメッシュ.duplicate()
					#i.navigation_mesh.border_size=0
					#i.navigation_mesh.cell_size=0.25
					#i.navigation_mesh.cell_height=0.01
					#i.navigation_mesh.agent_max_climb=0.55
					#i.navigation_mesh.border_size=0
					i.navigation_mesh.agent_height=2.1
				#await get_tree().create_timer(randi_range(1,60)).tim
					i.bake_navigation_mesh()
				elif 有無 and ナビ生成済み:
					i.navigation_mesh=ナビ生成済み
				else:
					ナビ生成済み=i.navigation_mesh
					i.navigation_mesh=null
					await get_tree().create_timer(10).timeout
					ナビ生成済み=null

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
