extends Control
@export var 太陽:時間太陽


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	while 太陽:
		get_node("Label").text=str(int(太陽.time*1000))+"\n"+str(太陽.時間.keys()[太陽.いつ()])
		get_node("ProgressBar").value=太陽.time*1000
		await get_tree().create_timer(1).timeout
