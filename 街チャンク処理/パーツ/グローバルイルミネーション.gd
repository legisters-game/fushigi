extends VoxelGI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
	if data:
		data.propagation=1
		#call_deferred("bake")
	else:
		print("なし",get_parent().name)
	
