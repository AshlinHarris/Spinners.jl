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

@enum Status starting=1 running=2 finishing=3 closing=4 closed=5

# Spinner struct
Base.@kwdef mutable struct Spinner
	status::Status = starting
	style::Vector{String} = ["◒","◐","◓","◑"] |> collect .|> string
	mode::Symbol = :none
	seconds_per_frame::Real = 0.2
	frame::Unsigned = 1
end

# Functions on spinner types

function get_grapheme(spinner::Spinner)
	s = spinner.style
	i = spinner.frame

	return s[(i)%length(s)+1]
end

function erase_grapheme(spinner::Spinner)
	c = get_grapheme(spinner)

	print("\b"^textwidth(c) *
		" "^textwidth(c) *
		"\b"^textwidth(c) )

	return
end

function increment_frame!(S::Spinner)
	if S.mode == :rand || S.mode == :random
		S.frame = rand(filter((x) -> x!= S.frame, 1:length(S.style)))
	else
		S.frame+=1
	end
end

# Signaling spinners

rch = [RemoteChannel(()->Channel(1), 1) for _ in 1:nprocs()];

const STOP_SIGNAL = 42
function signal_to_close!()
	#println("SENDING STOP SIGNAL!")
	put!(rch[1], STOP_SIGNAL)
end
function stop_signal_found()
	ch = rch[myid()]
	if isready(ch)
		signal_found = take!(ch)
		#println("FOUND $signal_found")
		return signal_found == STOP_SIGNAL
	else
		return false
	end
	
end

const hide_cursor() = print("\u001B[?25l")
const show_cursor() = print("\u001B[0J", "\u001B[?25h")

get_named_string(x::Symbol) = get(SPINNERS, x, "? ")

include("Definitions.jl")
# Add dictionaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

function pop_first_by_type!(inputs, type, default)
	if isempty(inputs)
		return default
	end

	location = [isa(x, type) for x in inputs] |> findfirst
	return isnothing(location) ? default : popat!(inputs, location)
end

function generate_spinner(inputs)::Spinner
	
	# The first input must be the style
	raw_s = isempty(inputs) ? "◒◐◓◑" : popfirst!(inputs)
	# Then the first Number must be the rate
	seconds_per_frame = pop_first_by_type!(inputs, Number, 0.2)
	# Then the first remaining Symbol must be the mode
	mode = pop_first_by_type!(inputs, Symbol, :none)
	# The first remaining string must be the message
	msg = pop_first_by_type!(inputs, String, "")

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
		status=starting,
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

			# Stop or print next
			if(stop_signal_found())
				S.status=closing
			end
			if S.status == starting
				hide_cursor()
				print(get_grapheme(S))
				increment_frame!(S)
				S.status = running
			elseif S.status == running
				erase_grapheme(S)
				increment_frame!(S)
				next = get_grapheme(S)
				print(next)
			#elseif S.status == finishing
			#	;
			elseif S.status == closing
				# Clean up
				erase_grapheme(S)
				show_cursor()
				S.status = closed
			end
		end
	end

	inputs = collect(parameters)
	my_spinner = generate_spinner(inputs)

	my_timer = Timer(doit(rch, my_spinner),
		0, # Delay
		interval=my_spinner.seconds_per_frame);
	
	while my_spinner.status != closed
		sleep(0.2)
	end

	close(my_timer)
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
		local T = Threads.@spawn :interactive timer_spin($(inputs[1:end-1]...));

		# User expression
		$(esc(inputs[end]))

		# Close spinner
		signal_to_close!()
		wait(T)
	end
end

end # module Spinners
