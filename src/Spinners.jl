"""
# Exported names:
- `@spinner`

Please see `?@spinner` for more information.
"""
module Spinners

using Unicode: transcode

export @spinner

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

get_named_string(x::Symbol) = get(SPINNERS, x, "? ")

"""
# @spinner
Create a command line spinner

## Usage
```
@spinner "string" expression # Iterate through the graphemes of a string
@spinner :symbol expression  # Use a built-in spinner
```

## Available symbols
"""
macro spinner(s, f)
	quote
		hide_cursor()
		local T = timer_spin($s)
		$(esc(f))
		close(T)
		show_cursor()
	end
end

# Assemble the global Spinner dictionnary from SpinnerDefinitions.jl
include("SpinnerDefinitions.jl")
# Add dictionaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

function timer_spin(raw_s)
	if typeof(raw_s) == Symbol
		s = get_named_string(raw_s) |> collect
	elseif typeof(raw_s) == String
		s = collect(raw_s)
	else
		s = raw_s
	end
	
	i=1
	print(s[1])
	cb(timer) = (
		i+=1;
		print("\b"^length(transcode(UInt16, string(s[(i-1)%length(s)+1])))*s[i%length(s)+1]);
	)
	return Timer(cb, 2, interval = 0.2)
end

end # module Spinners
