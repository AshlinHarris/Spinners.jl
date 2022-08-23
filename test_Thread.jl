# julia --threads=2

const x = Channel()

using Base.Threads;
Threads.@spawn println(threadid()) && put!(x, "done")
Threads.@spawn println(threadid()) && put!(x, "done")

print(take!(x))
print(take!(x))

# close channel?

exit()
