# Spinners.jl

Command line spinners in Julia with decent Unicode support

| **Documentation** | **Build Status** |
|---|---|
| [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://ashlinharris.github.io/Spinners.jl/stable/) [![](https://img.shields.io/badge/docs-development-blue.svg)](https://ashlinharris.github.io/Spinners.jl/dev/) | [![Build Status](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/AshlinHarris/Spinners.jl/actions/workflows/ci.yml) |

Draw a string animation cycle (spinner) until a given task completes.
This tool is designed primarily for visible ASCII characters, emojis, or a mix of both.
See the [documentation](https://ashlinharris.github.io/Spinners.jl/stable/#Examples) for examples, and for further information.

The current version is a working prototype with some Unicode support. The emphasis of v0.2 will be running the spinner on its own process and adding a macro for ease of use, and I might focus on performance for v0.3.

`Spinners.jl` (once it's mature) might be most useful for displaying elements while files are being downloaded or written to disk.
They serve as a visual indicator to the user that a process is ongoing and shouldn't be interrupted.
It isn't advisable to add terminal elements that are overly distracting unless there is a need.
For optimal performance and minimal energy consumption, it might be better to use a static message, or nothing at all.

# At a glance

![spinner](https://user-images.githubusercontent.com/90787010/186546184-33b4a8af-779a-439b-a41c-ae84cedae4f1.gif)
![cards](https://user-images.githubusercontent.com/90787010/186546176-442681d3-0584-48c0-9452-912c844a5112.gif)
![dots](https://user-images.githubusercontent.com/90787010/186546179-b84beac9-5cc9-485f-a435-2515532ef856.gif)
![loading](https://user-images.githubusercontent.com/90787010/186546182-f2d4e191-c360-4497-b089-46ff442bd568.gif)
![moon](https://user-images.githubusercontent.com/90787010/186546183-81ecd202-eb44-44d0-9ec3-36092af0b0f8.gif)
