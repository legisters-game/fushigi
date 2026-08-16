@icon("res://拡張リソース/アイコン/拡張ノード/モデル.png")
@tool
extends Node3D
class_name モデルクラス
@export var スキン:CompressedTexture2D
@export var メッシュ親:Node3D
@export var メッシュ親2:Node3D
@export var 顔:MeshInstance3D
@export var 表情データ:表情オブジェクト
@export var 顔ボーン:LookAtModifier3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not スキン:
		return
	for 暫定メッシュ:Node in メッシュ親.get_children():
		if 暫定メッシュ is MeshInstance3D:
			for インデックス:int in range(暫定メッシュ.mesh.get_surface_count()):
				#print("ds")
				var 元マテリアル:StandardMaterial3D=暫定メッシュ.mesh.surface_get_material(インデックス)
				var 新規マテリアル:StandardMaterial3D=元マテリアル.duplicate()
				新規マテリアル.albedo_texture=スキン
				暫定メッシュ.set_surface_override_material(インデックス,新規マテリアル)
	
	if メッシュ親2==null:return
	for 暫定メッシュ2:Node in メッシュ親2.get_children():
		if 暫定メッシュ2 is MeshInstance3D:
			for インデックス:int in range(暫定メッシュ2.mesh.get_surface_count()):
				#print("ds")
				var 元マテリアル:StandardMaterial3D=暫定メッシュ2.mesh.surface_get_material(インデックス)
				var 新規マテリアル:StandardMaterial3D=元マテリアル.duplicate()
				新規マテリアル.albedo_texture=スキン
				暫定メッシュ2.set_surface_override_material(インデックス,新規マテリアル)


func 表情切り替え(切り替え表情:表情オブジェクト.表情)->void:
	if not 顔 or not 表情データ or  not 顔.mesh:return
	var マテリアル:StandardMaterial3D=顔.mesh.surface_get_material(0)
	if not マテリアル:
		return
	var 上書きマテリアル:StandardMaterial3D=マテリアル.duplicate()
	if 表情データ.取得(切り替え表情):
		上書きマテリアル.albedo_texture=表情データ.取得(切り替え表情)
		顔.set_surface_override_material(0,上書きマテリアル)
