using Random
using Spinners
using Test

usleep(usecs) = ccall(:usleep, Cint, (Cuint,), usecs)

function get_stdout(command::Expr)
	os = stdout;
	(rd, wr) = redirect_stdout();
	eval(command)
	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	return output
end

function output_test(expr, expected)
	output = get_stdout(expr)
	@test output == expected
end

function regex_test(rex, expr)
	out = get_stdout(expr)
	@test occursin(rex, out)
end

# How to make this more readable?
# Maybe read the outputs from elsewhere
# Also, does the order of tests affect the output?
# How can these be randomized?
usleep(1_000_000)
output_test( :( @spinner "abc" usleep(1_000_000) ), "\e[?25lb\bc\ba\b \e[0J\e[?25h")
output_test( :( @spinner :pong sleep(1) ), "\e[?25l▐⠈       ▌\b\b\b\b\b\b\b\b\b\b▐ ⠂      ▌\b\b\b\b\b\b\b\b\b\b▐ ⠠      ▌\b\b\b\b\b\b\b\b\b\b▐  ⡀     ▌\b\b\b\b\b\b\b\b\b\b          \e[0J\e[?25h")
output_test( :( @spinner :clock sleep(1) ), "\e[?25l🕐 \b\b\b🕑 \b\b\b🕒 \b\b\b🕓 \b\b\b🕔 \b\b\b   \e[0J\e[?25h")


output_test( :( @spinner "क़ " sleep(1) ), "\e[?25l \bक़\b \bक़\b \b \e[0J\e[?25h")
output_test( :( @spinner ["क़ ", "12345"] sleep(1) ), "\e[?25l12345\b\b\b\b\bक़ \b\b12345\b\b\b\b\bक़ \b\b12345\b\b\b\b\b     \e[0J\e[?25h")
output_test( :( @spinner "🎉\u3000დ\u3000@ क़ " sleep(2) ), "\e[?25l　\b\bდ\b　\b\b@\b \bक़\b \b🎉\b\b　\b\bდ\b \e[0J\e[?25h")

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
	@spinner :clock 0.2 x=1
	@spinner :clock 0.2 f()
	@spinner :clock 0.2 "before" x=1
	@spinner :clock 0.2 "before" f()
	@spinner :clock 0.2 "before" :rand x=1
	@spinner :clock 0.2 "before" :random f()
	s=:clock
	#@spinner s "hello"
	#@spinner s "hello" x=1
	#@spinner s "hello" f()

	# Tricky spinners
end
redirect_stdout(os);
close(wr);

#=

let rex = r"^(\e\[\?25l)([abcdefg][\b]){0,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "abcdefg" sleep(1) ) )
end

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

let rex = r"^(\e\[\?25l)([⊙◡][\b])*([\b ]){2,48}(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :blink sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛][\b][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :clock sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([⠀⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :dots sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🌑🌒🌓🌔🌕🌖🌗🌘][\b][\b]){2,48}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :moon sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([▉▊▋▌▍▎▏][\b])*([\b ]){2,48}(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :shutter sleep(1) ) )
end

=#
