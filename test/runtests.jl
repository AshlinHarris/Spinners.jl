using Random
using Spinners
using Test

original_stdout = stdout
(rd, wr) = redirect_stdout();

spinner()

redirect_stdout(original_stdout)
close(wr)
s = read(rd, String)
#println(s)

q = "\e[?25l    \b\b\b\b\\ \b\b  \b\b| \b\b  \b\b/ \b\b  \b\b- \b\b  \b\b\\ \b\b  \b\b| \b\b  \b\b/ \b\b  \b\b- \b\b  \b\b\\ \b\b  \b\b| \b\b  \b\b/ \b\b  \b\b- \b\b\b\b    \b\b\b\b✔️\e[0J\e[?25h"

#println(s == q)
@test s == q


using Spinners; os = stdout; (rd, wr) = redirect_stdout(); t=@async Task(sleep(0.1)); spinner(t); redirect_stdout(os);close(wr);s=read(rd, String)
q = "\e[?25l    \b\b\b\b\\ \b\b\b\b    \b\b\b\b✔️\e[0J\e[?25h"
@test s == q

using Spinners; os = stdout; (rd, wr) = redirect_stdout(); t=@async Task(sleep(0.1)); spinner(t, "1234567890"); redirect_stdout(os);close(wr);s=read(rd, String)
q = "\e[?25l          \b\b\b\b\b\b\b\b\b\b1 \b\b\b\b\b\b\b\b\b\b          \b\b\b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
@test s == q

using Spinners; os = stdout; (rd, wr) = redirect_stdout(); t=@async Task(sleep(0.1)); spinner(t, "🌑🌒🌓🌔🌕🌖🌗🌘"); redirect_stdout(os);close(wr);s=read(rd, String)
q = "\e[?25l        \b\b\b\b\b\b\b\b🌑 \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b        \b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
@test s == q

using Spinners; os = stdout; (rd, wr) = redirect_stdout(); t=@async Task(sleep(0.1)); spinner(t, "🌑🌒🌓🌔🌕🌖🌗🌘", 0.01, mode=:unfurl); redirect_stdout(os);close(wr);s=read(rd, String)
q = "\e[?25l        \b\b\b\b\b\b\b\b🌑🌒🌓🌔🌕🌖🌗🌘\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b        \b\b\b\b\b\b\b\b🌑🌒🌓🌔🌕🌖🌗🌘\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b        \b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
@test s == q

using Spinners; os = stdout; (rd, wr) = redirect_stdout(); t=@async Task(sleep(0.1)); spinner(t, "Ẵ⌘⓴♞⡕abcⰖ", 0.01, mode=:unfurl); redirect_stdout(os);close(wr);s=read(rd, String)
q = "\e[?25l         \b\b\b\b\b\b\b\b\bẴ⌘⓴♞⡕abcⰖ\b\b\b\b\b\b\b\b\b         \b\b\b\b\b\b\b\b\b✔️\e[0J\e[?25h"
@test s == q


using Spinners; os = stdout; (rd, wr) = redirect_stdout(); t=@async Task(sleep(0.1));  spinner(t, "........", 0.08, mode=:unfurl, before="Loading", after="Finished", cleanup=false); redirect_stdout(os);close(wr);s=read(rd, String)
q = "Loading\e[?25l        \b\b\b\b\b\b\b\b........\nFinished\n\e[0J\e[?25h"
@test s == q


Random.seed!(37)
using Spinners; os = stdout; (rd, wr) = redirect_stdout(); t=@async Task(sleep(0.01));spinner(t, :braille, 0.05, mode=:rand, after="⣿"); redirect_stdout(os);close(wr);s=read(rd, String)
q = "\e[?25l                                                                                                                                                                                                                                                               \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b⣎ \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                                                                                                                                                                                                                                                               \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b⣿\e[0J\e[?25h"
@test s == q
