@tool
extends MeshInstance3D
class_name 演出チャンク指定ツール
@export_tool_button("演出時のチャンクとして追加") var 演出自のチャンク=チャンク追加
var 演出基盤:演出基盤クラス

func チャンク追加()->void:
	if not 演出基盤:return
	var 自身の名前:String="res://街チャンク処理/街シーン/"+name+".tscn"
	if not ResourceLoader.exists(自身の名前):
		printerr("これはシステム的なエラーではありませんが、チャンクのシーンが保存されていません。\n表示させたいチャンクは既にシーンとして保存されている必要があります。\n"+自身の名前)
		return
	var _UID:String=ResourceUID.id_to_text(ResourceLoader.get_resource_uid(自身の名前))
	#ResourceUID.id_to_text
	if not 演出基盤.表示チャンク.has(自身の名前):
		演出基盤.表示チャンク.append(自身の名前)
		print("追加")
