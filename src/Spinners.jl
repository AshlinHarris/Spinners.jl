# https://docs.julialang.org/en/v1/manual/strings/

#Issues for 0.1
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

export spinner, @spinner

const BACKSPACE = '\b' # '\U8' == '\b'
const ANSI_ESCAPE = '\u001B'

function clear_field(s::String, blank::String)
	print(blank^length(s), BACKSPACE^length(s))
end

function erase_display(s::String, blank::String)
	print(BACKSPACE^length(transcode(UInt16, s)), blank^length(s), BACKSPACE^(length(transcode(UInt16, blank^length(s) ))))
end

function get_element(s::Vector, i::Int)
	return string(s[i])
end

const hide_cursor() = print(ANSI_ESCAPE, "[?25l")

function task_is_still_running(t::Task)
	return !istaskdone(t)
end

function overwrite_display(old::String, new::String, blank::String)
	erase_display(old, blank)
	print(new)
end

function pause_animation(s)
	sleep(s)
end

const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

"""
	function spinner(t, string, time)
Add column to a DataFrame based on symbol presence in the target DataFrame
# Arguments
- `t::Union{Task, Nothing}`: The spinner is shown until this task terminates.
- `string::Union{String, Symbol, Nothing}`: Cycle through the characters in this string. For convenience, some example strings can be selected with a symbol: :arrow, :bar, :blink, :dots, :moon, :pinwheel, :shutter
- `time::Union{Number, Nothing}`: Number of seconds per frame
# Options
- `mode::Union{Symbol, Nothing}`: :spin, :random, or :unfurl
- `before::Union{String, Nothing}`: Text to display in front of the spinner
- `after::Union{String, Nothing}`: Text to display after the spinner has finished
- `blank::Union{String, Nothing}`: Character to be treated as a blank
- `cleanup::Union{Bool, Nothing}`: Erase the spinner after it has finished?
"""

function spinner(
	t::Union{Task, Nothing}=nothing,
	string::Union{String, Symbol, Nothing}=nothing,
	time::Union{Number, Nothing}=nothing;
	mode::Union{Symbol, Nothing}=nothing,
	before::Union{String, Nothing}=nothing,
	after::Union{String, Nothing}=nothing,
	blank::Union{String, Nothing}=nothing,
	cleanup::Union{Bool, Nothing}=nothing,
	)

	# Assign missing arguments
	if isnothing(t)
		t = @async sleep(3)
	end
	# Declare raw_string in this scope?
	if typeof(string) == String
		raw_string = string
	elseif isnothing(string) || string == :pinwheel
		raw_string = "\\|/-"
	elseif string == :arrows
		raw_string = "←↖↑↗→↘↓↙"
	elseif string == :bar
		raw_string = "▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
	elseif string == :blink
		raw_string="⊙⊙⊙⊙⊙⊙⊙⊙⊙◡"
	elseif string == :dots
		raw_string = join([Char(i) for i in 0x2801:0x28ff])
		#  @show map(Unicode.julia_chartransform, x for x in s)
	elseif string == :moon
		raw_string="🌑🌒🌓🌔🌕🌖🌗🌘"
	elseif string == :shutter
		raw_string = "▉▊▋▌▍▎▏▎▍▌▋▊▉"
	else
		#error
	end
	if isnothing(time)
		time = 0.25
	end
	if isnothing(mode)
		mode = :spin
	end
	if isnothing(before)
		before = ""
	else
		print(before)
	end
	if isnothing(blank)
		blank = " "
	end
	if isnothing(cleanup)
		cleanup = true
	end
	if isnothing(after)
		#after = get_element(v_string, 1);
		after = "✔️"
	end

	v_string = collect(raw_string)

	hide_cursor()
	try

		clear_field(raw_string, blank)

		l = length(raw_string)

		STR_TO_DELETE = ""
		print(STR_TO_DELETE) # initial blank (deleted within loop)

		if mode == :spin
			# Spinner
			i = 0
			while task_is_still_running(t)
				next_char = get_element(v_string, ( i % l)  + 1 ) * " "
				overwrite_display(STR_TO_DELETE, next_char, blank)
				pause_animation(time)
				STR_TO_DELETE = next_char
				i = i + 1
			end
		elseif mode == :random || mode == :haphazard || mode == :rand
			if l > 1
				# Spinner
				i = rand(1:l)
				while task_is_still_running(t)
					next_char = get_element(v_string, i) * " "
					overwrite_display(STR_TO_DELETE, next_char, blank)
					pause_animation(time)
					STR_TO_DELETE = next_char
					i = rand(filter((x) -> x!= i, 1:l)) # Don't allow repeats
				end
			else
				print(get_element(v_string, 1))
			end
		elseif mode == :unfurl
			# Spinner
			# prime the loop
			overwrite_display(STR_TO_DELETE, get_element(v_string, 1), blank)
			pause_animation(time)
			i = 1
			while task_is_still_running(t) || i % l + 1 != 1 # Print the remainder of the v_string at the end
				m = ( i % l + 1)
				if m == 1
					pause_animation(time*3)
					erase_display(raw_string, blank)
				end
				print(get_element(v_string, m))
				pause_animation(time)
				i = i + 1
			end
			if isnothing(after)
				#after = v_string;
				after = "✔️"
			end
		else
			#error
		end

		# Print after string
		
		if cleanup == true
			overwrite_display(before*raw_string, after, blank)
		else
			println("\n",after)
		end

	#The cursor should always be set back to visible, even if there's an interruption.
	finally
		show_cursor()
	end
end

# spinner()
# julia> t = @async sleep(5); spinner(t, :moon, before="👀:")
# julia> t = @async sleep(5); spinner(t, :dots, 0.05, mode=:rand, after="⣿")
# t = @async sleep(5); spinner(t, :dots, 0.05, mode=:rand, after="⣿")
# julia> t = @async sleep(5); spinner(t, "........", 0.08, mode=:unfurl, before="Loading", after="Finished", cleanup=false)

function before()
	c = "while true;" *
	"for i in collect(\"◒◐◓◑\");" *
	"print(\"\$i\");" *
	"sleep(0.2);" *
	"print(\"\\b\"^length(transcode(UInt16, \"\$i\")));" *
	"end;" *
	"end"

	# Display the spinner as an external program
	return run(pipeline(` julia -e $c`, stdout), wait=false)
end

function after(p)
	kill(p)
	print("\b")
end

macro spinner(f)

	:( p = before(); $(esc(f)); kill(p); print("\b") )

end

end # module Spinners


