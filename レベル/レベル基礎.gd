extends Node3D
class_name レベル基礎クラス
@export var テレポート先:Array[Marker3D]
@export var カメラ:Camera3D
@export var 階層処理切り替え用ノード:Array[Node3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if カメラ:
		カメラ.make_current()
	


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
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
