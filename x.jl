using IterTools

@async sum(rand(100_000_000))
c = stdout;
for i in ncycle("\\|/-", 10)
	write(c, "$i");
	flush(c)
	sleep(0.1)
	write(c, "\b")
end
