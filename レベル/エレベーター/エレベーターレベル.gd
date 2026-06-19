extends レベル基礎クラス
class_name エレベーターレベルクラス
@onready var 表示板:Label3D=$Label3D
@onready var 出口:レベルゲート=$"レベルゲート"
@onready var GUI:Control=$Control

@export_file_path("*.tscn") var 階層:Array[String]
@export_range(0,1000) var アクセス番号:Array[int]
@export var 階層名:Array[String]
@export var ボタンシーン:PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	var 新規配列:Array[String]
	var 新規番号配列:Array[int]
	var 新規階層名配列:Array[String]
	var インデックス:int=0
	for i:String in 階層:
		if i and i!="":
			新規配列.append(i)
			if アクセス番号.size()-1>=インデックス:
				新規番号配列.append(アクセス番号[インデックス])
			else:
				新規番号配列.append(0)
				
			if 階層名.size()-1>=インデックス:
				新規階層名配列.append(階層名[インデックス])
			else:
				新規階層名配列.append("")
		インデックス+=1
	階層=新規配列
	アクセス番号=新規番号配列
	階層名=新規階層名配列
	
	表示板.初期化(2,階層.size()+1)
	インデックス=0
	for i:String in 階層名:
		var ボタンインスタンス:エレベーターボタンGUI=ボタンシーン.instantiate()
		ボタンインスタンス.初期化(インデックス,self,i)
		GUI.get_node("HFlowContainer/VBoxContainer").add_child(ボタンインスタンス)
		インデックス+=1
	
	
	#出口.アクセスレベル=
	


func _exit_tree() -> void:
	データロガー.ディメンションセーブロック=false

func 初期化(現階:int)->void:
	表示板.現状=現階
	表示板.更新()
	出口.アクセスレベル=階層[現階-1]
	出口.アクセス番号=アクセス番号[現階-1]
	出口.階層=現階
	

func 階層選択(階層インデックス:int)->void:
	if 階層インデックス+1==出口.階層:
		GUI.hide()
		get_tree().get_first_node_in_group("UI").show()
		return
	
	if カメラ and カメラ.has_method("set_elevator_moving"):
		カメラ.set_elevator_moving(true)
	
	await get_tree().create_timer(0.2+0.75*abs((階層インデックス+1-出口.階層))).timeout
	if カメラ and カメラ.has_method("set_elevator_moving"):
		カメラ.set_elevator_moving(false)
	初期化(階層インデックス+1)
	GUI.hide()
	get_tree().get_first_node_in_group("UI").show()
	
