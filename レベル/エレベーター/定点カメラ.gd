extends Camera3D

# 揺れの強さ（パタメータを調整して好みの揺れにしてください）
@export var shake_intensity: float = 0.05
# 揺れるスピード（大きいほど細かく激しく揺れます）
@export var shake_speed: float = 25.0

# エレベーターが移動中かどうかのフラグ
var is_elevator_moving: bool = false
var time_passed: float = 0.0

func _process(delta: float) -> void:
	if is_elevator_moving:
		# 時間を進める
		time_passed += delta * shake_speed
		
		# サイン波とノイズ（乱数）を組み合わせて不規則なガタゴト感を出す
		# h_offset と v_offset の周期をずらすことで斜めの動きを作ります
		h_offset = sin(time_passed) * shake_intensity + randf_range(-0.01, 0.01)
		v_offset = cos(time_passed * 1.2) * shake_intensity + randf_range(-0.01, 0.01)
	else:
		# エレベーターが止まったら、徐々に元の位置（0）に戻す
		h_offset = move_toward(h_offset, 0.0, delta * 0.5)
		v_offset = move_toward(v_offset, 0.0, delta * 0.5)

# 他のスクリプト（ボタンやエレベーター本体）からこの関数を呼んで揺れを制御します
func set_elevator_moving(moving: bool) -> void:
	is_elevator_moving = moving
