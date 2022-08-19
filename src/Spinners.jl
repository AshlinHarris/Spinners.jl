module Spinners

export spinner

	function spinner(string)

		#a = sleep(7)
		#t = Task(a)
		t = @async sleep(4)
		#schedule(t)
		#yield()

		i = 0
		while !istaskdone(t)
			print(string[ ( i % length(string)  ) + 1 ])
			sleep(0.5)
			print("\b")
			i = i + 1
		end
		println()
	end

end # module Spinners
