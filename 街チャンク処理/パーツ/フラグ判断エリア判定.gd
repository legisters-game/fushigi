extends Area3D
class_name フラグ判断エリア判定クラス
enum フラグ{通常,ミッション,ミッション条件}

@export var フラグの種類:フラグ
@export var 調べるフラグ名:String
@export var フラグがある場合:bool
@export var 消去フラグ:String
@export var 無効時解放:bool


@export_file_path("*.tscn") var 演出シーン:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if データロガー.フラグあるか(消去フラグ):queue_free()
	if 無効時解放:
		if !判断(調べるフラグ名):queue_free()
			


func 判断(フラグ名:String)->bool:
	if フラグ名=="":return false
	match フラグの種類:
		フラグ.通常:
			if フラグがある場合:
				return データロガー.フラグあるか(フラグ名)
			else:
				return !データロガー.フラグあるか(フラグ名)
		フラグ.ミッション:
			if フラグがある場合:
				return データロガー.config.has_section_key("ミッションフラグ",フラグ名)
			else:
				return !データロガー.config.has_section_key("ミッションフラグ",フラグ名)
		フラグ.ミッション条件:
			if フラグがある場合:
				return データロガー.config.has_section_key("ミッション条件フラグ",フラグ名)
			else:
				return !データロガー.config.has_section_key("ミッション条件フラグ",フラグ名)
	return false



func _on_body_entered(body: Node3D) -> void:
	if body is プレイヤークラス and 判断(調べるフラグ名):
		if 演出シーン:
			#body as プレイヤークラス
			if body.重力無効 and body.移動操作ロック or get_tree().get_first_node_in_group("全体制御").get_node("演出ルート").get_child_count()!=0:return
			get_tree().get_first_node_in_group("全体制御").シナリオ演出実行(演出シーン)
