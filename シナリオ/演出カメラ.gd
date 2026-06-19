@tool
extends Camera3D

@export var ターゲット:Array[Marker3D]
@export var ターゲット番号:int
@export var 切り替え時間:float
@export var イージング:float
var 切り替え中:bool
var 目的対象:int
var 動的目的位置:Vector3
var 移動開始時の位置:Vector3
var イージング補間用:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not ターゲット or ターゲット.is_empty():return
	if ターゲット.get(ターゲット番号)==null:
		ターゲット番号=0
	目的対象=ターゲット番号


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not ターゲット or ターゲット.is_empty():return
	
	if ターゲット.get(ターゲット番号)==null:
		ターゲット番号=0
	if typeof(ターゲット.get(ターゲット番号))==TYPE_NIL:
		#print(ターゲット.get(ターゲット番号))
		return
	if 目的対象!=ターゲット番号:
		切り替え中=true
		イージング補間用=0
		目的対象=ターゲット番号
		移動開始時の位置 = 動的目的位置 
		
	if 切り替え中:
		イージング補間用+=delta
		var 進捗率:float = clampf(イージング補間用 / 切り替え時間, 0.0, 1.0)
		進捗率 = ease(進捗率, イージング)
		
		
		動的目的位置=移動開始時の位置.lerp(ターゲット[ターゲット番号].global_position,進捗率)
		if 進捗率 >= 1.0:
			切り替え中=false
			イージング補間用=0
		#ease(-1,目的位置)
		#print(動的目的位置)
	else:
		#print("a")
		動的目的位置=ターゲット[ターゲット番号].global_position
	var diff:Vector3 = global_position - 動的目的位置
	if diff.length() > 0.01:
		var forward:Vector3 = diff.normalized()
		var right = Vector3.UP.cross(forward).normalized()
		var actual_up:Vector3 = forward.cross(right).normalized()
		global_basis = Basis(right, actual_up, forward)
		
