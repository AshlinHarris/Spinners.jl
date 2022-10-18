"""
# Exported names:
- `@spinner`

Please see `?@spinner` for more information.
"""
module Spinners

using Base.Threads
using Distributed
using Unicode: graphemes
using Unicode: transcode

export @spinner, spinner

rch = [RemoteChannel(()->Channel(1), 1) for _ in 1:nprocs()]

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

get_grapheme(s,i) = s[(i)%length(s)+1]
erase_grapheme(c) = print("\b"^textwidth(c) *
	" "^textwidth(c) *
	"\b"^textwidth(c) )

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
	timer_spin("◒◐◓◑")
end
function timer_spin(parameters...)

	inputs = collect(parameters)

	# Process inputs

	if isempty(inputs)
		seconds_per_frame = 0.2
	else
		location = [isa(x, Number) for x in inputs] |> findfirst
		if isnothing(location)
			seconds_per_frame = 0.2
		else
			seconds_per_frame = popat!(inputs, location)
		end
	end

	if isempty(inputs)
		raw_s = "◒◐◓◑"
	else
		raw_s = popfirst!(inputs)
	end

	if isempty(inputs)
		msg = ""
	else
		msg = popfirst!(inputs)::String
	end

	if isempty(inputs)
		mode = :none
	else
		mode = popfirst!(inputs)::Symbol
	end

	if typeof(raw_s) == Symbol
		raw_s = get_named_string(raw_s)
	end

	if typeof(raw_s) == String
		s = ["$i" for i in collect(graphemes(raw_s))]
	else
		s = raw_s
	end

	# Append messages to each frame
	s .*= msg

	# Callback function
	function doit(i, rch, mode)
		(timer) -> begin
			# Check for a stop signal (42) on this channel
			ch = rch[myid()]
			stop = isready(ch) && take!(ch) == 42

			# Clean up
			current = get_grapheme(s,i)
			erase_grapheme(current)

			# Stop or print next
			if(stop)
				close(timer)
			else
				if mode == :rand || mode == :random
					i = rand(filter((x) -> x!= i, 1:100))
				else
					i+=1
				end
				next = get_grapheme(s, i)
				print(next)
			end

		end
	end
	i=1
	print(s[1])
	Timer(doit(i, rch, mode), 0, interval = seconds_per_frame)
end

# Add spinner start up and clean up to user expression
macro spinner(inputs...)
	return quote
		# Add start up before user expression
		hide_cursor()
		local T = fetch(Threads.@spawn :interactive timer_spin($(inputs[1:end-1]...)))

		# User expression
		$(esc(inputs[end]))

		# Add clean up after user expression
		put!(rch[1], 42)
		show_cursor()
	end
end

macro spinner()
        @info("An expression is required (e.g., `@spinner sleep(4)`).")
end

end # module Spinners
