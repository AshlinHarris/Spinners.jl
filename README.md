# Spinners.jl

Command line spinners in Julia with decent Unicode support

| **Documentation** | **Build Status** |
|---|---|
| [![](https://img.shields.io/badge/docs-stable-red.svg)](https://ashlinharris.github.io/Spinners.jl/stable/) [![](https://img.shields.io/badge/docs-development-blue.svg)](https://ashlinharris.github.io/Spinners.jl/dev/) | [![Build Status](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml) |

## Notes for users
Try these:
```
using Spinners
@spinner                   # no arguments
@spinner sleep(4)          # just an expressions
@spinner :moon             # just a character set (or symbol)
@spinner :bounce sleep(4)  # character set and expressions

```
Some explanations:
```
using Spinners

@spinner # For testing, it runs on a default function (sleep(3))

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

# This documentation isn't complete, I hope to finish it up soon! -Ashlin 
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

# Older (and outdated) documentation

## Description

Draw a string animation cycle (spinner) until a given command completes.
See the [documentation](https://ashlinharris.github.io/Spinners.jl/stable/#Examples) for examples, and for further information.

The API might change drastically until v1.0.  

`Spinners.jl` (once it's mature) might be most useful for displaying elements while files are being downloaded or written to disk.
They serve as a visual indicator to the user that a process is ongoing and shouldn't be interrupted.
It isn't advisable to add terminal elements that are overly distracting unless there is a need.
For optimal performance and minimal energy consumption, it might be better to use a static message, or nothing at all.

I highly recommend [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl), which already has its own version of spinners, albeit with a different use case.
[This thread on the Julia Discourse](https://discourse.julialang.org/t/update-stdout-while-a-function-is-running/86285) gives some technical details, but essentially those spinners are still progress meters, which must be updated at points with the function being measured. In contrast, I'm developing spinners that update independently and only need a signal to terminate after a function call elapses.

## At a glance
```
# Usage: 
# @spinner result = some_long_function(); println(result)
```

![spinner](https://user-images.githubusercontent.com/90787010/186546184-33b4a8af-779a-439b-a41c-ae84cedae4f1.gif)
![cards](https://user-images.githubusercontent.com/90787010/186546176-442681d3-0584-48c0-9452-912c844a5112.gif)
![dots](https://user-images.githubusercontent.com/90787010/186546179-b84beac9-5cc9-485f-a435-2515532ef856.gif)
![loading](https://user-images.githubusercontent.com/90787010/186546182-f2d4e191-c360-4497-b089-46ff442bd568.gif)
![moon](https://user-images.githubusercontent.com/90787010/186546183-81ecd202-eb44-44d0-9ec3-36092af0b0f8.gif)

## Related Packages
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
  

