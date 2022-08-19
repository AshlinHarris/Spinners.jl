module Spinners

export spinner

	function spinner(string)
		for i in 1:length(string)
			print(string[i])
			sleep(0.5)
			print("\b")
		end
		println()
	end

end # module Spinners
