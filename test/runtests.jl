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

# Scope test
let
	@spinner "abc" new_variable = 4
	@test new_variable == 4
	@spinner new_variable_2 = 5
	@test new_variable_2 == 5
end

let rex = r"^(\e\[\?25l)([◒◐◓◑◒◐◓◑][\b]){8,40}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner ) )
end

let rex = r"^(\e\[\?25l)([◒◐◓◑◒◐◓◑][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([abcdefg][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "abcdefg" sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([abcdefg][\b]){8,40}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "abcdefg" ) )
end

let rex = r"^(\e\[\?25l)([䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿][\b]){8,40}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿" ) )
end

# I believe this test fails because Windows terminal inserts spaces after these characters.
#let rex = r"^(\e\[\?25l)([𝌆 𝌇 𝌈 𝌉 𝌊 𝌋 𝌌 𝌍 𝌎 𝌏 𝌐 𝌑 𝌒 𝌓 𝌔 𝌕 𝌖 𝌗 𝌘 𝌙 𝌚 𝌛 𝌜 𝌝 𝌞 𝌟 𝌠 𝌡 𝌢 𝌣 𝌤 𝌥 𝌦 𝌧 𝌨 𝌩 𝌪 𝌫 𝌬 𝌭 𝌮 𝌯 𝌰 𝌱 𝌲 𝌳 𝌴 𝌵 𝌶 𝌷 𝌸 𝌹 𝌺 𝌻 𝌼 𝌽 𝌾 𝌿 𝍀 𝍁 𝍂 𝍃 𝍄 𝍅 𝍆 𝍇 𝍈 𝍉 𝍊 𝍋 𝍌 𝍍 𝍎 𝍏 𝍐 𝍑 𝍒 𝍓 𝍔 𝍕 𝍖][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
#	regex_test(rex, :( @spinner "𝌆𝌇𝌈𝌉𝌊𝌋𝌌𝌍𝌎𝌏𝌐𝌑𝌒𝌓𝌔𝌕𝌖𝌗𝌘𝌙𝌚𝌛𝌜𝌝𝌞𝌟𝌠𝌡𝌢𝌣𝌤𝌥𝌦𝌧𝌨𝌩𝌪𝌫𝌬𝌭𝌮𝌯𝌰𝌱𝌲𝌳𝌴𝌵𝌶𝌷𝌸𝌹𝌺𝌻𝌼𝌽𝌾𝌿𝍀𝍁𝍂𝍃𝍄𝍅𝍆𝍇𝍈𝍉𝍊𝍋𝍌𝍍𝍎𝍏𝍐𝍑𝍒𝍓𝍔𝍕𝍖" ) )
#end

#trigrams
let rex = r"^(\e\[\?25l)([☰☱☲☳☴☵☶☷][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "☰☱☲☳☴☵☶☷" sleep(1) ) )
end

# Built-in character sets
let rex = r"^(\e\[\?25l)([←↖↑↗→↘↓↙][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :arrow sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([▁▂▃▄▅▆▇█][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :bar sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([⊙◡][\b])*([\b ]){2,16}(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :blink sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛][\b][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :clock sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([⠀⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :dots sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🌑🌒🌓🌔🌕🌖🌗🌘][\b][\b]){2,16}([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :moon sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([▉▊▋▌▍▎▏][\b])*([\b ]){2,16}(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :shutter sleep(1) ) )
end

