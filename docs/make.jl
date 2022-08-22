using Spinners, Documenter
DocMeta.setdocmeta!(Spinners, :DocTestSetup, :(using DataFrames, Spinners); recursive=true)

makedocs(;
	modules=[Spinners],
	authors="Ashlin Harri",
	repo="https://github.com/AshlinHarris/Spinners.jl/blob/{commit}{path}#L{line}",
	sitename="Spinners.jl",
	pages=["Home" => "index.md"],
	strict=true,
	doctest=true, # Set doctest=:fix to revise the output of any failing tests
)

deploydocs(; repo="github.com/AshlinHarris/Spinners.jl", devbranch="main")
