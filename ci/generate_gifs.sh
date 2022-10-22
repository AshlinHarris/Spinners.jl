#!/usr/bin/sh

# One need to have python and asciinema installed
# One need to have rust-compiled and installed asciinema/agg tool

rm result.cast
asciinema rec result.cast --command "julia --project=@. generate_gifs.jl"
agg result.cast test.gif