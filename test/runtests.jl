using Random
using Spinners
using Test

#usleep(usecs) = ccall(:usleep, Cint, (Cuint,), usecs)

function get_stdout(command::Expr)
	os = stdout;
	(rd, wr) = redirect_stdout();
	eval(command)
	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	return output
end

function regex_test(rex, expr)
	out = get_stdout(expr)
	@test occursin(rex, out)
end

os = stdout;
(rd, wr) = redirect_stdout();
let
	# Scope tests
	@spinner "abc" new_variable = 4
	@test new_variable == 4
	@spinner "◒◐◓◑" new_variable_2 = 5
	@test new_variable_2 == 5

	# Usage tests
	f() = 2+2
	#@spinner
	#@spinner x=1
	#@spinner f()
	#@spinner :clock 
	@spinner :clock x=1
	@spinner :clock f()
	#@spinner :clock 0.2 x=1
	#@spinner :clock 0.2 f()
	#@spinner :clock 0.2 "before" x=1
	#@spinner :clock 0.2 "before" f()
	#@spinner :clock 0.2 "before" :rand x=1
	#@spinner :clock 0.2 "before" :random f()
	s=:clock
	#@spinner s "hello"
	#@spinner s "hello" x=1
	#@spinner s "hello" f()

	# Tricky spinners
	@spinner "क़ " sleep(2)
	#@spinner ["क़ ", "12345"] sleep(2)
	#@spinner "🎉\u3000დ\u3000@ क़ " sleep(2)

end
redirect_stdout(os);
close(wr);

#=

for i in 1:20
@test get_stdout(:( @spinner "abcdefg" sleep(1) )) == "\e[?25lb\b \bd\b \be\b \bf\b \bg\b \b\e[0J\e[?25h"
end
=#


let rex = r"^(\e\[\?25l)([abcdefg][\b]){8,56}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "abcdefg" ) )
end

let rex = r"^(\e\[\?25l)([䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿][\b]){8,56}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿" ) )
end

# I believe this test fails because Windows terminal inserts spaces after these characters.
#let rex = r"^(\e\[\?25l)([𝌆 𝌇 𝌈 𝌉 𝌊 𝌋 𝌌 𝌍 𝌎 𝌏 𝌐 𝌑 𝌒 𝌓 𝌔 𝌕 𝌖 𝌗 𝌘 𝌙 𝌚 𝌛 𝌜 𝌝 𝌞 𝌟 𝌠 𝌡 𝌢 𝌣 𝌤 𝌥 𝌦 𝌧 𝌨 𝌩 𝌪 𝌫 𝌬 𝌭 𝌮 𝌯 𝌰 𝌱 𝌲 𝌳 𝌴 𝌵 𝌶 𝌷 𝌸 𝌹 𝌺 𝌻 𝌼 𝌽 𝌾 𝌿 𝍀 𝍁 𝍂 𝍃 𝍄 𝍅 𝍆 𝍇 𝍈 𝍉 𝍊 𝍋 𝍌 𝍍 𝍎 𝍏 𝍐 𝍑 𝍒 𝍓 𝍔 𝍕 𝍖][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
#	regex_test(rex, :( @spinner "𝌆𝌇𝌈𝌉𝌊𝌋𝌌𝌍𝌎𝌏𝌐𝌑𝌒𝌓𝌔𝌕𝌖𝌗𝌘𝌙𝌚𝌛𝌜𝌝𝌞𝌟𝌠𝌡𝌢𝌣𝌤𝌥𝌦𝌧𝌨𝌩𝌪𝌫𝌬𝌭𝌮𝌯𝌰𝌱𝌲𝌳𝌴𝌵𝌶𝌷𝌸𝌹𝌺𝌻𝌼𝌽𝌾𝌿𝍀𝍁𝍂𝍃𝍄𝍅𝍆𝍇𝍈𝍉𝍊𝍋𝍌𝍍𝍎𝍏𝍐𝍑𝍒𝍓𝍔𝍕𝍖" ) )
#end

#trigrams
let rex = r"^(\e\[\?25l)([☰☱☲☳☴☵☶☷][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "☰☱☲☳☴☵☶☷" sleep(1) ) )
end

# Built-in character sets
let rex = r"^(\e\[\?25l)([←↖↑↗→↘↓↙][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :arrow sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([▁▂▃▄▅▆▇█][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :bar sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([⠀⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :dots sleep(1) ) )
end

#=
let rex = r"^(\e\[\?25l)([⊙◡][\b])*([\b ]){2,48}(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :blink sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛][\b][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :clock sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🌑🌒🌓🌔🌕🌖🌗🌘][\b][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :moon sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([▉▊▋▌▍▎▏][\b])*([\b ]){2,48}(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :shutter sleep(1) ) )
end
=#


