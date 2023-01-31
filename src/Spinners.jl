"""
# Exported names:
- `@spinner`
Please see `?@spinner` for more information.
"""
module Spinners

using Unicode: graphemes
using Unicode: transcode

export @spinner, spinner

@enum Status starting=1 running=2 finishing=3 closing=4 closed=5

const hide_cursor() = print("\u001B[?25l")
const show_cursor() = print("\u001B[0J", "\u001B[?25h")


default_user_function() = sleep(3)

function __start_up(s)

	hide_cursor()

	# Modify for statement based on input type
	if typeof(s) == String
		#for_statement = "for i in collect(\"$s\");"
		for_statement = "V = collect(\"$s\");"
		cleanup_statement = "print(\"\\b\"^length(transcode(UInt16, string(last(\"$s\")))));"
	elseif typeof(s) == Vector{String}
		#for_statement = "for i in $s;"
		for_statement = "V = $s;"
		cleanup_statement = "print(\"\\b\"^length(transcode(UInt16, last($s))));"
	end

	# Prime the loop so that print steps can be consolidated
	first = s[1]

	# Assemble command to produce spinner
	command =
	"let;" *
		"print(\"$first\");" *
		for_statement *
		"L = length(V);" *
		"i=1;" *
		"t=Threads.@async read(stdin, Char);" *
		"while !istaskdone(t);" *
			#for_statement *
			"while !istaskdone(t);" *
				"try;" *
					"print(\"\\b\"^length(transcode(UInt16, string(V[i])))*V[i]);" *
					#"print(\"\\b\"^length(transcode(UInt16, \"\$i\"))*\"\$i\");" *
				"finally;" *
					"flush(stdout);" *
				"end;" *
				"sleep(0.125);" *
				"i == L ? i = 1 : i += 1;" *
			"end;" *
			#"end;" *
		"end;" *
	"end;" *
	cleanup_statement;

	# Display the spinner as an external program
	proc_input = Pipe()
	proc = run(pipeline(`julia -e $command`, stdin = proc_input, stdout = stdout, stderr = stderr), wait = false)
	return proc, proc_input
end

function __clean_up(p, proc_input, s)
	write(proc_input,'c')

	# Wait for process to terminate, if needed.
	while process_running(p)
		sleep(0.1)
	end
	sleep(0.1)
	flush(stdout)

	show_cursor()
end

get_named_string(x::Symbol) = get(SPINNERS, x, "? ")

include("Definitions.jl")
# Add dictionaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

#= Outdated functions and macros for interactive tasks


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
=#

"""
# @spinner
Create a command line spinner
## Usage
```
@spinner expression          # Use the default spinner
@spinner "string" expression # Iterate through the graphemes of a string
@spinner :symbol expression  # Use a built-in spinner
```
## Available symbols
`:arrow`, `:bar`, `:blink`, `:bounce`, `:cards`, `:clock`, `:dots`, `:loading`, `:moon`, `:pong`, `:shutter`, `:snail`
"""
macro spinner()
	quote
		@spinner default_user_function()
	end
end
macro spinner(x::QuoteNode)
	quote
		local s = get_named_string($x)
		local p, proc_input = __start_up(s)
	os = stdout;
	(rd, wr) = redirect_stdout();
		if(isinteractive())
			show(default_user_function())
		else
			default_user_function()
		end
		__clean_up(p, proc_input, s)
	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	print( output )
	end
end
macro spinner(x::QuoteNode, f)
	quote
		local s = get_named_string($x)
		local p, proc_input = __start_up(s)
	os = stdout;
	(rd, wr) = redirect_stdout();
		return_value = $(esc(f))
		if(isinteractive() && !isnothing(return_value))
			show($(esc(f)))
		end
		__clean_up(p, proc_input, s)
	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	print( output )
	end
end
macro spinner(s::String, f)
	quote
		local p, proc_input = __start_up($s)
	os = stdout;
	(rd, wr) = redirect_stdout();
		return_value = $(esc(f))
		if(isinteractive() && !isnothing(return_value))
			show($(esc(f)))
		end
		__clean_up(p, proc_input, $s)
	redirect_stdout(os);
	close(wr);
	output = read(rd, String)
	print( output )
	end
end
macro spinner(f)
	quote
		@spinner "◒◐◓◑" $(esc(f))
	end
end
macro spinner(s::String)
	quote
		@spinner $s default_user_function()
	end
end






end # module Spinners
