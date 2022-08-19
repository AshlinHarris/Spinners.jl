module Spinners

export spinner

get_element(s::String, i::Int) = s[i]

function spinner(
	t::Union{Task, Nothing}=nothing,
	string::Union{String, Nothing}=nothing,
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
	if isnothing(string)
		string = "\\|/-"
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
	

	l = length(string)

	print(" ") # initial blank (deleted within loop)

	if mode == :spin
		# Spinner
		i = 0
		sleep(time)
		while !istaskdone(t)
			print("\b", get_element(string, ( i % length(string)  ) + 1 ))
			sleep(time)
			i = i + 1
		end
		if isnothing(after)
			after = get_element(string, 1);
		end
	elseif mode == :random || mode == :haphazard
		if l > 1
			# Spinner
			i = rand(1:l)
			while !istaskdone(t)
				print("\b", get_element(string, i))
				sleep(time)
				i = rand(filter((x) -> x!= i, 1:l)) # Don't allow repeats
			end
			if isnothing(after)
				after = get_element(string, 1);
			end
		else
			print(get_element(string, 1))
		end
	elseif mode == :unfurl
		# Spinner
		# prime the loop
		print("\b", get_element(string, 1))
		i = 1
		while !istaskdone(t) || i % l + 1 != 1 # Print the remainder of the string at the end
			m = ( i % l + 1)
			if m == 1
				sleep(time*3)
				print("\b" ^ l * " " ^ l * "\b" ^ l)
			end
			print(get_element(string, m))
			sleep(time)
			i = i + 1
		end
		if isnothing(after)
			after = string;
		end
	else
		#error
	end

	# Print after string
	
	if cleanup == true
		println("\b" ^ ( l + length(before)), after)
	else
		println("\n",after)
	end
end

end # module Spinners
