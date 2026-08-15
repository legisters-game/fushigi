@icon("res://拡張リソース/アイコン/拡張ノード/UI_時間.png")
extends Control
@export var 太陽:時間太陽



func _ready() -> void:
	var ラベル:Label=get_node("Label")
	var バー:HSlider=get_node("ProgressBar")
	while 太陽 and ラベル and バー:
		ラベル.text=str(int(太陽.現時間*1000))+"\n"+str(太陽.時間.keys()[太陽.いつ()])
		バー.value=太陽.現時間*1000
		await get_tree().create_timer(1).timeout
