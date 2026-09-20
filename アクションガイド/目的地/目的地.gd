@tool
extends Node3D


@onready var モデル:MeshInstance3D=$MeshInstance3D
@onready var レベル制御:レベル制御クラス=$"../../../"
var ターン:bool
@export var 無効:bool
var ミッション:ミッションデータ

func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint() and レベル制御 and not(レベル制御.ディメンション返し()==""or レベル制御.ディメンション返し()=="オープンワールド"):
		hide()
		return
	モデル.rotate_y(delta)
	if 無効:return
	if ターン:
		モデル.position.y=lerpf(モデル.position.y,1.2,delta*1.2)
		if モデル.position.y>=1:
			ターン=false
			切り替え()
	else:
		モデル.position.y=lerpf(モデル.position.y,-1.2,delta*1.2)
		if モデル.position.y<=-1:
			ターン=true
			切り替え()

func 切り替え()->void:
	無効=true
	await get_tree().create_timer(0.45).timeout
	無効=false


func 目的地更新(目的地:Vector3,追尾ミッション:ミッションデータ)->void:
	show()
	if get_tree().get_first_node_in_group("プレイヤー"):
		global_position=get_tree().get_first_node_in_group("プレイヤー").global_position
		global_position.y+=1
		await get_tree().create_timer(0.45).timeout
	ミッション=追尾ミッション
	var アニメーション:Tween=get_tree().create_tween()
	アニメーション.bind_node(self)
	アニメーション.tween_property(self,"global_position",目的地,5)
	アニメーション.set_ease(Tween.EASE_IN_OUT)
