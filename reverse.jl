using DataFrames
using PreprocessMD
using Distributed

df = DataFrame(a=rand(1000), b=rand(1:10, 1000))
pivot(df)

# Add a worker
(w,) = addprocs(1)

# Assign work
@everywhere function f()
	while true
		print("_")
		flush(stdout)
		sleep(0.1)
	end
end
remotecall(f, w)

s = 0
for i in 10_000_000:10_000_010
	x = BigInt(999)^i % 17
end
rmprocs(w)
print(s)



