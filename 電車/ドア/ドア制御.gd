@tool
extends Node3D
class_name ドア制御
@export_tool_button("開く") var a=開く
@export_tool_button("閉じる")var b=閉じる
var 開くカウンター:int
var 閉じるカウンター:int
signal 全部開いた
signal 全部閉まった


func _ready() -> void:
	for i in get_children():
		if i is 電車_前ドア:
			i.閉まった.connect(閉まった)
			i.開いた.connect(開いた)
			
		
	await get_tree().create_timer(10).timeout
	開く()
	
func 開く()->void:
	開くカウンター=0
	for i in get_children():
		if i is 電車_前ドア:
			開くカウンター+=1
			i.開く()

func 閉じる()->void:
	閉じるカウンター=0
	for i in get_children():
		if i is 電車_前ドア:
			閉じるカウンター+=1
			i.閉まる()

func 開いた()->void:
	開くカウンター-=1
	if 開くカウンター==0:
		pass
		全部開いた.emit()

func 閉まった()->void:
	閉じるカウンター-=1
	if 閉じるカウンター==0:
		全部閉まった.emit()
