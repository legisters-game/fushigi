extends Control
class_name メッセージボックスクラス
@export var メッセージラベル:Label
@export var 名前:Label
@export var 選択肢1:選択肢ボタンクラス
@export var 選択肢2:選択肢ボタンクラス
@export var 選択肢3:選択肢ボタンクラス
@export var プレイヤー:プレイヤークラス
@export var 追尾カメラ:追尾カメラクラス
var 相手NPC:NPCクラス
var 中断:bool
signal ログ進行(int)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	メッセージラベル.text=""
	名前.text=""
	get_node("テクスチャ枠/メッセージ枠/ボタン").text=キーマッピング.キー文字[キーマッピング.インプットイベントから入力イベントを文字で返す(InputMap.action_get_events("メッセージ進行")[0])]
	
	選択肢1.入力キー指定(キーマッピング.キー文字[キーマッピング.インプットイベントから入力イベントを文字で返す(InputMap.action_get_events("選択肢1")[0])])
	選択肢2.入力キー指定(キーマッピング.キー文字[キーマッピング.インプットイベントから入力イベントを文字で返す(InputMap.action_get_events("選択肢2")[0])])
	選択肢3.入力キー指定(キーマッピング.キー文字[キーマッピング.インプットイベントから入力イベントを文字で返す(InputMap.action_get_events("選択肢3")[0])])
	

func 表示(誰:String,メッセージ内容:Array[セリフオブジェクト])->void:
	show()
	名前.text=誰
	#外部でtrueにして強制的にログを終了させる
	中断=false
	if 相手NPC and 追尾カメラ:
		追尾カメラ.会話中視点角ロック(true,相手NPC)
	if 相手NPC.アクションポイント:
		相手NPC.アクションポイント.hide()
	for i:セリフオブジェクト in メッセージ内容:
		if 中断:break
		メッセージラベル.text=i.セリフ
		if 相手NPC:
			相手NPC.表情切り替え(i.表情)
			
		if i is セリフ分岐オブジェクト:
			await 分岐回帰ログ表示(i)
		elif i is ファイナルセリフオブジェクト:
			中断=true
			await ログ進行
		else:
			await ログ進行
	if 相手NPC:
		相手NPC.表情切り替え(表情オブジェクト.表情.通常)
		相手NPC.会話前回転戻し()
		相手NPC.停止=false
	相手NPC=null
	プレイヤー.移動操作ロック=false
	if 追尾カメラ:
		追尾カメラ.会話中視点角ロック(false)
	hide()


func 分岐回帰ログ表示(分岐セリフ:セリフ分岐オブジェクト)->void:
	match 分岐セリフ.選択肢.size():
		1:
			選択肢1.出現(分岐セリフ.選択肢[0])
			
		2:
			選択肢1.出現(分岐セリフ.選択肢[0])
			選択肢2.出現(分岐セリフ.選択肢[1])
		3:
			選択肢1.出現(分岐セリフ.選択肢[0])
			選択肢2.出現(分岐セリフ.選択肢[1])
			選択肢3.出現(分岐セリフ.選択肢[2])
	var 選択インデックス:int
	while true:
		選択インデックス=await ログ進行
		if 選択インデックス==0 and 分岐セリフ.選択1セリフ and not 分岐セリフ.選択1セリフ.is_empty() and  分岐セリフ.選択1セリフ[0]:
			break
		elif 選択インデックス==1 and 分岐セリフ.選択2セリフ and not 分岐セリフ.選択2セリフ.is_empty() and  分岐セリフ.選択2セリフ[0]:
			break
		elif 選択インデックス==2 and 分岐セリフ.選択3セリフ and not 分岐セリフ.選択3セリフ.is_empty() and  分岐セリフ.選択3セリフ[0]:
			break
		elif not 分岐セリフ.選択1セリフ:
			選択インデックス=99
			break
	
	match 選択インデックス:
		0:
			for i:セリフオブジェクト in 分岐セリフ.選択1セリフ:
				if 中断:break
				メッセージラベル.text=i.セリフ
				if 相手NPC:
					相手NPC.表情切り替え(i.表情)
				if i is セリフ分岐オブジェクト:
					await 分岐回帰ログ表示(i)
				elif i is ファイナルセリフオブジェクト:
					中断=true
					await ログ進行
				else:
					await ログ進行
		1:
			for i:セリフオブジェクト in 分岐セリフ.選択2セリフ:
				if 中断:break
				メッセージラベル.text=i.セリフ
				if 相手NPC:
					相手NPC.表情切り替え(i.表情)
				if i is セリフ分岐オブジェクト:
					await 分岐回帰ログ表示(i)
				elif i is ファイナルセリフオブジェクト:
					中断=true
					await ログ進行
				else:
					await ログ進行
		2:
			for i:セリフオブジェクト in 分岐セリフ.選択3セリフ:
				if 中断:break
				メッセージラベル.text=i.セリフ
				if 相手NPC:
					相手NPC.表情切り替え(i.表情)
				if i is セリフ分岐オブジェクト:
					await 分岐回帰ログ表示(i)
				elif i is ファイナルセリフオブジェクト:
					中断=true
					await ログ進行
				else:
					await ログ進行
		
		

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("メッセージ進行") or Input.is_action_just_released("選択肢1"):
		ログ進行.emit(0)
	elif Input.is_action_just_released("選択肢2"):
		ログ進行.emit(1)
	elif Input.is_action_just_released("選択肢3"):
		ログ進行.emit(2)


func _on_ログ進行(_int: Variant) -> void:
	for i:Node in get_node("VBoxContainer").get_children():
		if i is Control:
			i.hide()


func _on_選択肢ボタン1_pressed() -> void:
	ログ進行.emit(0)


func _on_選択肢ボタン2_pressed() -> void:
	ログ進行.emit(1)


func _on_選択肢ボタン3_pressed() -> void:
	ログ進行.emit(2)
