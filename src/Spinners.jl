module Spinners

export spinner

	function spinner(string)
		i = 0
		while true
		#for i in 1:length(string)
			print(string[ ( i % length(string)  ) + 1 ])
			sleep(0.5)
			print("\b")
			i = i + 1
		end
		println()
	end

end # module Spinners
