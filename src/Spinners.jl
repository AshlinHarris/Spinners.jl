"""
# Exported names:
- `@spinner`

Please see `?@spinner` for more information.
"""
module Spinners

using Base.Threads
using Distributed: fetch
using Distributed: isready
using Distributed: myid
using Distributed: nprocs
using Distributed: put!
using Distributed: RemoteChannel
using Distributed: take!
using Unicode: graphemes
using Unicode: transcode

export @spinner, spinner

# Spinner struct
Base.@kwdef mutable struct Spinner
	style::Vector{String} = ["\\","|","/","-"] |> collect .|> string
	mode::Symbol = :none
	seconds_per_frame::Real = 0.2
	frame::Unsigned = 1
end

# Functions on spinner types

function get_grapheme(spinner)
	s = spinner.style
	i = spinner.frame

	return s[(i)%length(s)+1]
end

function erase_grapheme(spinner)
	c = get_grapheme(spinner)

	print("\b"^textwidth(c) *
		" "^textwidth(c) *
		"\b"^textwidth(c) )

	return
end

# Signaling spinners

rch = [RemoteChannel(()->Channel(1), 1) for _ in 1:nprocs()];

const STOP_SIGNAL = 42
const signal_to_close() = put!(rch[1], STOP_SIGNAL)
function stop_signal_found()
	ch = rch[myid()]
	stop = isready(ch) && take!(ch) == STOP_SIGNAL
end

const hide_cursor() = print("\u001B[?25l")
const show_cursor() = print("\u001B[0J", "\u001B[?25h")

get_named_string(x::Symbol) = get(SPINNERS, x, "? ")

include("Definitions.jl")
# Add dictionaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

function generate_spinner(inputs)::Spinner

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
		mode = popfirst!(inputs)
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

	return Spinner(
		style=s,
		mode=mode,
		seconds_per_frame=seconds_per_frame,
	)
end

function timer_spin()
	timer_spin("◒◐◓◑")
end
function timer_spin(parameters...)

	# Callback function
	function doit(rch, S::Spinner)

		(timer) -> begin
			# Clean up
			erase_grapheme(S)

			# Stop or print next
			if(stop_signal_found())
				close(timer)
			else
				if S.mode == :rand || S.mode == :random
					S.frame = rand(filter((x) -> x!= S.frame, 1:100))
				else
					S.frame+=1
				end
				next = get_grapheme(S)
				print(next)
			end
		end
	end

	inputs = collect(parameters)
	my_spinner = generate_spinner(inputs)

	print(get_grapheme(my_spinner))
	my_timer = Timer(doit(rch, my_spinner), 0, interval = my_spinner.seconds_per_frame);
	wait(my_timer)
end

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
macro spinner()
        @info("An expression is required (e.g., `@spinner sleep(4)`).")
end
macro spinner(inputs...)
	return quote
		# Start spinner
		hide_cursor()
		local T = fetch(Threads.@spawn :interactive timer_spin($(inputs[1:end-1]...)));

		# User expression
		$(esc(inputs[end]))

		# Close spinner
		signal_to_close()
		show_cursor()
	end
end

end # module Spinners
