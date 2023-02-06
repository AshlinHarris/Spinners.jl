# Spinners.jl

Command line spinners in Julia with Unicode support

[![Build Status](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml) [![Coverage](https://codecov.io/gh/ashlinharris/Spinners.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/AshlinHarris/Spinners.jl)

![spinners](https://user-images.githubusercontent.com/90787010/189241813-9ff87134-7b57-4e53-829b-32c6bc660851.gif)

## Description

`Spinners.jl` provides a single macro (`@spinner`), which generates a terminal spinner.

Spinners serve as a visual indicator to the user that a process is ongoing and shouldn't be interrupted (e.g., files are being downloaded or written to disk).

The API should be considered unstable until v1.0.

## Tutorial:
```
using Spinners

# The @spinner macro shouldn't affect the scope
do_some_calculations(x) = sum(map(i -> BigInt(999)^10_000_000 % i, 1:x))
@spinner "\\|/-" x = do_some_calculations(10);
println(x)

# You can provide a character set...
@spinner "🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛" do_some_calculations(15)
# ...but note that the following is not yet supported
# my_string = "🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛"
# @spinner my_string do_some_calculations(15)

# There are several character sets built in
# For instance, @spinner :clock do_some_calculations(15)
@spinner :loading
@spinner :shutter
@spinner :blink
@spinner :pong
@spinner :cards
```

## Related Works

I highly recommend [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl). This package includes spinning progress meters, which must be updated at points within the function being measured.
In contrast, `Spinners.jl.@spinner` treats the user function as a black box. It can't measure progress, but it receives a signal when the user's function is complete, so the user doesn't need to add breaks to their function.

In Julia:
- [timholy/ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl)
- [FedeClaudi/Term.jl](https://github.com/FedeClaudi/Term.jl)
  - https://fedeclaudi.github.io/Term.jl/stable/adv/progressbars/
- JuliaLang/Pkg.jl spinners:
  - [MiniProgressBars.jl](https://github.com/JuliaLang/Pkg.jl/blob/master/src/MiniProgressBars.jl)
  - [API.jl](https://github.com/JuliaLang/Pkg.jl/blob/master/src/API.jl)
- [cloud-oak/ProgressBars.jl](https://github.com/cloud-oak/ProgressBars.jl)
- [KristofferC/TerminalSpinners.jl](https://github.com/KristofferC/TerminalSpinners.jl)
- [rahulkp220/Spinner.jl (defunct)](https://github.com/rahulkp220/Spinner.jl)
  
In other languages:
- [sindresorhus/cli-spinners (JavaScript)](https://github.com/sindresorhus/cli-spinners)
  - Some assets in Spinners.jl come from here.

## Related discussions:
- https://discourse.julialang.org/t/update-stdout-while-a-function-is-running/86285
- https://discourse.julialang.org/t/how-to-print-rotating-tick-as-progress-bar-in-terminal/62099
- https://discourse.julialang.org/t/terminating-a-process-on-windows/87481
- https://discourse.julialang.org/t/whats-an-interactive-task-does-it-pause-a-running-task/93532
  
