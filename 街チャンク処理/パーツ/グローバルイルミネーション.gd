extends VoxelGI

@export var 例外:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint() and !例外:
		queue_free()
	if data:
		data.propagation=1
		#call_deferred("bake")
	else:
		print("なし",get_parent().name)
	
