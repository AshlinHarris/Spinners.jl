module Spinners

export spinner

	function spinner(string, time)

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
