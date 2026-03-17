using ForestEcology
using Documenter

DocMeta.setdocmeta!(ForestEcology, :DocTestSetup, :(using ForestEcology); recursive=true)

makedocs(;
    modules=[ForestEcology, ForestCore],
    remotes=nothing,
    authors="Marcos Daniel da Silva <marcosdasilva@5a.tec.br> and contributors",
    sitename="ForestEcology.jl",
    format=Documenter.HTML(;
        canonical="https://JuliaForests.github.io/ForestEcology.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaForests/ForestEcology.jl",
    devbranch="master",
)
