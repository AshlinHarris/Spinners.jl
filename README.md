# Spinners.jl

Command line spinners in Julia with decent Unicode support

## Warning for Windows users

__Important:__ `Spinners.jl` creates a process which __no longer terminates on Windows__. The issue first appeared in the past several days and applies regardless of Julia version or package version.

[![Build Status](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml)

![spinners](https://user-images.githubusercontent.com/90787010/189241813-9ff87134-7b57-4e53-829b-32c6bc660851.gif)

## Description

`Spinners.jl` provides a single macro (`@spinner`), which generates a terminal spinner.
The spinner runs as a separate process that is terminated once the user code has finished running.
For user instructions, see the internal documentation (`?@spinner`).

The package is supported on all modern Julia releases for Linux, MacOS, and Windows.
However, Windows terminal might have issues with some UTF-16 characters, which it displays with additional spaces.

The API should be considered unstable until v1.0.

Spinners serve as a visual indicator to the user that a process is ongoing and shouldn't be interrupted (e.g., files are being downloaded or written to disk).
It isn't advisable to add terminal elements that are overly distracting unless there is a need.
For improved performance and energy use, it might be better to use a static message, or nothing at all.

## Tutorial:
```
using Spinners

# For testing, a default function (sleep(3)) is used
@spinner 

# Put @spinner in front of your code - this shouldn't affect the scope
do_some_calculations(x) = sum(map(i -> BigInt(999)^10_000_000 % i, 1:x))
@spinner x = do_some_calculations(10);
println(x)

# You can provide a character set...
@spinner "🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛" do_some_calculations(15)
# ...but note that the following is not yet supported
# my_string = "🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛"
# @spinner my_string do_some_calculations(15)
# There is some Unicode support.
# For now, it's best if all the characters have the same transcode length

# There are several character sets built in
# For instance, @spinner :clock do_some_calculations(15)
@spinner :loading
@spinner :shutter
@spinner :blink

# Currently, users cannot input their own string vector.
# However, there are some that are already built in:
@spinner :loading
@spinner :pong
@spinner :cards
```

## Notes for developers
Here are any aspects of the code that were especially tricky for me to conceive and implement, so they might be confusing to others:
- Source code
  - The main julia process generates the code for the spinner and shells out (with julia) to make the spinner process. This is the only way I could find for the spinner to act completely independently of the user's functions.
  - The processes don't communicate until the main process sends a kill signal to the spinner process.
  - To erase a character, the spinner process prints a number of backspaces depending on the length of the character's transcode.
- Tests
  - I capture stdout to see what the spinner process has printed.
  - The spinner isn't guranteed to start or stop at a particular moment, so I use regular expressions to make sure the printout is reasonable.
  
## Internal documentation:
```
julia> using Spinners
help?> @spinner
  @spinner
  ≡≡≡≡≡≡≡≡≡≡

  Create a command line spinner

  Usage
  =======

  @spinner expression          # Use the default spinner
  @spinner "string" expression # Iterate through the graphemes of a string
  @spinner :symbol expression  # Use a built-in spinner

  Available symbols
  ===================

  :arrow, :bar, :blink, :bounce, :cards, :clock, :dots, :loading, :moon, :pong, :shutter, :snail
```

## Related Works

I highly recommend [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl), which already has its own version of spinners, albeit with a different use case.
[This thread on the Julia Discourse](https://discourse.julialang.org/t/update-stdout-while-a-function-is-running/86285) gives some technical details, but essentially those spinners are still progress meters, which must be updated at points with the function being measured. In contrast, I'm developing spinners that update independently and only need a signal to terminate after a function call elapses.

In Julia:
- [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl)
  - Includes feature from [Spinner.jl](https://github.com/rahulkp220/Spinner.jl)
- [ProgressBars.jl](https://github.com/cloud-oak/ProgressBars.jl)
- Pkg.jl spinners:
  - [MiniProgressBars.jl](https://github.com/JuliaLang/Pkg.jl/blob/master/src/MiniProgressBars.jl)
  - [API.jl](https://github.com/JuliaLang/Pkg.jl/blob/master/src/API.jl)
  
Other projects:
- [cli-spinners](https://github.com/sindresorhus/cli-spinners)
  - Some assets in Spinners.jl come from here.
  
