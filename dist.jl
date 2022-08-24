using Distributed
(w,) = addprocs(1)

#using DataFrames
#using PreprocessMD

#df = DataFrame(a=rand(1000), b=rand(1:10, 1000))

@everywhere function f()
	sleep(0.1)
	s = 0
	for i in 10_000_000:10_000_001
		s += BigInt(999)^i % 17
	end
	sleep(0.1)

	return s
end

@everywhere function g(c, d)
	return (c, d)
end

r = Future()
@async put!(r, remotecall_fetch(f, w))
#@async put!(r, remotecall_fetch(g, w, 2, 3))
#
#@async put!(r, remotecall_fetch(pivot, w, df))
#@async put!(r, remotecall_fetch(, w, "test"))

while !isready(r)
	print("_")
	flush(stdout)
	sleep(0.1)
end

println()
println(fetch(r))

rmprocs(w)

