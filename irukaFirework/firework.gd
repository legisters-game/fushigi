extends Node2D


# =========================================================
# 基本設定
# =========================================================

const GRAVITY: float = 145.0

# 通常の火花が残す軌跡
const NORMAL_TRAIL_POINTS: int = 3

# 柳系が残す軌跡
const LONG_TRAIL_POINTS: int = 5


# =========================================================
# 花火の種類
# =========================================================

enum FireworkType {
	CHRYSANTHEMUM,
	PEONY,
	WILLOW,
	SMALL_CHRYSANTHEMUM,
	CROWN,
	GOLD_WILLOW,
	DOUBLE_BURST,
	CHAOTIC,
	DOUBLE_COLOR,
	MINI_BURST,
	BIG_BURST,
	STAR_MINE
}


# =========================================================
# ロケット
# =========================================================

var rocket_position: Vector2 = Vector2.ZERO

var rocket_velocity: Vector2 = Vector2.ZERO

var target_height: float = 250.0


# =========================================================
# 状態
# =========================================================

var exploded: bool = false

var finished: bool = false


# =========================================================
# 火花
# =========================================================

var sparks: Array[Dictionary] = []


# =========================================================
# 色
# =========================================================

var firework_color: Color = Color.WHITE

var secondary_color: Color = Color.WHITE


# =========================================================
# 大きさ
# =========================================================

var firework_scale: float = 1.0


# =========================================================
# 種類
# =========================================================

var firework_type: int = 0


# =========================================================
# 爆発フラッシュ
# =========================================================

var flash_time: float = 0.0


# =========================================================
# 色一覧
# =========================================================

var colors: Array[Color] = [

	Color(1.0, 0.05, 0.05),

	Color(1.0, 0.18, 0.03),

	Color(1.0, 0.45, 0.02),

	Color(1.0, 0.85, 0.05),

	Color(0.15, 1.0, 0.2),

	Color(0.02, 1.0, 0.65),

	Color(0.02, 0.45, 1.0),

	Color(0.15, 0.25, 1.0),

	Color(0.55, 0.1, 1.0),

	Color(1.0, 0.1, 0.65),

	Color(1.0, 0.65, 0.15),

	Color(1.0, 0.95, 0.65)

]


# =========================================================
# 初期化
# =========================================================

func _ready() -> void:

	prepare_firework()

	queue_redraw()


# =========================================================
# 花火準備
# =========================================================

func prepare_firework() -> void:

	exploded = false

	finished = false

	sparks.clear()


	# -----------------------------------------------------
	# 打ち上げ位置
	# -----------------------------------------------------

	rocket_position = Vector2(

		randf_range(
			70.0,
			1130.0
		),

		690.0

	)


	# -----------------------------------------------------
	# 打ち上げ速度
	# -----------------------------------------------------

	rocket_velocity = Vector2(

		randf_range(
			-15.0,
			15.0
		),

		-randf_range(
			470.0,
			580.0
		)

	)


	# -----------------------------------------------------
	# 爆発高度
	# -----------------------------------------------------

	target_height = randf_range(

		150.0,

		370.0

	)


	# -----------------------------------------------------
	# 大きさ
	# -----------------------------------------------------

	firework_scale = randf_range(

		0.78,

		1.28

	)


	# -----------------------------------------------------
	# 花火種類
	# -----------------------------------------------------

	firework_type = randi_range(

		0,

		11

	)


	# -----------------------------------------------------
	# 色
	# -----------------------------------------------------

	firework_color = colors.pick_random()

	secondary_color = colors.pick_random()


	while secondary_color == firework_color:

		secondary_color = colors.pick_random()


# =========================================================
# メイン更新
# =========================================================

func _process(delta: float) -> void:

	if finished:

		return


	if not exploded:

		update_rocket(delta)

	else:

		update_sparks(delta)

		if flash_time > 0.0:

			flash_time -= delta


	queue_redraw()


# =========================================================
# ロケット更新
# =========================================================

func update_rocket(delta: float) -> void:

	# -----------------------------------------------------
	# 重力
	# -----------------------------------------------------

	rocket_velocity.y += (

		GRAVITY
		* 0.12
		* delta

	)


	# -----------------------------------------------------
	# 少し横に揺れる
	# -----------------------------------------------------

	rocket_velocity.x += (

		sin(
			Time.get_ticks_msec()
			* 0.002
		)
		* 2.0
		* delta

	)


	# -----------------------------------------------------
	# 移動
	# -----------------------------------------------------

	rocket_position += (

		rocket_velocity
		* delta

	)


	# -----------------------------------------------------
	# 爆発判定
	# -----------------------------------------------------

	if rocket_velocity.y >= 0.0 \
	or rocket_position.y <= target_height:

		explode()


# =========================================================
# 爆発
# =========================================================

func explode() -> void:

	if exploded:

		return


	exploded = true

	flash_time = 0.13


	match firework_type:

		FireworkType.CHRYSANTHEMUM:

			create_chrysanthemum()


		FireworkType.PEONY:

			create_peony()


		FireworkType.WILLOW:

			create_willow()


		FireworkType.SMALL_CHRYSANTHEMUM:

			create_small_chrysanthemum()


		FireworkType.CROWN:

			create_crown()


		FireworkType.GOLD_WILLOW:

			create_gold_willow()


		FireworkType.DOUBLE_BURST:

			create_double_burst()


		FireworkType.CHAOTIC:

			create_chaotic()


		FireworkType.DOUBLE_COLOR:

			create_double_color()


		FireworkType.MINI_BURST:

			create_mini_burst()


		FireworkType.BIG_BURST:

			create_big_burst()


		FireworkType.STAR_MINE:

			create_star_mine()


# =========================================================
# 火花追加
# =========================================================

func add_spark(
	velocity: Vector2,
	life: float,
	gravity_multiplier: float,
	color: Color,
	size: float = 2.0,
	trail_points: int = NORMAL_TRAIL_POINTS
) -> void:

	var initial_trail: Array[Vector2] = []

	initial_trail.append(
		rocket_position
	)


	var spark: Dictionary = {

		"position":
			rocket_position,

		"velocity":
			velocity,

		"life":
			life,

		"max_life":
			life,

		"gravity":
			gravity_multiplier,

		"color":
			color,

		"size":
			size,

		"trail":
			initial_trail,

		"trail_points":
			trail_points

	}


	sparks.append(spark)


# =========================================================
# ① 菊
# =========================================================

func create_chrysanthemum() -> void:

	var count: int = randi_range(

		75,

		105

	)


	var base_speed: float = (

		randf_range(

			230.0,

			310.0

		)

		* firework_scale

	)


	for i: int in range(count):

		var angle: float = (

			TAU
			* float(i)
			/ float(count)

		)


		angle += randf_range(

			-0.10,

			0.10

		)


		var speed: float = (

			base_speed
			* randf_range(
				0.78,
				1.18
			)

		)


		var velocity: Vector2 = (

			Vector2.from_angle(angle)
			* speed

		)


		velocity.x += randf_range(

			-8.0,

			8.0

		)


		add_spark(

			velocity,

			randf_range(
				1.45,
				2.0
			),

			0.95,

			firework_color,

			randf_range(
				1.5,
				2.2
			),

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ② 牡丹
# =========================================================

func create_peony() -> void:

	var count: int = randi_range(

		95,

		130

	)


	for i: int in range(count):

		var angle: float = (

			randf()
			* TAU

		)


		var speed: float = (

			randf_range(
				145.0,
				290.0
			)
			* firework_scale

		)


		var velocity: Vector2 = (

			Vector2.from_angle(angle)
			* speed

		)


		add_spark(

			velocity,

			randf_range(
				1.05,
				1.65
			),

			0.95,

			firework_color,

			randf_range(
				1.8,
				2.5
			),

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ③ 柳
# =========================================================

func create_willow() -> void:

	var count: int = randi_range(

		65,

		85

	)


	for i: int in range(count):

		var angle: float = (

			TAU
			* float(i)
			/ float(count)

		)


		angle += randf_range(

			-0.18,

			0.18

		)


		var speed: float = (

			randf_range(
				140.0,
				225.0
			)
			* firework_scale

		)


		var velocity: Vector2 = (

			Vector2.from_angle(angle)
			* speed

		)


		# -------------------------------------------------
		# 下方向へ少し流す
		# -------------------------------------------------

		velocity.y += randf_range(

			10.0,

			60.0

		)


		add_spark(

			velocity,

			randf_range(
				3.5,
				5.0
			),

			1.8,

			firework_color,

			randf_range(
				1.3,
				1.9
			),

			LONG_TRAIL_POINTS

		)


# =========================================================
# ④ 小菊
# =========================================================

func create_small_chrysanthemum() -> void:

	var count: int = randi_range(

		45,

		65

	)


	for i: int in range(count):

		var angle: float = (

			TAU
			* float(i)
			/ float(count)

		)


		angle += randf_range(

			-0.18,

			0.18

		)


		add_spark(

			Vector2.from_angle(angle)
			* randf_range(
				115.0,
				190.0
			),

			randf_range(
				0.85,
				1.35
			),

			1.0,

			firework_color,

			1.6,

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ⑤ 冠菊
# =========================================================

func create_crown() -> void:

	var count: int = randi_range(

		65,

		90

	)


	for i: int in range(count):

		var angle: float = (

			TAU
			* float(i)
			/ float(count)

		)


		angle += randf_range(

			-0.14,

			0.14

		)


		var velocity: Vector2 = (

			Vector2.from_angle(angle)
			* randf_range(
				160.0,
				270.0
			)

		)


		velocity.y += randf_range(

			20.0,

			95.0

		)


		add_spark(

			velocity,

			randf_range(
				1.9,
				3.0
			),

			1.35,

			firework_color,

			randf_range(
				1.4,
				2.0
			),

			LONG_TRAIL_POINTS

		)


# =========================================================
# ⑥ 金柳
# =========================================================

func create_gold_willow() -> void:

	var count: int = randi_range(

		65,

		90

	)


	var gold: Color = Color(

		1.0,

		0.72,

		0.18

	)


	for i: int in range(count):

		var angle: float = (

			randf()
			* TAU

		)


		var velocity: Vector2 = (

			Vector2.from_angle(angle)
			* randf_range(
				145.0,
				240.0
			)

		)


		velocity.y += randf_range(

			0.0,

			50.0

		)


		add_spark(

			velocity,

			randf_range(
				3.0,
				4.3
			),

			1.75,

			gold,

			randf_range(
				1.4,
				2.0
			),

			LONG_TRAIL_POINTS

		)


# =========================================================
# ⑦ 二段咲き
# =========================================================

func create_double_burst() -> void:

	# -----------------------------------------------------
	# 外側
	# -----------------------------------------------------

	var outer_count: int = 45


	for i: int in range(outer_count):

		var angle: float = (

			randf()
			* TAU

		)


		add_spark(

			Vector2.from_angle(angle)
			* randf_range(
				190.0,
				270.0
			),

			randf_range(
				1.5,
				2.2
			),

			1.0,

			firework_color,

			1.7,

			NORMAL_TRAIL_POINTS

		)


	# -----------------------------------------------------
	# 内側
	# -----------------------------------------------------

	var inner_count: int = 30


	for i: int in range(inner_count):

		var angle: float = (

			randf()
			* TAU

		)


		add_spark(

			Vector2.from_angle(angle)
			* randf_range(
				80.0,
				140.0
			),

			randf_range(
				0.9,
				1.35
			),

			1.0,

			secondary_color,

			2.0,

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ⑧ 乱れ咲き
# =========================================================

func create_chaotic() -> void:

	var count: int = randi_range(

		70,

		105

	)


	for i: int in range(count):

		var angle: float = (

			randf()
			* TAU

		)


		var velocity: Vector2 = (

			Vector2.from_angle(angle)
			* randf_range(
				90.0,
				300.0
			)

		)


		velocity.x += randf_range(

			-45.0,

			45.0

		)


		velocity.y += randf_range(

			-30.0,

			70.0

		)


		add_spark(

			velocity,

			randf_range(
				0.9,
				2.25
			),

			randf_range(
				0.85,
				1.35
			),

			firework_color,

			randf_range(
				1.3,
				2.1
			),

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ⑨ 二色咲き
# =========================================================

func create_double_color() -> void:

	var count: int = randi_range(

		75,

		105

	)


	for i: int in range(count):

		var angle: float = (

			TAU
			* float(i)
			/ float(count)

		)


		angle += randf_range(

			-0.12,

			0.12

		)


		var color: Color


		if i % 2 == 0:

			color = firework_color

		else:

			color = secondary_color


		add_spark(

			Vector2.from_angle(angle)
			* randf_range(
				180.0,
				300.0
			),

			randf_range(
				1.3,
				2.0
			),

			1.0,

			color,

			randf_range(
				1.5,
				2.1
			),

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ⑩ ミニ爆発
# =========================================================

func create_mini_burst() -> void:

	var count: int = randi_range(

		30,

		45

	)


	for i: int in range(count):

		var angle: float = (

			randf()
			* TAU

		)


		add_spark(

			Vector2.from_angle(angle)
			* randf_range(
				80.0,
				175.0
			),

			randf_range(
				0.75,
				1.2
			),

			1.0,

			firework_color,

			1.5,

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ⑪ 大玉
# =========================================================

func create_big_burst() -> void:

	var count: int = randi_range(

		105,

		140

	)


	for i: int in range(count):

		var angle: float = (

			randf()
			* TAU

		)


		var velocity: Vector2 = (

			Vector2.from_angle(angle)
			* randf_range(
				220.0,
				370.0
			)
			* firework_scale

		)


		add_spark(

			velocity,

			randf_range(
				1.55,
				2.45
			),

			1.0,

			firework_color,

			randf_range(
				1.5,
				2.3
			),

			NORMAL_TRAIL_POINTS

		)


# =========================================================
# ⑫ スターマイン風
# =========================================================

func create_star_mine() -> void:

	var burst_count: int = randi_range(

		2,

		3

	)


	for b: int in range(burst_count):

		var center_offset: Vector2 = Vector2(

			randf_range(
				-60.0,
				60.0
			),

			randf_range(
				-60.0,
				60.0
			)

		)


		var count: int = randi_range(

			18,

			27

		)


		for i: int in range(count):

			var angle: float = (

				randf()
				* TAU

			)


			var velocity: Vector2 = (

				Vector2.from_angle(angle)
				* randf_range(
					90.0,
					195.0
				)

			)


			var initial_trail: Array[Vector2] = []

			initial_trail.append(

				rocket_position
				+ center_offset

			)


			var spark: Dictionary = {

				"position":
					rocket_position
					+ center_offset,

				"velocity":
					velocity,

				"life":
					randf_range(
						0.8,
						1.45
					),

				"max_life":
					1.45,

				"gravity":
					1.0,

				"color":
					firework_color,

				"size":
					1.6,

				"trail":
					initial_trail,

				"trail_points":
					NORMAL_TRAIL_POINTS

			}


			sparks.append(spark)


# =========================================================
# 火花更新
# =========================================================

func update_sparks(delta: float) -> void:

	var alive: bool = false


	for spark: Dictionary in sparks:

		var life: float = float(

			spark["life"]

		)


		if life <= 0.0:

			continue


		alive = true


		var position: Vector2 = (

			spark["position"]

		)


		var velocity: Vector2 = (

			spark["velocity"]

		)


		var gravity_multiplier: float = float(

			spark["gravity"]

		)


		# -------------------------------------------------
		# 軌跡配列
		# -------------------------------------------------

		var trail: Array[Vector2] = (

			spark["trail"]

		)


		var trail_points: int = int(

			spark["trail_points"]

		)


		# -------------------------------------------------
		# 現在位置を軌跡の先頭へ
		# -------------------------------------------------

		trail.push_front(position)


		# -------------------------------------------------
		# 軌跡が増えすぎないようにする
		# -------------------------------------------------

		while trail.size() > trail_points:

			trail.pop_back()


		# -------------------------------------------------
		# 重力
		# -------------------------------------------------

		velocity.y += (

			GRAVITY
			* gravity_multiplier
			* delta

		)


		# -------------------------------------------------
		# 空気抵抗
		# -------------------------------------------------

		velocity *= pow(

			0.988,

			delta * 60.0

		)


		# -------------------------------------------------
		# 少しだけ横に揺れる
		# -------------------------------------------------

		velocity.x += (

			sin(
				life * 5.0
			)
			* 3.0
			* delta

		)


		# -------------------------------------------------
		# 移動
		# -------------------------------------------------

		position += (

			velocity
			* delta

		)


		# -------------------------------------------------
		# 寿命
		# -------------------------------------------------

		life -= delta


		# -------------------------------------------------
		# 保存
		# -------------------------------------------------

		spark["position"] = position

		spark["velocity"] = velocity

		spark["life"] = life

		spark["trail"] = trail


	# -----------------------------------------------------
	# 全部消えた
	# -----------------------------------------------------

	if not alive:

		finished = true


# =========================================================
# 描画
# =========================================================

func _draw() -> void:

	# =====================================================
	# 打ち上げ中
	# =====================================================

	if not exploded:

		# -------------------------------------------------
		# ロケット本体
		# -------------------------------------------------

		draw_circle(

			rocket_position,

			3.0,

			Color.WHITE

		)


		# -------------------------------------------------
		# ロケットの光
		# -------------------------------------------------

		draw_circle(

			rocket_position,

			7.0,

			Color(

				firework_color.r,
				firework_color.g,
				firework_color.b,
				0.14

			)

		)


		# -------------------------------------------------
		# 打ち上げの尾
		# -------------------------------------------------

		draw_line(

			rocket_position,

			rocket_position
			+ Vector2(
				0.0,
				24.0
			),

			Color(

				firework_color.r,
				firework_color.g,
				firework_color.b,
				0.45

			),

			1.5

		)


		return


	# =====================================================
	# 爆発フラッシュ
	# =====================================================

	if flash_time > 0.0:

		var flash_alpha: float = (

			flash_time
			/ 0.13

		)


		draw_circle(

			rocket_position,

			20.0
			* flash_alpha,

			Color(

				1.0,
				1.0,
				0.9,
				flash_alpha * 0.3

			)

		)


		draw_circle(

			rocket_position,

			6.0
			* flash_alpha,

			Color(

				1.0,
				1.0,
				1.0,
				flash_alpha

			)

		)


	# =====================================================
	# 火花
	# =====================================================

	for spark: Dictionary in sparks:

		var life: float = float(

			spark["life"]

		)


		if life <= 0.0:

			continue


		var max_life: float = float(

			spark["max_life"]

		)


		var alpha: float = clamp(

			life
			/ max_life,

			0.0,

			1.0

		)


		# -------------------------------------------------
		# 消える直前はさらに暗くする
		# -------------------------------------------------

		if life < 0.35:

			alpha *= clamp(

				life / 0.35,

				0.0,

				1.0

			)


		var position: Vector2 = (

			spark["position"]

		)


		var spark_color: Color = (

			spark["color"]

		)


		var size: float = float(

			spark["size"]

		)


		var trail: Array[Vector2] = (

			spark["trail"]

		)


		# =================================================
		# 軌跡
		# =================================================

		if trail.size() >= 2:

			for i: int in range(

				trail.size() - 1

			):

				var trail_start: Vector2 = (

					trail[i]

				)


				var trail_end: Vector2 = (

					trail[i + 1]

				)


				var trail_ratio: float = (

					1.0
					- float(i)
					/ float(trail.size())

				)


				var trail_alpha: float = (

					alpha
					* trail_ratio
					* 0.65

				)


				var trail_width: float = (

					size
					* trail_ratio

				)


				if trail_width < 0.4:

					trail_width = 0.4


				draw_line(

					trail_start,

					trail_end,

					Color(

						spark_color.r,
						spark_color.g,
						spark_color.b,
						trail_alpha

					),

					trail_width

				)


		# =================================================
		# 火花本体
		# =================================================

		draw_circle(

			position,

			size * 1.25,

			Color(

				1.0,
				1.0,
				0.9,
				alpha

			)

		)


		# =================================================
		# 外側の色付き光
		# =================================================

		draw_circle(

			position,

			size * 2.1,

			Color(

				spark_color.r,
				spark_color.g,
				spark_color.b,
				alpha * 0.12

			)

		)
