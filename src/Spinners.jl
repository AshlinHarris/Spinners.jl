"""
`Spinners.jl` provides a single macro (@spinner), which generates a terminal spinner.

For user instructions, see the internal documentation (`?@spinner`).
"""
module Spinners

using Unicode: graphemes

export @spinner

const default_spinner_animation = ["◒", "◐", "◓", "◑"]
default_user_function() = sleep(3)

Base.@kwdef struct Spinner
	style::Vector{String} = default_spinner_animation
	#mode::Symbol = :none
	seconds_per_frame::Real = 0.15
end

include("Definitions.jl")

string_to_vector(s) = string.(collect(graphemes(s)))

function __spinner(S)

	s=S.style
	seconds_per_frame = S.seconds_per_frame

	# Assemble command to produce spinner
	command = "
		try
			V = $s
			x = $seconds_per_frame
	" * raw"""
			print("\u001B[?25l", V[1]) # hide cursor

			function clean_up(c) # Erase spinner
				w = textwidth(c)
				print("\b" ^ w, " " ^ w, "\b" ^ w)
			end

			L = length(V) # declaring this const keeps the spinner from drawing?
			iterator_to_index(i) = (i - 1) % L + 1
			
			i = 1
			t=Threads.@async read(stdin, Char)
			keep_going = true
			while keep_going
				try
					prev = iterator_to_index(i)
					i += 1
					curr = iterator_to_index(i)
					clean_up(V[prev])
					print(V[curr])

					if istaskdone(t)
						clean_up(V[curr])
						keep_going = false
					end

				catch InterruptException
					curr = iterator_to_index(i)
					clean_up(V[curr])
					keep_going = false
				finally
				end
				sleep(x)
			end
		finally
			print("\u001B[0J", "\u001B[?25h") # Restore cursor
		end
	"""

	# Display the spinner as an external program
	proc_input = Pipe()
	proc = run(pipeline(`julia -e $command`, stdin = proc_input, stdout = stdout, ), wait = false)
	return proc, proc_input
end

function generate_spinner(inputs)::Spinner

	# The first input must be the style
	raw_s = isempty(inputs) ? "◒◐◓◑" : popfirst!(inputs)
	# Then the first Number must be the rate
	seconds_per_frame = pop_first_by_type!(inputs, Number, 0.15)
	# Then the first remaining Symbol must be the mode
	#mode = pop_first_by_type!(inputs, Symbol, :none)
	# The first remaining string must be the message
	msg = pop_first_by_type!(inputs, String, "")

	s = 
		if(isa(raw_s, Symbol))
			copy(get(list, raw_s::Symbol, ["?"," "]))::Vector{String}
		elseif(isa(raw_s, String))
			string_to_vector(raw_s)
		else
			raw_s
		end

	# Append messages to each frame
	s .*= msg

	return Spinner(
		style=s,
		#mode=mode,
		seconds_per_frame=seconds_per_frame,
	)
end

"""
`@spinner`: Command line spinners with Unicode support

Usage: `@spinner [style] [rate] [message] function`

  - `style`: `String`, `Vector{String}`, or `Symbol`
    - See `Spinners.list` for the list of supported symbols
  - `rate`: seconds per frame
  - `message::String`: text displayed to the right of the spinner

Examples:
```
	@spinner
	@spinner :aesthetic
	@spinner "◧◨" 0.5 sleep(5)
```
"""
macro spinner()
	quote
		@spinner default_spinner_animation default_user_function()
	end
end
macro spinner(x::QuoteNode)
	quote
		@spinner $x default_user_function()
	end
end
macro spinner(s::String)
	quote
		@spinner string_to_vector($s) default_user_function()
	end
end
function pop_first_by_type!(inputs, type, default)
	if isempty(inputs)
		return default
	end

	location = [isa(x, type) for x in inputs] |> findfirst
	return isnothing(location) ? default : popat!(inputs, location)
end
macro spinner(n::Number)
	quote
		@spinner default_spinner_animation $n default_user_function()
	end
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

