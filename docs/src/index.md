```@meta
CurrentModule = Spinners
```

# Spinners

Documentation for [Spinners.jl](https://github.com/AshlinHarris/Spinners.jl).

```@contents
```

# Examples

```@example
using Spinner

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

