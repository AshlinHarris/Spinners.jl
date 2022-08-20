#Issues:
# Add moving spinner?
# Add mode=:flip (playing cards)
# Fix the final cleanup step
# 	Differentiate between character to end on and ending message?
# The cursor should always be set back to visible, even if there's an interruption.
# Reliance on ANSI escape sequences
# What if the task also prints?
# Isn't there a better way to work with Unicode in Julia
# Display multiple spinners
# Display larger spinners (at least wider)

module Spinners

using IterTools: nth
using Unicode: graphemes

export spinner

function get_element(s::Vector, i::Int)
	s[i]
end
function get_element(s::String, i::Int)
	u = graphemes(s)
	return nth(u, i)
end

function spinner(
	t::Union{Task, Nothing}=nothing,
	string::Union{String, Symbol, Nothing}=nothing,
	time::Union{AbstractFloat, Nothing}=nothing;
	mode::Union{Symbol, Nothing}=nothing,
	before::Union{String, Nothing}=nothing,
	after::Union{String, Nothing}=nothing,
	cleanup::Union{Bool, Nothing}=nothing,
	)

	# Assign missing arguments
	if isnothing(t)
		t = @async sleep(3)
	end
	if isnothing(string) || string == :pinwheel
		raw_string = "\\|/-"
	elseif typeof(string) == String
		raw_string = string
	elseif string == :arrows
		raw_string = "←↖↑↗→↘↓↙"
	elseif string == :bars
		raw_string = "▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
	elseif string == :braille
		raw_string = braille="⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿"
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
	if isnothing(cleanup)
		cleanup = true
	end

	v_string = collect(raw_string)

	# Make cursor invisible
	# Notice that the code depends on some particular ANSI escape sequences.
	# Is that an issue?
	ESC = "\u001B"
	print("$ESC[?25l")

	l = length(v_string)

	STR_TO_DELETE = " "
	print(STR_TO_DELETE) # initial blank (deleted within loop)

	if mode == :spin
		# Spinner
		i = 0
		while !istaskdone(t)
			next_char = get_element(v_string, ( i % l)  + 1 ) * " "
			print("\b"^sizeof(STR_TO_DELETE), next_char)
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
				print("\b"^sizeof(STR_TO_DELETE), next_char)
				sleep(time)
				STR_TO_DELETE = next_char
				i = rand(filter((x) -> x!= i, 1:l)) # Don't allow repeats
			end
			if isnothing(after)
				#after = get_element(v_string, 1);
				after = ✔️
			end
		else
			print(get_element(v_string, 1))
		end
	elseif mode == :unfurl
		# Spinner
		# prime the loop
		print("\b"^sizeof(STR_TO_DELETE), get_element(v_string, 1))
		sleep(time)
		i = 1
		while !istaskdone(t) || i % l + 1 != 1 # Print the remainder of the v_string at the end
			m = ( i % l + 1)
			if m == 1
				sleep(time*3)
				print("\b" ^ sizeof(raw_string) * " " ^ sizeof(raw_string) * "\b" ^ sizeof(raw_string))
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
		println("\b" ^ ( sizeof(raw_string) + sizeof(before)),
		        " " ^ ( length(v_string)),
		        "\b" ^ ( length(v_string)),
		        after)
	else
		println("\n",after)
	end

	# Make cursor visibile
	print("$ESC[0J$ESC[?25h")
end

end # module Spinners
