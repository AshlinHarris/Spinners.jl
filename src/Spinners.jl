# https://docs.julialang.org/en/v1/manual/strings/

#Issues
# Can't use multiple spinners
#	@spinner :moon @spinner
# Some issues with Unicode may be due to Windows terminal
# Reliance on ANSI escape sequences
# Avoid ANSI with Base.transcode?
# What if the task also prints?
# Ensure that input string is UTF-16
	# Notice that the code depends on some particular ANSI escape sequences.

#Issues for later versions:
# Add moving spinner?
# Add mode=:flip (playing cards)
# Display multiple spinners
# Display larger spinners (at least wider)
# Documentation
#	\U, escape forms, s[begin], s[end]
#	use length(s) for number of characers
#	collect(eachindex(s))
#	careful with concatenation

module Spinners

using Unicode: transcode

export @spinner

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

const default_user_function() = sleep(3)

function get_named_string(x::Symbol)::String
	if x == :arrow
		s = "←↖↑↗→↘↓↙"
	elseif x == :bar
		s = "▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
	elseif x == :blink
		s="⊙⊙⊙⊙⊙⊙⊙◡"
	elseif x == :dots
		s = join([Char(i) for i in 0x2801:0x28ff])
		#  @show map(Unicode.julia_chartransform, x for x in s)
	elseif x == :moon
		s="🌑🌒🌓🌔🌕🌖🌗🌘"
	elseif x == :shutter
		s = "▉▊▋▌▍▎▏▎▍▌▋▊▉"
	else
		s = "? "
	end

	return s
end

function __start_up(s)

	hide_cursor()

	c = "while true;" *
	"for i in collect(\"$s\");" *
	"print(\"\$i\");" *
	"sleep(0.125);" *
	"print(\"\\b\"^length(transcode(UInt16, \"\$i\")));" *
	"end;" *
	"end"

	# Display the spinner as an external program
	return run(pipeline(` julia -e $c`, stdout), wait=false)
end

function __clean_up(p, s)
	kill(p)

	# Calculate the number of spaces needed to overwrite the printed character
	# Notice that this might exceed the required number, which could delete preceding characters
	amount = maximum(length.(transcode.(UInt8, "$x" for x in collect(s))))
	print(BACKSPACE^amount * " "^amount * BACKSPACE^amount)

	show_cursor()
end

macro spinner(x::QuoteNode)
	quote
		local p
		local s = get_named_string($x)
		try
			p = __start_up(s)
			default_user_function()
		finally
			__clean_up(p, s)
		end
	end
end
macro spinner(x::QuoteNode, f)
	quote
		local p
		local s = get_named_string($x)
		try
			p = __start_up(s)
			$(esc(f))
		finally
			__clean_up(p,s)
		end
	end
end
macro spinner()
	quote
		@spinner default_user_function()
	end
end
macro spinner(s::String, f)
	quote
		local p
		try
			p = __start_up($s)
			$(esc(f))
		finally
			kill(p)
			show_cursor()
		end
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

