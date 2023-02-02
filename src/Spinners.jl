module Spinners

using Unicode: graphemes

export @spinner, spinner

Base.@kwdef mutable struct Spinner
	#status::Status = starting
	style::Vector{String} = ["◒","◐","◓","◑"]
	mode::Symbol = :none
	seconds_per_frame::Real = 0.15
	frame::Unsigned = 1
end


include("Definitions.jl")
# Add dictionaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)
function get_named_string_vector(x::Symbol)::Vector{String}
	value = get(SPINNERS, x, "? ")
	return isa(value, String) ? string_to_vector(value) : value
end

string_to_vector(s) = string.(collect(graphemes(s)))

default_user_function() = sleep(3)

function __spinner(S)

s=S.style
seconds_per_frame = S.seconds_per_frame

	# Assemble command to produce spinner
	command = "
		try
			V = $s
			print(\"\\u001B[?25l\", V[1]) # hide cursor

			function clean_up(c) # Erase spinner
					print(
						\"\\b\"^textwidth(c),
						\" \"^textwidth(c),
						\"\\b\"^textwidth(c),
					)
			end

			L = length(V) # declaring this const keeps the spinner from drawing?
			iterator_to_index(i) = (i - 1) % L + 1
			
			i = 1
			t=Threads.@async read(stdin, Char)
			while true
				try
					prev = iterator_to_index(i)
					i += 1
					curr = iterator_to_index(i)
					print(\"\\b\"^textwidth(V[prev])*V[curr])

					if istaskdone(t)
						clean_up(V[prev])
						quit()
					end

				catch InterruptException
					curr = iterator_to_index(i)
					clean_up(V[curr])
					quit()
				finally
				end
				sleep($seconds_per_frame)
			end
		finally
			print(\"\\u001B[0J\", \"\\u001B[?25h\") # Restore cursor
		end
	"

	# Display the spinner as an external program
	proc_input = Pipe()
	proc = run(pipeline(`julia -e $command`, stdin = proc_input, stdout = stdout), wait = false)
	return proc, proc_input
end

macro spinner()
	quote
		@spinner ["◒", "◐", "◓", "◑"] default_user_function()
	end
end
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
	seconds_per_frame = pop_first_by_type!(inputs, Number, 0.15)
	# Then the first remaining Symbol must be the mode
	mode = pop_first_by_type!(inputs, Symbol, :none)
	# The first remaining string must be the message
	msg = pop_first_by_type!(inputs, String, "")

	s = 
		if(isa(raw_s, Symbol))
			 get_named_string_vector(raw_s)
		elseif(isa(raw_s, String))
			string_to_vector(raw_s)
		else
			raw_s
		end

	# Append messages to each frame
	s .*= msg

	return Spinner(
		style=s,
		mode=mode,
		seconds_per_frame=seconds_per_frame,
	)
end

macro spinner(args...)
	quote
		local s = generate_spinner(collect(eval.([$args[1:end-1]...])))
		#generate_spinner(args[1:end-1])
		local p, proc_input = __spinner(s)
	os = stdout;
	(rd, wr) = redirect_stdout();
		return_value = $(esc(args[end]))
		if(isinteractive() && !isnothing(return_value))
			show(return_value)
		end
		write(proc_input,'c')

	while(process_running(p))
		sleep(0.1)
	end

	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	print(output)
	end
end

end # module Spinners

#= Outdated functions and macros for interactive tasks

@enum Status starting=1 running=2 finishing=3 closing=4 closed=5

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

=#
