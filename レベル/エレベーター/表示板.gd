extends Label3D


var 最大:int
var 現状:int

func 初期化(今:int,最上階:int)->void:
	現状=今
	最大=最上階
	更新()
	

func 更新()->void:
	text=str(現状)+"/"+str(最大)
