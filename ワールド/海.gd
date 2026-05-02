extends MeshInstance3D

@export var プレイヤー:エンティティ

func _physics_process(_delta: float) -> void:
	#wqueue_free()
	if プレイヤー:
		global_position.x=プレイヤー.global_position.x
		global_position.z=プレイヤー.global_position.z
