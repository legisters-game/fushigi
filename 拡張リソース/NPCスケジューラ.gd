@tool
class_name NPCスケジューラ extends Resource

@export_tool_button("整合性チェック","DampedSpringJoint2D") var ボタン1:Callable=asチェック
@export var スケジュールリスト: Array[セルスケジュール]

func asチェック(警告のみ:bool=true) -> void:
	if スケジュールリスト.is_empty():
		return

	# 1. データのソート（開始時間順）
	スケジュールリスト.sort_custom(func(a, b)->bool: return a.開始時間 < b.開始時間)

	var 整理済み: Array[セルスケジュール] = []
	
	for i:int in range(スケジュールリスト.size()):
		var 現在:セルスケジュール = スケジュールリスト[i]
		
		# 2. 重複チェック
		var is_duplicate:bool = false
		for 既存:セルスケジュール in 整理済み:
			if 範囲が重なっているか(現在, 既存):
				if 警告のみ:
					var スケジュール名:String="名前無し"
					if 現在.名前 and 現在.名前!="":
						スケジュール名=現在.名前
					var 既存スケジュール名:String="名前無し"
					if 既存.名前 and 既存.名前!="":
						既存スケジュール名=既存.名前
					print_rich("[color=yellow]重複検出: [「",スケジュール名,"」", 現在.開始時間, "-", 現在.終了時間, "] は [「",既存スケジュール名,"」", 既存.開始時間, "-", 既存.終了時間, "] と重複しています。アクセスナンバー[",i,"][/color]")
				is_duplicate = true
				break
		
		if not is_duplicate:
			整理済み.append(現在)
	if not 警告のみ:
		スケジュールリスト = 整理済み
	else:
		print("整合性チェック完了。")

# 範囲の重なり判定（0.0～1.0のループと日またぎを考慮）
func 範囲が重なっているか(a: セルスケジュール, b: セルスケジュール) -> bool:
	# 範囲A: [a.開始, a.終了], 範囲B: [b.開始, b.終了]
	# 日またぎを考慮した衝突判定 (ド・モルガンの法則の逆)
	# 衝突しない条件: (a.終了 <= b.開始) OR (a.開始 >= b.終了)
	# ただし、日またぎ(start > end)の場合は、[start, 1.0] と [0.0, end] に分割して考える必要がある
	
	var ranges_a:Array[Array] = get_normalized_ranges(a)
	var ranges_b:Array[Array] = get_normalized_ranges(b)
	
	for ra:Array[float] in ranges_a:
		for rb:Array[float] in ranges_b:
			# 通常の範囲重なりチェック (開始時刻同士で比較)
			if max(ra[0], rb[0]) < min(ra[1], rb[1]):
				return true
	return false

# 日またぎを考慮して、常に通常範囲の配列として返す
func get_normalized_ranges(s: セルスケジュール) -> Array[Array]:
	if s.開始時間 < s.終了時間:
		return [[s.開始時間, s.終了時間]]
	else:
		return [[s.開始時間, 1.0], [0.0, s.終了時間]]



func _init() -> void:
	if Engine.is_editor_hint():
		pass
		#asチェック(false)
