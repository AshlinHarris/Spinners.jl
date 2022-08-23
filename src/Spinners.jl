
# https://docs.julialang.org/en/v1/manual/strings/

#Issues for 0.1
# Some issues with Unicode may be due to Windows terminal
# Reliance on ANSI escape sequences
# Avoid ANSI with Base.transcode?
# What if the task also prints?
# Does this slow down computation significantly?
# Ensure that input string is UTF-8
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

export spinner

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

function overwrite_display(old::String, new::String, blank::String)
	erase_display(old, blank)
	print(new)
end

const show_cursor() = print(ANSI_ESCAPE, "[0J", ANSI_ESCAPE, "[?25h")

function spinner(
	t::Union{Task, Nothing}=nothing,
	string::Union{String, Symbol, Nothing}=nothing,
	time::Union{AbstractFloat, Nothing}=nothing;
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
	elseif string == :bars
		raw_string = "▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
	elseif string == :dots
		raw_string = dots="⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿"
	elseif string == :blink
		raw_string="⊙⊙⊙⊙⊙⊙⊙⊙⊙◡"
	elseif string == :moon
		raw_string="🌑🌒🌓🌔🌕🌖🌗🌘"
	elseif string == :shutters
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
			while !istaskdone(t)
				next_char = get_element(v_string, ( i % l)  + 1 ) * " "
				overwrite_display(STR_TO_DELETE, next_char, blank)
				sleep(time)
				STR_TO_DELETE = next_char
				i = i + 1
			end
			if isnothing(after)
				#after = get_element(v_string, 1);
				after = "✔️"
			end
		elseif mode == :random || mode == :haphazard || mode == :rand
			if l > 1
				# Spinner
				i = rand(1:l)
				while !istaskdone(t)
					next_char = get_element(v_string, i) * " "
					overwrite_display(STR_TO_DELETE, next_char, blank)
					sleep(time)
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
			sleep(time)
			i = 1
			while !istaskdone(t) || i % l + 1 != 1 # Print the remainder of the v_string at the end
				m = ( i % l + 1)
				if m == 1
					sleep(time*3)
					erase_display(raw_string, blank)
				end
				print(get_element(v_string, m))
				sleep(time)
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

end # module Spinners
