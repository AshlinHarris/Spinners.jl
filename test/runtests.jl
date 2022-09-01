using Random
using Spinners
using Test

usleep(usecs) = ccall(:usleep, Cint, (Cuint,), usecs)
precise_sleep(x) = usleep(Int(x * 1_000_000))
const short() = precise_sleep(1.495)

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


# These tests rely on sleep(), which is imprecise
#=
output_test(
	:( @spinner ),
	"\e[?25l◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner "1234" ),
	"\e[?25l◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b\b\b   \b\b\b\e[0J\e[?25h"
)
=#

output_test(
	:( @spinner short() ),
	"\e[?25l◒\b◐\b◓\b◑\b◒\b◐\b◓\b◑\b◒\b◐\b\b\b   \b\b\b\e[0J\e[?25h"
)

output_test(
	:( @spinner "1234567890" short() ),
	"\e[?25l1\b2\b3\b4\b5\b6\b7\b8\b9\b \b\e[0J\e[?25h"
)

output_test(
	:( @spinner "abcdefg" short() ),
	"\e[?25la\bb\bc\bd\be\bf\bg\ba\bb\b \b\e[0J\e[?25h"
)

# hexagrams
output_test(
	:( @spinner "䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿" ),
	"\e[?25l䷀\b䷁\b䷂\b䷃\b䷄\b䷅\b䷆\b䷇\b䷈\b䷉\b䷊\b䷋\b䷌\b䷍\b䷎\b䷏\b䷐\b䷑\b䷒\b䷓\b䷔\b\b\b   \b\b\b\e[0J\e[?25h"
)

# tetragrams
output_test(
	:( @spinner "𝌆 𝌇 𝌈 𝌉 𝌊 𝌋 𝌌 𝌍 𝌎 𝌏 𝌐 𝌑 𝌒 𝌓 𝌔 𝌕 𝌖 𝌗 𝌘 𝌙 𝌚 𝌛 𝌜 𝌝 𝌞 𝌟 𝌠 𝌡 𝌢 𝌣 𝌤 𝌥 𝌦 𝌧 𝌨 𝌩 𝌪 𝌫 𝌬 𝌭 𝌮 𝌯 𝌰 𝌱 𝌲 𝌳 𝌴 𝌵 𝌶 𝌷 𝌸 𝌹 𝌺 𝌻 𝌼 𝌽 𝌾
𝌿 𝍀 𝍁 𝍂 𝍃 𝍄 𝍅 𝍆 𝍇 𝍈 𝍉 𝍊 𝍋 𝍌 𝍍 𝍎 𝍏 𝍐 𝍑 𝍒 𝍓 𝍔 𝍕 𝍖 " short() ),
	"\e[?25l𝌆\b\b \b𝌇\b\b \b𝌈\b\b \b𝌉\b\b \b𝌊\b\b\b\b    \b\b\b\b\e[0J\e[?25h"
)

# trigrams
output_test(
	:( @spinner "☰☱☲☳☴☵☶☷" short() ),
	"\e[?25l☰\b☱\b☲\b☳\b☴\b☵\b☶\b☷\b☰\b\b\b   \b\b\b\e[0J\e[?25h"
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
