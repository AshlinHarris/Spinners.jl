module Spinners

export spinner

function spinner(
	t::Union{Task, Nothing}=nothing,
	string::Union{String, Nothing}=nothing,
	time::Union{AbstractFloat, Nothing}=nothing;
	mode::Union{Symbol, Nothing}=nothing,
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

	if mode == :spin
		# Spinner
		i = 0
		while !istaskdone(t)
			print("\b", string[ ( i % length(string)  ) + 1 ])
			sleep(time)
			i = i + 1
		end
		println()
	elseif mode == :unfurl
		# Spinner
		i = 0
		while !istaskdone(t)
			l = length(string)
			m = ( i % l + 1)
			if m == 1
				sleep(time*3)
				print("\b" ^ l * " " ^ l * "\b" ^ l)
			end
			print(string[ m  ])
			sleep(time)
			i = i + 1
		end
		println()
	end
end

end # module Spinners
