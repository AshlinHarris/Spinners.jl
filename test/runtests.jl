using Random
using Spinners
using Test

# Look at this
function output_test(command::Expr, expected::String)
	Random.seed!(37) # Make this depend on the version?
	os = stdout;
	(rd, wr) = redirect_stdout();
	eval(command)
	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	@test output == expected
end

# Don't look at this

output_test(
	:( @spinner ),
	"\e[?25l◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner sleep(1) ),
	"\e[?25l◒\b◐\b◓\b◑\b◒\b◐\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner "1234567890" sleep(0.5) ),
	"\e[?25l1\b2\b \b\e[0J\e[?25h"
)

output_test(
	:( @spinner "abcdefg" sleep(1) ),
	"\e[?25la\bb\bc\bd\be\bf\b \b\e[0J\e[?25h"
)

# hexagrams
output_test(
	:( @spinner "䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿" ),
	"\e[?25l䷀\b䷁\b䷂\b䷃\b䷄\b䷅\b䷆\b䷇\b䷈\b䷉\b䷊\b䷋\b䷌\b䷍\b䷎\b䷏\b䷐\b䷑\b䷒\b䷓\b䷔\b\b\b   \b\b\b\e[0J\e[?25h"
)

# tetragrams
output_test(
	:( @spinner "𝌆 𝌇 𝌈 𝌉 𝌊 𝌋 𝌌 𝌍 𝌎 𝌏 𝌐 𝌑 𝌒 𝌓 𝌔 𝌕 𝌖 𝌗 𝌘 𝌙 𝌚 𝌛 𝌜 𝌝 𝌞 𝌟 𝌠 𝌡 𝌢 𝌣 𝌤 𝌥 𝌦 𝌧 𝌨 𝌩 𝌪 𝌫 𝌬 𝌭 𝌮 𝌯 𝌰 𝌱 𝌲 𝌳 𝌴 𝌵 𝌶 𝌷 𝌸 𝌹 𝌺 𝌻 𝌼 𝌽 𝌾
𝌿 𝍀 𝍁 𝍂 𝍃 𝍄 𝍅 𝍆 𝍇 𝍈 𝍉 𝍊 𝍋 𝍌 𝍍 𝍎 𝍏 𝍐 𝍑 𝍒 𝍓 𝍔 𝍕 𝍖 " sleep(0.5) ),
	"\e[?25l𝌆\b\b \b\b\b\b    \b\b\b\b\e[0J\e[?25h"
)

# trigrams
output_test(
	:( @spinner "☰☱☲☳☴☵☶☷" sleep(0.5) ),
	"\e[?25l☰\b☱\b\b\b   \b\b\b\e[0J\e[?25h"
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
	:( @spinner :bounce sleep(0.1) ),
	"\e[?25l\b\b\b\b\b\b\b\b\b         \b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
	#"\e[?25l(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b\b\b         \b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
	#"\e[?25l(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(●    )\b\b\b\b\b\b\b( ●   )\b\b\b\b\b\b\b(  ●  )\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b(    ●)\b\b\b\b\b\b\b(   ● )\b\b\b\b\b\b\b\b\b         \b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :cards sleep(0.2) ),
	"\e[?25l\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                    \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :clock sleep(0.5) ),
	"\e[?25l🕐\b\b🕑\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
	#"\e[?25l🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b🕗\b\b🕘\b\b🕙\b\b🕚\b\b🕛\b\b🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b🕗\b\b🕘\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
	#"\e[?25l🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b🕗\b\b🕘\b\b🕙\b\b🕚\b\b🕛\b\b🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
	#"\e[?25l🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b🕗\b\b🕘\b\b🕙\b\b🕚\b\b🕛\b\b🕐\b\b🕑\b\b🕒\b\b🕓\b\b🕔\b\b🕕\b\b🕖\b\b🕗\b\b🕘\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :dots sleep(0.5) ),
	"\e[?25l⠁\b⠂\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :loading sleep(0.5) ),
	"\e[?25lLoading.    \b\b\b\b\b\b\b\b\b\b\b\bLoading..   \b\b\b\b\b\b\b\b\b\b\b\b            \b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :moon sleep(0.5) ),
	"\e[?25l🌑\b\b🌒\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :pong sleep(0.5) ),
	"\e[?25l▐⠂       ▌\b\b\b\b\b\b\b\b\b\b▐⠈       ▌\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :shutter sleep(0.5) ),
	"\e[?25l▉\b▊\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner :snail sleep(0.5) ),
	"\e[?25l🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b🐌        🏁\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\e[0J\e[?25h"

)

output_test(
	:( @spinner :a125🐌125yvg35hfddyu sleep(0.5) ),
	"\e[?25l?\b \b \b\e[0J\e[?25h"
)


#=


output_test(
	:(t = @async Task(:); spinner(t)),
	"\e[?25l    \b\b\b\b\b\b\b\b    \b\b\b\b✔️\e[0J\e[?25h"
)

output_test(
	:(t=@async Task(:); spinner(t, "1234567890")),
	"\e[?25l          \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b          \b\b\b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
)

output_test(
	:(t=@async Task(:); spinner(t, "1234567890", 2)),
	"\e[?25l          \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b          \b\b\b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
)

output_test(
	:(t=@async Task(:); spinner(t, "🌑🌒🌓🌔🌕🌖🌗🌘")),
	"\e[?25l        \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b        \b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
)

output_test(
	:(t=@async Task(:); spinner(t, "🌑🌒🌓🌔🌕🌖🌗🌘", 0.01, mode=:unfurl)),
	"\e[?25l        \b\b\b\b\b\b\b\b🌑🌒🌓🌔🌕🌖🌗🌘\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b        \b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
 
)

output_test(
	:(t=@async Task(:); spinner(t, "Ẵ⌘⓴♞⡕abcⰖ", 0.01, mode=:unfurl)),
	"\e[?25l         \b\b\b\b\b\b\b\b\bẴ⌘⓴♞⡕abcⰖ\b\b\b\b\b\b\b\b\b         \b\b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
)

output_test(
	:(t=@async Task(:);  spinner(t, "........", 0.08, mode=:unfurl, before="Loading", after="Finished", cleanup=false)),
	"Loading\e[?25l        \b\b\b\b\b\b\b\b........\nFinished\n\e[0J\e[?25h"
)


output_test(
	:(t=@async Task(:);spinner(t, :dots, 0.05, mode=:rand, after="⣿")),
	"\e[?25l                                                                                                                                                                                                                                                               \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                                                                                                                                                                                                                                                               \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b⣿\e[0J\e[?25h"
)

=#
