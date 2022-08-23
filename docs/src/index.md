```@meta
CurrentModule = Spinners
```

# Spinners

Documentation for [Spinners.jl](https://github.com/AshlinHarris/Spinners.jl).

```@contents
```

# Examples

```@example
(rd, wr) = redirect_stdout() # hide
using Spinners

spinner()
t = @async sleep(5); spinner(t, :moon)
t = @async sleep(5); spinner(t, "........", 0.08, mode=:unfurl, before="Loading", after="Finished", cleanup=false)
t = @async sleep(5); spinner(t, :dots, 0.05, mode=:rand, after="⣿")
t = @async sleep(5); spinner(t, "🂫🂬🂭🂮🂡", 0.5, mode=:unfurl, blank = "🂠", cleanup=false)

```
# Function index

```@index
```

# Function documentation

```@autodocs
Modules = [Spinners]
Private = false
Order = [:function]
```
# Limitations
The intended use case is for visible ASCII characters and emojis.
These should hopefully work on most any modern ANSI terminal, regardless of operating system.
Windows terminal will have issues with some UTF-8 characters.
Certain character sets (UTF-16, alphabets that print right to left, etc.) are not currently supported.


