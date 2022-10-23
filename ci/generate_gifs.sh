#!/usr/bin/sh

# One need to have python and asciinema installed
# One need to have rust-compiled and installed asciinema/agg tool
julia --project=@. -e "using Pkg; Pkg.instantiate()"
rm result.cast
asciinema rec result.cast --command "julia --project=@. generate_gifs.jl"

# remove julia header lines
sed '2,6d' result.cast > result2.cast

agg result2.cast test.gif