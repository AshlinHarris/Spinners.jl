"""
`Spinners.jl` provides a single macro (@spinner), which generates a terminal spinner.

For user instructions, see the internal documentation (`?@spinner`).
"""
module Spinners

using Test: @test_throws
using Unicode: graphemes

export @spinner

default_user_function() = sleep(3)
const default_spinner_animation = ["◒", "◐", "◓", "◑"]

struct Spinner
	style::Vector{String}
	mode::Symbol
	seconds_per_frame::Real
end

include("Definitions.jl")

string_to_vector(s) = string.(collect(graphemes(s)))

function __spinner(S)

	s=S.style
	seconds_per_frame = S.seconds_per_frame
	if_rand = (S.mode == :rand)

	# Assemble command to produce spinner
	command = raw"""
		const ANSI = Dict{Symbol,String}(
			:hide_cursor => "\u001B[?25l",
			:show_cursor => "\u001B[0J\u001B[?25h",
		)

		function clean_up(c) # Erase spinner
			w = textwidth(c)
			print("\b" ^ w, " " ^ w, "\b" ^ w)
		end
	""" * "
		try
			V = $s
			x = $seconds_per_frame
			r = $if_rand
	" * raw"""
			print(ANSI[:hide_cursor], V[1])

			L = length(V) # declaring this const keeps the spinner from drawing?
			iterator_to_index(i) = (i - 1) % L + 1
			
			i = 1
			t=Threads.@async read(stdin, Char)
			keep_going = true
			while keep_going
				# Get previous and current frames
				prev = iterator_to_index(i)
				i += r ? rand(1:L-1) : 1
				curr = iterator_to_index(i)

				clean_up(V[prev])
				print(V[curr])

				if istaskdone(t)
					clean_up(V[curr])
					keep_going = false
				end

				sleep(x)
			end
		catch InterruptException
			print(ANSI[:show_cursor])
		finally
			print(ANSI[:show_cursor])
		end
	"""

	# Display the spinner as an external program
	proc_input = Pipe()
	proc = run(pipeline(`$(Base.julia_cmd()) -e $command`, stdin = proc_input, stdout = stdout, stderr = stderr), wait = false)
	return proc, proc_input
end

function generate_spinner(inputs)::Spinner

	set_of_modes = Set([:none, :rand])

	# The user's function is already removed
	# Pop the first Symbol that matches the set of possible modes
	#mode = pop_first_by_type!(inputs, Symbol, :none)
	mode = :none
	for i in eachindex(inputs)
		if inputs[i] ∈ set_of_modes
			mode = splice!(inputs,i)
			break
		end
	end
		
	# The first remaining input must be the style
	raw_s = isempty(inputs) ? "◒◐◓◑" : popfirst!(inputs)
	# Then the first Number must be the rate
	seconds_per_frame = pop_first_by_type!(inputs, Number, 0.15)
	# The first remaining string must be the message
	msg = pop_first_by_type!(inputs, String, "")

	if(isa(raw_s, Symbol))
		s = copy(get(list, raw_s::Symbol, ["?"," "]))::Vector{String}
	elseif(isa(raw_s, String))
		s = string_to_vector(raw_s)::Vector{String}
	else
		s = raw_s::Vector{String}
	end

	# Append messages to each frame
	s .*= msg

	return Spinner(s, mode, seconds_per_frame)
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
macro spinner(x::QuoteNode, y::QuoteNode)
	quote
		@spinner $x $y default_user_function()
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
		# Draw spinner
		local s = generate_spinner(collect(eval.([$args[1:end-1]...])))
		#generate_spinner(args[1:end-1])
		local p, proc_input = __spinner(s)

		# Block user input other than stop signals
		function raw_mode(b)
			ccall(:jl_tty_set_mode,Int32, (Ptr{Cvoid},Int32), stdin.handle, b)
		end
		function block_user_input(proc_input)
			raw_mode(true)
			#ret == 0 || error("unable to switch to raw mode")
			while read(stdin, Char) ∉ Set(['\x03', '\x04', '\e']) end
			write(proc_input,'c')
			raw_mode(false)
		end
		local t = Base.@async block_user_input(proc_input)

		# Run user's original command
		return_value = $(esc(args[end]))
		if(isinteractive() && !isnothing(return_value))
			show(return_value)
		end

		# Close spinner
		write(proc_input,'c')

		# Stop blocking user input (if not closed by user)
		ex = InterruptException()
		!istaskdone(t) && @test_throws InterruptException Base.throwto(t, ex) && raw_mode(false)

		while(process_running(p))
			sleep(0.1)
		end

	end
end

end # module Spinners

