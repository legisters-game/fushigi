extends StaticBody3D
enum フラグ{通常,ミッション,ミッション条件}

@export var フラグの種類:フラグ
@export var 調べるフラグ名:String
@export var フラグがある場合:bool
@export var 消去フラグ:String
@export var 無効時解放:bool

func _ready() -> void:
	if 判断(消去フラグ):queue_free()
	if 無効時解放:
		if !判断(調べるフラグ名):
			queue_free()

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
