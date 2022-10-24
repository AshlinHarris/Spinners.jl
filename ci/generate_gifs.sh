#!/usr/bin/sh

# One need to have python and asciinema installed
# One need to have rust-compiled and installed asciinema/agg tool
julia --project=@. -e "using Pkg; Pkg.instantiate()"
rm result.cast
asciinema rec result.cast --command "julia -q --project=@. generate_gifs.jl"
agg --theme asciinema --font-family "JuliaMono, Segoe UI Emoji" result.cast test.gif