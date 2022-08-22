using Spinners
using Test

original_stdout = stdout
(rd, wr) = redirect_stdout();

spinner()

redirect_stdout(original_stdout)
close(wr)
s = read(rd, String)
println(s)

#let t= @async(2)

