extends Button
class_name エレベーターボタンGUI

var インデックス:int


func 初期化(階層インデックス:int,エレベーター:エレベーターレベルクラス,文字:String="")->void:
	インデックス=階層インデックス
	text=str(階層インデックス+1)+"階"
	if 文字!="":
		text=text+":"+文字
	pressed.connect(エレベーター.階層選択.bind(インデックス))
