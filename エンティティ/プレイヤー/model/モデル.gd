@tool
extends Node3D
@export var スキン:CompressedTexture2D
@export var メッシュ親:Node3D
@export var メッシュ親2:Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not スキン:
		return
	for i in メッシュ親.get_children():
		if i is MeshInstance3D:
			for e:int in range(i.mesh.get_surface_count()):
				print("ds")
				var 元マテリアル:StandardMaterial3D=i.mesh.surface_get_material(e)
				var 新規マテリアル:StandardMaterial3D=元マテリアル.duplicate()
				新規マテリアル.albedo_texture=スキン
				i.set_surface_override_material(e,新規マテリアル)
	
	for i in メッシュ親2.get_children():
		if i is MeshInstance3D:
			for e:int in range(i.mesh.get_surface_count()):
				print("ds")
				var 元マテリアル:StandardMaterial3D=i.mesh.surface_get_material(e)
				var 新規マテリアル:StandardMaterial3D=元マテリアル.duplicate()
				新規マテリアル.albedo_texture=スキン
				i.set_surface_override_material(e,新規マテリアル)
