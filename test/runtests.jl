using Random
using Spinners
using Test

# Look at this
function output_test(command::Expr, expected::String)
	Random.seed!(37)
	os = stdout;
	(rd, wr) = redirect_stdout();
	eval(command)
	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	@test output == expected
end

# Don't look at this
#=
output_test(
	:(spinner()),
	"\e[?25l    \b\b\b\b\\ \b\b  \b\b| \b\b  \b\b/ \b\b  \b\b- \b\b  \b\b\\ \b\b  \b\b| \b\b  \b\b/ \b\b  \b\b- \b\b  \b\b\\ \b\b  \b\b| \b\b  \b\b/ \b\b  \b\b- \b\b\b\b    \b\b\b\b✔️\e[0J\e[?25h"
	)
=#

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

