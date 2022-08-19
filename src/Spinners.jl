module Spinners

export spinner

function spinner(
	t::Union{Task, Nothing}=nothing,
	string::Union{String, Nothing}=nothing,
	time::Union{AbstractFloat, Nothing}=nothing,
	)

	# Assign missing arguments
	if isnothing(t)
		t = @async sleep(3)
	end
	if isnothing(string)
		string = "\\|/-"
	end
	if isnothing(time)
		time = 0.1
	end

	# Spinner
	i = 0
	while !istaskdone(t)
		print("\b", string[ ( i % length(string)  ) + 1 ])
		sleep(time)
		i = i + 1
	end
	println()
end

end # module Spinners
