@tool
class_name 透明壁コリジョン
extends CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var シェイプ:BoxShape3D=shape
	シェイプ.size=Vector3(1,0.994,1)
	debug_color=Color(0.96, 0.0, 0.304, 0.42)
