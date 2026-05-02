extends Node3D
class_name スケジュール管理クラス

@export var 全体スケジュール:Dictionary[NPC,NPCスケジューラ]
@export var 太陽:時間太陽
@export var メッセージボックス:メッセージボックスクラス
var ソート停止:Dictionary[NPC,Array]={}
enum NPC{キール,リュー,キング,ヒジキ,リッド,すね,リウス,ちゃいにー,いるか,ななし,かるかん,いきぱら,タック,リッター}

# Called when the node enters the scene tree for the first time.

func 目的地取得(対象: NPC) -> Dictionary[String, Variant]:
	var 返す辞書: Dictionary[String, Variant] = {"目的地": Vector3.ZERO, "強制到着": false}
	if not 全体スケジュール.has(対象):
		return 返す辞書

	var 現在時刻:float = 太陽.time
	
	# 1. 既存のソート停止（強制到着）状態の確認
	if ソート停止 and ソート停止.has(対象) and ソート停止[対象] and ソート停止[対象][0]:
		if ソート停止[対象][1] < 現在時刻:
			ソート停止[対象][0] = false
		else:
			return {"目的地": ソート停止[対象][2], "強制到着": true}

	var リスト: Array = 全体スケジュール[対象].スケジュールリスト
	
	# 2. 全予定の中から「現在の時間」に最も適したものを探す
	var 次の予定: セルスケジュール = null
	var 最小距離:float = 2.0 # 1.0より大きければ何でもよい
	
	for i:セルスケジュール in リスト:
		# 現在が期間内なら即座に決定
		var is_in_range:bool = false
		if i.開始時間 < i.終了時間: # 通常
			is_in_range = (現在時刻 >= i.開始時間 and 現在時刻 < i.終了時間)
		else: # 日またぎ
			is_in_range = (現在時刻 >= i.開始時間 or 現在時刻 < i.終了時間)
		
		if is_in_range:
			返す辞書["目的地"] = i.目的置
			返す辞書["強制到着"] = true
			ソート停止[対象] = [true, i.終了時間, i.目的置]
			return 返す辞書
			
		# 期間外の場合、「最も近い未来」を探す（距離計算）
		var 距離:float = i.開始時間 - 現在時刻
		if 距離 < 0: 距離 += 1.0 # ループ対応
		
		if 距離 < 最小距離:
			最小距離 = 距離
			次の予定 = i

	# 3. 予定が確定
	if 次の予定:
		返す辞書["目的地"] = 次の予定.目的置
		
	return 返す辞書
	
	
	
	
func メッセージ取得(対象: NPC) -> Array[セリフオブジェクト]:
	var 欲しいメッセージ:Array[セリフオブジェクト]
	#var 返す辞書: Dictionary[String, Variant] = {"目的地": Vector3.ZERO, "強制到着": false}
	if not 全体スケジュール.has(対象):
		return 欲しいメッセージ

	var 現在時刻:float = 太陽.time

	var リスト: Array = 全体スケジュール[対象].スケジュールリスト
	
	# 2. 全予定の中から「現在の時間」に最も適したものを探す
	var 次の予定: セルスケジュール = null
	var 最小距離:float = 2.0 # 1.0より大きければ何でもよい
	
	for i:セルスケジュール in リスト:
		# 現在が期間内なら即座に決定
		var is_in_range:bool = false
		if i.開始時間 < i.終了時間: # 通常
			is_in_range = (現在時刻 >= i.開始時間 and 現在時刻 < i.終了時間)
		else: # 日またぎ
			is_in_range = (現在時刻 >= i.開始時間 or 現在時刻 < i.終了時間)
		
		if is_in_range:
			欲しいメッセージ = i.セリフ
			次の予定=null
			return 欲しいメッセージ
		# 期間外の場合、「最も近い未来」を探す（距離計算）
		var 距離:float = i.開始時間 - 現在時刻
		if 距離 < 0: 距離 += 1.0 # ループ対応
		
		if 距離 < 最小距離:
			最小距離 = 距離
			次の予定 = i

	# 3. 予定が確定
	if 次の予定:
		欲しいメッセージ = 次の予定.セリフ
		return 欲しいメッセージ
	return 欲しいメッセージ
	#メッセージボックス.表示(NPC.find_key(対象),欲しいメッセージ)
