module Spinners

export spinner

	function spinner(
		string::Union{String, Nothing}=nothing,
		time::Union{AbstractFloat, Nothing}=nothing,
		)

	if isnothing(string)
		string = "\\|/-"
	end

	if isnothing(time)
		time = 0.1
	end

		t = @async sleep(4)

		i = 0
		while !istaskdone(t)
			print(string[ ( i % length(string)  ) + 1 ])
			sleep(time)
			print("\b")
			i = i + 1
		end
		println()
	end

end # module Spinners
