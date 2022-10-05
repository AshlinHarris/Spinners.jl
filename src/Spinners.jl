"""
# Exported names:
- `@spinner`

Please see `?@spinner` for more information.
"""
module Spinners

using Unicode: transcode

export @spinner

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

const default_user_function() = sleep(3)

get_named_string(x::Symbol) = get(SPINNERS, x, "? ")

function __start_up(s)

	hide_cursor()

	# Modify for statement based on input type
	if typeof(s) == String
		for_statement = "for i in collect(\"$s\");"
	elseif typeof(s) == Vector{String}
		for_statement = "for i in $s;"
	end

	# Prime the loop so that print steps can be consolidated
	first = s[1]

	# Assemble command to produce spinner
	c =
	"print(\"$first\");" *
	"while true;" *
		for_statement *
			"try;" *
				"print(\"\\b\"^length(transcode(UInt16, \"\$i\"))*\"\$i\");" *
			"finally;" *
				"flush(stdout);" *
			"end;" *
			"sleep(0.125);" *
		"end;" *
	"end"

	# Display the spinner as an external program
	return run(pipeline(` julia -e $c`, stdout), wait=false)
end

function __clean_up(p, s)
	kill(p)

	# Wait for process to terminate, if needed.
	while process_running(p)
		sleep(0.1)
	end
	sleep(0.1)
	#=
	if process_running(p)
		sleep(0.01)
		if process_running(p)
			sleep(0.1)
			if process_running(p)
				sleep(1)
				if process_running(p)
					sleep(2)
					# Then just give up
					# I don't think any Julia release from this decade will typically end up here.
				end
			end
		end
	end
	=#

	flush(stdout)

	# Calculate the number of spaces needed to overwrite the printed character
	# Notice that this might exceed the required number, which could delete preceding characters
	amount = maximum(length.(transcode.(UInt8, "$x" for x in collect(s))))
	print(BACKSPACE^amount * " "^amount * BACKSPACE^amount)

	flush(stdout)

	show_cursor()
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
`:arrow`, `:bar`, `:blink`, `:bounce`, `:cards`, `:clock`, `:dots`, `:loading`, `:moon`, `:pong`, `:shutter`, `:snail`
"""
macro spinner(s, f)
	quote
		local T = timer_spin($s)
		$(esc(f))
		close(T)
	end
end

# Assemble the global Spinner dictionnary from SpinnerDefinitions.jl
include("SpinnerDefinitions.jl")
# Add dictionnaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

function timer_spin(raw_s)
	if typeof(raw_s) == Symbol
		s = get_named_string(raw_s) |> collect
	elseif typeof(raw_s) == String
		s = collect(raw_s)
	else
		s = raw_s
	end
	
	i=1
	print(s[1])
	cb(timer) = (
		i+=1;
		print("\b"^length(transcode(UInt16, string(s[(i-1)%length(s)+1])))*s[i%length(s)+1]);
	)
	return Timer(cb, 2, interval = 0.2)
end

end # module Spinners
