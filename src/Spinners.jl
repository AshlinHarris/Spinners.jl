"""
# Exported names:
- `@spinner`

Please see `?@spinner` for more information.
"""
module Spinners

using Base.Threads
using Distributed
using Unicode: transcode

export @spinner, spinner

rch = [RemoteChannel(()->Channel(1), 1) for _ in 1:nprocs()]

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

get_named_string(x::Symbol) = get(SPINNERS, x, "? ")

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
#! TODO Macros to rewrite


# Is the return needed ? one can use : var = @spinner :clock "messsage" expr
macro spinner(inputs...)
	_check_inputs(inputs)
	return quote

		hide_cursor()

		local T = fetch(Threads.@spawn :interactive timer_spin($(inputs[1:end-1]...)))

		res = $(esc(inputs[end]))

		put!(rch[1], 42)

		show_cursor()

		res

	end
end

# if i want a spinner for foo(5) then type spinner(:clock, foo, (5))
function spinner(style::Union{Symbol, String, Vector{String}} = :clock, action::Union{Function} = quote sleep(3) end, args=nothing; msg::String="")

        #TODO error management (@warn ...)
		hide_cursor()

        local T = fetch(Threads.@spawn :interactive timer_spin(style, msg))

        if typeof(action) == Expr
            res = eval(action)
        else
            if args!=nothing
                res = action(args)
            else
                res = action()
            end
        end

		put!(rch[1], 42);
		show_cursor()

		return res

end

# Assemble the global Spinner dictionnary from SpinnerDefinitions.jl
include("SpinnerDefinitions.jl")
# Add dictionaries in the merge process when adding a new set of spinners
SPINNERS = merge(custom, sindresorhus)

function timer_spin(raw_s, msg="")
    #! TODO implement right custom text
	if typeof(raw_s) == Symbol
		s = get_named_string(raw_s) |> collect
	elseif typeof(raw_s) == String
		s = collect(raw_s)
	else
		s = raw_s
	end

	# Callback function
	function doit(i, rch)
	    (timer) -> begin

		# Check for a stop signal (42) on this channel
		ch = rch[myid()]
		stop = isready(ch) && take!(ch) == 42

		if(stop)
			# Clean up and close
			print("\b"^length(transcode(UInt16, string(s[(i)%length(s)+1]))))
			close(timer)
		else
			# Clean up and print next
			print("\b"^length(transcode(UInt16, string(s[(i)%length(s)+1])))*s[(i+1)%length(s)+1])
			i+=1
		end

	    end
	end

	i=1
	print(s[1])
	Timer(doit(i, rch), 0, interval = 0.2)
end

function _check_inputs(inputs)
	#! To implement
end


end # module Spinners
