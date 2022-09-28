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
		local p = __start_up(s)
		default_user_function()
		__clean_up(p, s)
	end
end
macro spinner(x::QuoteNode, f)
	quote
		local s = get_named_string($x)
		local p = __start_up(s)
		$(esc(f))
		__clean_up(p,s)
	end
end
macro spinner(s::String, f)
	quote
		local p = __start_up($s)
		$(esc(f))
		__clean_up(p,$s)
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

# Assemble the global Spinner dictionnary from SpinnerDefinitions.jl
include("SpinnerDefinitions.jl")
# Add dictionnaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

end # module Spinners
