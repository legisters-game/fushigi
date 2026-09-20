@icon("res://拡張リソース/アイコン/拡張ノード/街ルート.png")
@tool
extends Node3D
class_name オープンワールド管理クラス
@export_flags("Fire", "Water", "Earth", "Wind","ds") var spell_elements: = 0
@export_tool_button("全体表示", "Callable") var hello_action = okq
var 全体表示:bool





func okq()->void:
	if not 全体表示:
		全体表示=true
		for i:Node in get_children():
			if i is チャンク管理クラス:
				i.強制表示()
	else:
		全体表示=false
		for i:Node in get_children():
			if i is チャンク管理クラス:
				i.hide()
