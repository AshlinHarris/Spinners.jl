module Spinners

using Unicode: transcode

export @spinner

const BACKSPACE = '\b'
const ANSI_ESCAPE = '\u001B'

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")
const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

const default_user_function() = sleep(3)

function get_named_string(x::Symbol)

# Design principles
# Respect the attention and focus of the user
#	Spinners are designed to grab attention, so use them judiciously.
# Animation should begin immediately
# 	If there is a long pause at the start, the user might think there is an issue.
#	:snail might need to be removed for this reason...


	if x == :arrow
		s = "←↖↑↗→↘↓↙"
	elseif x == :bar
		s = "▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
	elseif x == :blink
		s="⊙◡⊙⊙◡⊙⊙⊙⊙⊙⊙⊙"
	elseif x == :bounce
		s=[
			"(●    )"
			"( ●   )"
			"(  ●  )"
			"(   ● )"
			"(    ●)"
			"(   ● )"
			"(  ●  )"
			"( ●   )"
		]
	elseif x == :cards
		s=[
			"🂠🂠🂠🂠🂠",
			"🂪🂠🂠🂠🂠",
			"🂪🂫🂠🂠🂠",
			"🂪🂫🂭🂠🂠",
			"🂪🂫🂭🂮🂠",
			"🂪🂫🂭🂮🂱",
			"🂪🂫🂭🂮🂱",
			"🂪🂫🂭🂮🂱",
			"🂪🂫🂭🂮🂱",
			"🂠🂫🂭🂮🂱",
			"🂠🂠🂭🂮🂱",
			"🂠🂠🂠🂮🂱",
			"🂠🂠🂠🂠🂱",
			"🂠🂠🂠🂠🂠",
			"🂠🂠🂠🂠🂠",
			"🂠🂠🂠🂠🂠",
			"🂠🂠🂠🂠🂠",
		]
	elseif x == :clock
		s = join([Char(i) for i in 0x1f550:0x1f55b])
	elseif x == :dots
		s = join([Char(i) for i in 0x2800:0x28ff])
		#  @show map(Unicode.julia_chartransform, x for x in s)
		# or just collect(s)
	elseif x == :loading
		s=[
			"Loading.    ",
			"Loading..   ",
			"Loading...  ",
			"Loading.... ",
			"Loading.....",
			"Loading.....",
			"Loading.....",
			"Loading.....",
		]

	elseif x == :moon
		s="🌑🌒🌓🌔🌕🌖🌗🌘"
	elseif x == :pong # https://github.com/sindresorhus/cli-spinners
		s = [
			"▐⠂       ▌",
			"▐⠈       ▌",
			"▐ ⠂      ▌",
			"▐ ⠠      ▌",
			"▐  ⡀     ▌",
			"▐  ⠠     ▌",
			"▐   ⠂    ▌",
			"▐   ⠈    ▌",
			"▐    ⠂   ▌",
			"▐    ⠠   ▌",
			"▐     ⡀  ▌",
			"▐     ⠠  ▌",
			"▐      ⠂ ▌",
			"▐      ⠈ ▌",
			"▐       ⠂▌",
			"▐       ⠠▌",
			"▐       ⡀▌",
			"▐      ⠠ ▌",
			"▐      ⠂ ▌",
			"▐     ⠈  ▌",
			"▐     ⠂  ▌",
			"▐    ⠠   ▌",
			"▐    ⡀   ▌",
			"▐   ⠠    ▌",
			"▐   ⠂    ▌",
			"▐  ⠈     ▌",
			"▐  ⠂     ▌",
			"▐ ⠠      ▌",
			"▐ ⡀      ▌",
			"▐⠠       ▌"
		]
	elseif x == :shutter
		s = "▉▊▋▌▍▎▏▎▍▌▋▊▉"
	elseif x == :snail
		s = ["🐌        🏁"]
	else
		s = "? "
	end

	return s
end

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
	flush(stdout)

	# Calculate the number of spaces needed to overwrite the printed character
	# Notice that this might exceed the required number, which could delete preceding characters
	amount = maximum(length.(transcode.(UInt8, "$x" for x in collect(s))))
	print(BACKSPACE^amount * " "^amount * BACKSPACE^amount)

	show_cursor()
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
macro spinner()
	quote
		@spinner default_user_function()
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

end # module Spinners

