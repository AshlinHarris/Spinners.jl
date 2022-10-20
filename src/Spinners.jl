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
	mutable struct Spinner
		#id::Unsigned
		#location::String
		const style::Vector{String}
		const mode::Symbol
		frame::Unsigned
	end


rch = [RemoteChannel(()->Channel(1), 1) for _ in 1:nprocs()]

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

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

get_named_string(x::Symbol) = get(SPINNERS, x, "? ")

const STOP_SIGNAL = 42
const close_spinner() = put!(rch[1], STOP_SIGNAL)
function stop_signal_found()
	ch = rch[myid()]
	stop = isready(ch) && take!(ch) == STOP_SIGNAL
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

	my_spinner = Spinner(s, mode, 1)

	# Callback function
	function doit(rch, my_spinner)

		s = my_spinner.style
		mode = my_spinner.mode

		(timer) -> begin
			# Clean up
			erase_grapheme(my_spinner)

			# Stop or print next
			if(stop_signal_found())
				close(timer)
			else
				if mode == :rand || mode == :random
					my_spinner.frame = rand(filter((x) -> x!= my_spinner.frame, 1:100))
				else
					my_spinner.frame+=1
				end
				next = get_grapheme(my_spinner)
				print(next)
			end

		end
	end
	print(s[1])
	Timer(doit(rch, my_spinner), 0, interval = seconds_per_frame)
end

# Add spinner start up and clean up to user expression
macro spinner()
        @info("An expression is required (e.g., `@spinner sleep(4)`).")
end
macro spinner(inputs...)
	return quote
		# Add start up before user expression
		hide_cursor()
		local T = fetch(Threads.@spawn :interactive timer_spin($(inputs[1:end-1]...)))

		# User expression
		$(esc(inputs[end]))

		# Add clean up after user expression
		close_spinner()
		show_cursor()
	end
end

end # module Spinners
