module EllipseMakieExt
using EllipseGeometry
using Makie
import EllipseGeometry.add_axes!

function Makie.convert_arguments(::Type{<:AbstractPlot}, el::Ellipse)
    return (map(Point2f, zip(EllipseGeometry.getellipsepoints(el)...)),)
end

function add_axes!(el::Ellipse)
    return arrows!(EllipseGeometry.getellipseaxes(el)...; color=[:red, :green])
end

export add_axes!

end
