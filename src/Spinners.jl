"""
# Exported names:
- `@spinner`

Please see `?@spinner` for more information.
"""
module Spinners

using Base.Threads
using Distributed
using Unicode: transcode

export @spinner, spinner

rch = [RemoteChannel(()->Channel(1), 1) for _ in 1:nprocs()]

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

get_character(s,i) = s[(i)%length(s)+1]
erase_character(c) = print("\b"^length(transcode(UInt16, string(c))))

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

# Assemble the global Spinner dictionnary from Definitions.jl
include("Definitions.jl")
# Add dictionaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

function timer_spin()
	timer_spin(:clock, "")
end
function timer_spin(raw_s, msg="")
    #! TODO implement right custom text (msg arg)
	if typeof(raw_s) == Symbol
		s = get_named_string(raw_s) |> collect
	elseif typeof(raw_s) == String
		s = collect(raw_s)
	else
		s = raw_s
	end

	# Callback function
	function doit(i, rch)
		(timer) -> begin
			# Check for a stop signal (42) on this channel
			ch = rch[myid()]
			stop = isready(ch) && take!(ch) == 42

			# Clean up
			current = get_character(s,i)
			erase_character(current)

			# Stop or print next
			if(stop)
				close(timer)
			else
				i+=1
				next = get_character(s, i)
				print(next)
			end

		end
	end

	i=1
	print(s[1])
	Timer(doit(i, rch), 0, interval = 0.2)
end

function _check_inputs(inputs)
	#! To implement
end

# Is the return needed ? one can use : var = @spinner :clock "message" expr
macro spinner(inputs...)
	_check_inputs(inputs)
	return quote
		hide_cursor()

		local T = fetch(Threads.@spawn :interactive timer_spin($(inputs[1:end-1]...)))

		res = $(esc(inputs[end]))
		res
		put!(rch[1], 42)

		show_cursor()
	end
end

macro spinner()
        @info("An expression is required (e.g., `@spinner sleep(4)`).")
end

end # module Spinners
