extends NPCクラス
@export var 表示中ミッションフラグ:String


func _ready() -> void:
	if not データロガー.config.has_section_key("ミッションフラグ",表示中ミッションフラグ):
		queue_free()
	super()
