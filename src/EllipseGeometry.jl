module EllipseGeometry

using GeometryBasics
using StaticArrays
using LinearAlgebra: dot

import Base: show, angle

include("ellipse.jl")
include("methods.jl")

export Ellipse,
    conic,
    conic!,
    center,
    center!,
    axes,
    axes!,
    angle,
    angle!,
    fit_ellipse,
    inside_ellipse,
    mask_ellipse,
    to_el_coord

end
