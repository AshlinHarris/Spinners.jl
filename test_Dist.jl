using Spinners 
using Pkg
Pkg.develop(path=".")

using Distributed
nworkers() < 2 && addprocs(2)

f1 = @spawnat 1 sum(rand(100_000_000))
f2 = @spawnat 2 using Spinners
f2 = @spawnat 2 spinner()

r = fetch(f1), fetch(f2)
