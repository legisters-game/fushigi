extends Node3D
@export var マテリアル:StandardMaterial3D
@export var デバッグあり:bool
var 保存パス:String
func _ready() -> void:
	if Engine.is_editor_hint():
		#for i in get_children():
			#if i is MeshInstance3D:
				#i.show()
				#scale=Vector3(-3,-3,-3)
				#var ベース位置:Vector3=i.global_position
				#scale=Vector3(1,1,1)
				#var ベース:Vector3=i.scale
				#i.scale.x=i.scale.x+16
				#i.scale.y=i.scale.y+16
				#i.scale.z=i.scale.z+16
				#i.global_position=ベース位置
				
			
		return
	hide()
	処理有無制御(false)
	デバッグ(true)
	保存パス = name.replace("_Chunk", "")+".tscn"
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		show()
		デバッグ(false)
		処理有無制御(true)
		


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		処理有無制御(false)
		デバッグ(true)
		hide()



func 処理有無制御(有無:bool)->void:
	for i in get_children():
		if i is MeshInstance3D:
			if 有無:
				i.process_mode=Node.PROCESS_MODE_INHERIT
			else:
				i.process_mode=Node.PROCESS_MODE_DISABLED


func デバッグ(ブール:bool)->void:
	for i in get_children():
		if i is MeshInstance3D:
			if ブール:
				i.material_override=マテリアル
			else:
				i.material_override=null
