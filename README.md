# Spinners.jl

Command line spinners in Julia with decent Unicode support

| **Documentation** | **Build Status** |
|---|---|
| [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://ashlinharris.github.io/Spinners.jl/stable/) [![](https://img.shields.io/badge/docs-development-blue.svg)](https://ashlinharris.github.io/Spinners.jl/dev/) | [![Build Status](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml) |

## Description

Draw a string animation cycle (spinner) until a given command completes.
See the [documentation](https://ashlinharris.github.io/Spinners.jl/stable/#Examples) for examples, and for further information.

Currently, the `\@spinners` macro doesn't allow customization, but this is will be the development focus for v0.3.
The function `spinner()` allows customization but doesn't actually run the spinner as a separate process and will be deprecated in v0.3.
The API might change drastically until v1.0.  

`Spinners.jl` (once it's mature) might be most useful for displaying elements while files are being downloaded or written to disk.
They serve as a visual indicator to the user that a process is ongoing and shouldn't be interrupted.
It isn't advisable to add terminal elements that are overly distracting unless there is a need.
For optimal performance and minimal energy consumption, it might be better to use a static message, or nothing at all.

I highly recommend [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl), which already has its own version of spinners, albeit with a different use case.
[This thread on the Julia Discourse](https://discourse.julialang.org/t/update-stdout-while-a-function-is-running/86285) gives some technical details, but essentially those spinners are still progress meters, which must be updated at points with the function being measured. In contrast, I'm developing spinners that update independently and only need a signal to terminate after a function call elapses.

This thread on the Julia Discourse gives some technical details, but essentially those spinners are still progress meters, which must be updated at points with the function being measured. In contrast, I'm developing spinners that update independently and only need a signal to terminate after a function call elapses.

## At a glance
```
@spinner sleep(4)
# @spinner result = some_long_function(); println(result)
```

![spinner](https://user-images.githubusercontent.com/90787010/186546184-33b4a8af-779a-439b-a41c-ae84cedae4f1.gif)
![cards](https://user-images.githubusercontent.com/90787010/186546176-442681d3-0584-48c0-9452-912c844a5112.gif)
![dots](https://user-images.githubusercontent.com/90787010/186546179-b84beac9-5cc9-485f-a435-2515532ef856.gif)
![loading](https://user-images.githubusercontent.com/90787010/186546182-f2d4e191-c360-4497-b089-46ff442bd568.gif)
![moon](https://user-images.githubusercontent.com/90787010/186546183-81ecd202-eb44-44d0-9ec3-36092af0b0f8.gif)

## Related Packages

- [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl)
  - Includes feature from [Spinner.jl](https://github.com/rahulkp220/Spinner.jl)
- [ProgressBars.jl](https://github.com/cloud-oak/ProgressBars.jl)
- Pkg.jl spinners:
  - [MiniProgressBars.jl](https://github.com/JuliaLang/Pkg.jl/blob/master/src/MiniProgressBars.jl)
  - [API.jl](https://github.com/JuliaLang/Pkg.jl/blob/master/src/API.jl)
