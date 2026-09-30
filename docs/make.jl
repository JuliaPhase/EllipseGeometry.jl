using EllipseGeometry
using Documenter

DocMeta.setdocmeta!(EllipseGeometry, :DocTestSetup, :(using EllipseGeometry); recursive=true)

makedocs(;
    modules=[EllipseGeometry],
    authors="Oleg Soloviev <oleg.soloviev@gmail.com> and contributors",
    repo="https://github.com/JuliaPhase/EllipseGeometry.jl/blob/{commit}{path}#{line}",
    sitename="EllipseGeometry.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliaphase.github.io/EllipseGeometry.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaPhase/EllipseGeometry.jl",
    devbranch="main",
)
