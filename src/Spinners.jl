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
	style::Vector{String} = ["◒","◐","◓","◑"]
	mode::Symbol = :none
	seconds_per_frame::Real = 0.2
	frame::Unsigned = 1
end

# Functions on spinner types

function render(rch, S::Spinner)
	(timer) -> begin
		# Stop or print next
		if(stop_signal_found())
			S.status=closing
		end

		if S.status == starting
			hide_cursor()
			print(get_frame(S))
			S.status = running
		elseif S.status == running
			next_frame!(S)
		#elseif S.status == finishing
			# a final success symbol such as "✅" could be displayed here
			# failure symbol: ❌
		elseif S.status == closing
			# Clean up
			clean_up_frame(S)
			show_cursor()
			S.status = closed
		end
	end
end

function get_frame(spinner::Spinner)
	s = spinner.style
	i = spinner.frame

	return s[(i)%length(s)+1]
end

function clean_up_frame(spinner::Spinner)
	width = get_frame(spinner) |> textwidth
	print("\b" ^ width * " " ^ width)
end

function next_frame!(S::Spinner)

	old = get_frame(S)

	if S.mode == :rand || S.mode == :random
		S.frame = rand(filter((x) -> x!= S.frame, 1:length(S.style)))
	else
		S.frame+=1
	end

	new = get_frame(S)

	print("\b"^textwidth(old) * new)

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
		style=s,
		mode=mode,
		seconds_per_frame=seconds_per_frame,
	)
end

function timer_spin()
	timer_spin("◒◐◓◑")
end
function timer_spin(parameters...)

	inputs = collect(parameters)
	my_spinner = generate_spinner(inputs)

	my_timer = Timer(render(rch, my_spinner),
		0, # Delay
		interval=my_spinner.seconds_per_frame);
	
	while my_spinner.status != closed
		sleep(0.1)
	end

	close(my_timer)
end

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
