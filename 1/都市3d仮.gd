@tool
extends Node3D

@export_flags("Fire", "Water", "Earth", "Wind","ds") var spell_elements: = 0
@export_tool_button("全体表示", "Callable") var hello_action = okq
var 全体表示:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return
	for i in get_children():
		print(i.name)
	#process_mode=Node.PROCESS_MODE_DISABLED

func okq():
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
