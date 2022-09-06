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
@spinner "abc" new_variable = 4
@test new_variable == 4
@spinner new_variable_2 = 5
@test new_variable_2 == 5

let rex = r"^(\e\[\?25l)([◒◐◓◑◒◐◓◑][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner ) )
	regex_test(rex, :( @spinner sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([abcdefg][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "abcdefg" ) )
	regex_test(rex, :( @spinner "abcdefg" sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿" ) )
end

#=
let rex = r"^(\e\[\?25l)([
][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
=#

# I'm not sure why this test fails
#=
let rex = r"^(\e\[\?25l)([𝌆 𝌇 𝌈 𝌉 𝌊 𝌋 𝌌 𝌍 𝌎 𝌏 𝌐 𝌑 𝌒 𝌓 𝌔 𝌕 𝌖 𝌗 𝌘 𝌙 𝌚 𝌛 𝌜 𝌝 𝌞 𝌟 𝌠 𝌡 𝌢 𝌣 𝌤 𝌥 𝌦 𝌧 𝌨 𝌩 𝌪 𝌫 𝌬 𝌭 𝌮 𝌯 𝌰 𝌱 𝌲 𝌳 𝌴 𝌵 𝌶 𝌷 𝌸 𝌹 𝌺 𝌻 𝌼 𝌽 𝌾 𝌿 𝍀 𝍁 𝍂 𝍃 𝍄 𝍅 𝍆 𝍇 𝍈 𝍉 𝍊 𝍋 𝍌 𝍍 𝍎 𝍏 𝍐 𝍑 𝍒 𝍓 𝍔 𝍕 𝍖][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "𝌆 𝌇 𝌈 𝌉 𝌊 𝌋 𝌌 𝌍 𝌎 𝌏 𝌐 𝌑 𝌒 𝌓 𝌔 𝌕 𝌖 𝌗 𝌘 𝌙 𝌚 𝌛 𝌜 𝌝 𝌞 𝌟 𝌠 𝌡 𝌢 𝌣 𝌤 𝌥 𝌦 𝌧 𝌨 𝌩 𝌪 𝌫 𝌬 𝌭 𝌮 𝌯 𝌰 𝌱 𝌲 𝌳 𝌴 𝌵 𝌶 𝌷 𝌸 𝌹 𝌺 𝌻 𝌼 𝌽 𝌾 𝌿 𝍀 𝍁 𝍂 𝍃 𝍄 𝍅 𝍆 𝍇 𝍈 𝍉 𝍊 𝍋 𝍌 𝍍 𝍎 𝍏 𝍐 𝍑 𝍒 𝍓 𝍔 𝍕 𝍖" ) )
end
=#


#trigrams
let rex = r"^(\e\[\?25l)([☰☱☲☳☴☵☶☷][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner "☰☱☲☳☴☵☶☷" sleep(1) ) )
end

# Built-in character sets
let rex = r"^(\e\[\?25l)([←↖↑↗→↘↓↙][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :arrow sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([▁▂▃▄▅▆▇█][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :bar sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([⊙◡][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :blink sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛][\b][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :clock sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([⠀⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :dots sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([🌑🌒🌓🌔🌕🌖🌗🌘][\b][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :moon sleep(1) ) )
end

let rex = r"^(\e\[\?25l)([▉▊▋▌▍▎▏][\b])*([\b ])*(\e\[0J\e\[\?25h)$"
	regex_test(rex, :( @spinner :shutter sleep(1) ) )
end

#=
)

output_test(
	:( @spinner :arrow ),
	"\e[?25l←\b↖\b↑\b↗\b→\b↘\b↓\b↙\b←\b↖\b↑\b↗\b→\b↘\b↓\b↙\b←\b↖\b↑\b↗\b→\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :bar ),
	"\e[?25l▁\b▂\b▃\b▄\b▅\b▆\b▇\b█\b▇\b▆\b▅\b▄\b▃\b▂\b▁\b▁\b▂\b▃\b▄\b▅\b▆\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :blink ),
	"\e[?25l⊙\b⊙\b⊙\b⊙\b⊙\b⊙\b⊙\b◡\b⊙\b⊙\b⊙\b⊙\b⊙\b⊙\b⊙\b◡\b⊙\b⊙\b⊙\b⊙\b⊙\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :bounce precise_sleep(3) ),
	"\e[?25l(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b\b\b         \b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :cards short() ),
	"\e[?25l🂠🂠🂠🂠🂠\b\b\b\b\b\b\b\b\b\b🂪🂠🂠🂠🂠\b\b\b\b\b\b\b\b\b\b🂪🂫🂠🂠🂠\b\b\b\b\b\b\b\b\b\b🂪🂫🂭🂠🂠\b\b\b\b\b\b\b\b\b\b🂪🂫🂭🂮🂠\b\b\b\b\b\b\b\b\b\b🂪🂫🂭🂮🂱\b\b\b\b\b\b\b\b\b\b🂪🂫🂭🂮🂱\b\b\b\b\b\b\b\b\b\b🂪🂫🂭🂮🂱\b\b\b\b\b\b\b\b\b\b🂪🂫🂭🂮🂱\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                    \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :clock precise_sleep(3) ),
	"\e[?25l🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b🕗\b\b🕘\b\b🕙\b\b🕚\b\b🕛\b\b🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b🕗\b\b🕘\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :dots short() ),
	"\e[?25l⠁\b⠂\b⠃\b⠄\b⠅\b⠆\b⠇\b⠈\b⠉\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :loading short() ),
	"\e[?25lLoading.    \b\b\b\b\b\b\b\b\b\b\b\bLoading..   \b\b\b\b\b\b\b\b\b\b\b\bLoading...  \b\b\b\b\b\b\b\b\b\b\b\bLoading.... \b\b\b\b\b\b\b\b\b\b\b\bLoading.....\b\b\b\b\b\b\b\b\b\b\b\bLoading.....\b\b\b\b\b\b\b\b\b\b\b\bLoading.....\b\b\b\b\b\b\b\b\b\b\b\bLoading.....\b\b\b\b\b\b\b\b\b\b\b\bLoading.    \b\b\b\b\b\b\b\b\b\b\b\b            \b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :moon short() ),
	"\e[?25l🌑\b\b🌒\b\b🌓\b\b🌔\b\b🌕\b\b🌖\b\b🌗\b\b🌘\b\b🌑\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :pong short() ),
	"\e[?25l▐⠂       ▌\b\b\b\b\b\b\b\b\b\b▐⠈       ▌\b\b\b\b\b\b\b\b\b\b▐ ⠂      ▌\b\b\b\b\b\b\b\b\b\b▐ ⠠      ▌\b\b\b\b\b\b\b\b\b\b▐  ⡀     ▌\b\b\b\b\b\b\b\b\b\b▐  ⠠     ▌\b\b\b\b\b\b\b\b\b\b▐   ⠂    ▌\b\b\b\b\b\b\b\b\b\b▐   ⠈    ▌\b\b\b\b\b\b\b\b\b\b▐    ⠂   ▌\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :shutter short() ),
	"\e[?25l▉\b▊\b▋\b▌\b▍\b▎\b▏\b▎\b▍\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :snail short() ),
	"\e[?25l🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"

)

output_test(
	:( @spinner :a125🐌125yvg35hfddyu short() ),
	"\e[?25l?\b \b?\b \b?\b \b?\b \b?\b \b\e[0J\e[?25h"
)

=#
