@tool
extends Node3D
class_name レベル基礎クラス
##レベル移動してくるとき、どの位置にテレポートするか番号で指定できる。
@export var テレポート先:Array[Marker3D]
##このレベルに移動すると、自動でカメラが切り替わる。
@export var カメラ:Camera3D
##ひとつのレベルを複数のエリアで使用する場合、選択された階層以外を解放する。
##階層の一番上のノードを配列に割り当てる必要がある。
@export var 階層処理切り替え用ノード:Array[Node3D]
@export var NPC用オブジェクト:Array[StaticBody3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if カメラ:
		カメラ.make_current()
	position.y=-50
	


func 階層有効(階層番号:int)->void:
	if not 階層処理切り替え用ノード:return
	var ノード:Node3D=階層処理切り替え用ノード.get(階層番号)
	if ノード:
		ノード.process_mode=Node.PROCESS_MODE_INHERIT
	else:
		ノード=階層処理切り替え用ノード.get(0)
		if ノード:ノード.process_mode=Node.PROCESS_MODE_INHERIT
	
	if ノード:
		for i:Node3D in 階層処理切り替え用ノード:
			if i!=ノード:i.queue_free() 
	
