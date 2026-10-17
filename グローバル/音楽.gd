extends AudioStreamPlayer

@onready var サブ:AudioStreamPlayer=$AudioStreamPlayer

@onready var 有効:AudioStreamPlayer=self
var ボリューム定数:int=-22
var チェンジ中:bool
func _ready() -> void:
	volume_db=ボリューム定数
	サブ.volume_db=ボリューム定数

func 再生()->void:
	有効.play()

func チェンジ(音楽:AudioStream,切り替え時間:float=1)->void:
	if チェンジ:return
	var アニメーション:Tween=get_tree().create_tween()
	チェンジ中=true
	if 有効 == self:
		サブ.stream=音楽
		アニメーション.tween_property(有効,"volume_db",-80.0,切り替え時間)
		await アニメーション.finished
		停止()
		サブ.volume_db=ボリューム定数
		サブ.play()
		有効=サブ
	else:
		self.stream=音楽
		アニメーション.tween_property(有効,"volume_db",-80.0,切り替え時間)
		await アニメーション.finished
		停止()
		self.volume_db=ボリューム定数
		self.play()
		有効=self
	チェンジ中=false

func 停止()->void:
	有効.stop()
