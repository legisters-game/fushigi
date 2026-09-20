
extends Node2D


# =========================================================
# ノード
# =========================================================

@onready var firework_manager: Node2D = $FireworkManager

@onready var finale_button: Button = $FinaleButton


# =========================================================
# フィナーレボタンを表示するまでの時間
# =========================================================

const BUTTON_SHOW_DELAY: float = 5.0


# =========================================================
# 初期化
# =========================================================

func _ready() -> void:

	# 最初はボタンを非表示
	finale_button.visible = false

	# ボタンの文字を最初から「フィナーレ」にする
	finale_button.text = "フィナーレ"

	# ボタンを押したときの処理を接続
	finale_button.pressed.connect(
		_on_finale_button_pressed
	)

	# 5秒待つ
	await get_tree().create_timer(
		BUTTON_SHOW_DELAY
	).timeout

	# 「フィナーレ」と表示してからボタンを出す
	finale_button.text = "フィナーレ"
	finale_button.visible = true


# =========================================================
# フィナーレボタン
# =========================================================

func _on_finale_button_pressed() -> void:

	# フィナーレ開始
	firework_manager.start_finale()

	# ボタンを押せなくする
	finale_button.disabled = true

	# ボタンの文字を変更
	finale_button.text = "フィナーレ中..."

	# フィナーレ終了まで待つ
	while not firework_manager.finale_finished:

		await get_tree().process_frame

	# フィナーレ終了
	finale_button.disabled = false

	# 再び「フィナーレ」に戻す
	finale_button.text = "フィナーレ"
	finale_button.visible = false
