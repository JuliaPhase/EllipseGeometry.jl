using EllipseGeometry
using Test

@testset "EllipseGeometry.jl" begin
    # Write your tests here.
    el = Ellipse()
    @test angle(el) == 0.0f0
    @test center(el).data == (0.0f0,0.0f0)
    @test all(EllipseGeometry.axes(el) .== [1,1])
    @test angle(el) == 0
    @test all(conic(el) .== [1,0,1,0,0,-1])

end
