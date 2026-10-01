
# Not yet, need to to think about the rotation/axes representation
# Just limit to needed functionality of 2D case
# TODO just add an orthogonal matrix as both the semi-axes and rotation
#
# """
#     HyperEllipsoid{N, T}

# A `HyperEllipsoid` is a generalization of an ellipse into N-dimensions.
# A `center` and semi-axes vector, `r`, must be specified.
# """
# struct HyperEllipsoid{N,T} <: GeometryPrimitive{N,T}
#     center::Point{N,T}
#     r::SVector{N,T}

# end

"""
    Ellipse{T}


"""
mutable struct Ellipse{T} <: GeometryPrimitive{2,T}
    _conic::SVector{6,T}
    _center::Point2{T}
    _axes::SVector{2,T}
    _angle::T
end

function Ellipse(con::AbstractVector{T}) where {T}
    center, axes, angle = conic_to_axes(con)

    return Ellipse(SVector{6,T}(con), Point2{T}(center), SVector{2,T}(axes), T(angle))
end

function Ellipse(centre, axes, angle)
    return Ellipse(axes_to_conic(centre, axes, angle))
end

Ellipse() = Ellipse(Float32[1.0, 0.0, 1.0, 0.0, 0.0, -1.0])

function show(io::IO, el::Ellipse)
    return print(
        io,
        "Ellipse with axes $(axes(el)), centre $(center(el)), angle $(angle(el)) rad.\nConic coefficients $(conic(el))",
    )
end

conic(el::Ellipse) = el._conic
center(el::Ellipse) = el._center
axes(el::Ellipse) = el._axes
angle(el::Ellipse) = el._angle

function conic!(el::Ellipse, coeffs)
    el._conic = coeffs
    el._center, el._axes, el._angle = conic_to_axes(coeffs)
    return el
end

function axes!(el::Ellipse, ax)
    # el._axes = sort!([ax...]; rev=true)
    el._axes = [ax...]
    el._conic = axes_to_conic(el._center, el._axes, el._angle)
    return el
end

function center!(el::Ellipse, c)
    el._center = c
    el._conic = axes_to_conic(el._center, el._axes, el._angle)
    return el
end

function angle!(el::Ellipse, θ)
    el._angle = θ
    el._conic = axes_to_conic(el._center, el._axes, el._angle)
    return el
end

function rotate!(el::Ellipse, θ)
    el._angle += θ
    el._conic = axes_to_conic(el._center, el._axes, el._angle)
    return el
end

function to_el_coord(x, y, el::Ellipse)
    c = center(el)
    lx, ly = axes(el)
    ϕ = angle(el)
    ex = [cos(ϕ), sin(ϕ)] ./ lx
    ey = [-sin(ϕ), cos(ϕ)] ./ ly
    p = [x - c[1], y - c[2]]
    return dot(p, ex), dot(p, ey)
end

to_el_coord(c::Tuple, el::Ellipse) = to_el_coord(c..., el)

copy(el::Ellipse) = Ellipse(conic(el))

scale!(el::Ellipse, c) = axes!(el, c * axes(el))
scale(el::Ellipse, c) = axes!(copy(el), c * axes(el))

"""
    rotate_with_image!(ellipse, dims::Tuple)

Rotate the ellipse by 90 degrees counter-clockwise with respect to the image dimensions `dims`. If an image is provided instead of dimensions, the size of the image is used.
"""
function rotate_with_image!(ellipse, dims::Tuple)
    xc, yc = center(ellipse)
    EllipseGeometry.center!(ellipse, (dims[1] + 1 - yc, xc))
    return angle!(ellipse, angle(ellipse) + π / 2)
end

rotate_with_image!(ellipse, image::Matrix) = rotate_with_image!(ellipse, size(image))

"""
    flip_with_image!(ellipse, dims::Tuple, flipaxis=:x)

Flip the ellipse with respect to the image dimensions `dims`. The `flipaxis` can be `:x` or `:y`.
If an image is provided instead of dimensions, the size of the image is used.
"""
function flip_with_image!(ellipse, dims::Tuple, flipaxis=:x)
    xc, yc = center(ellipse) # x is always the first coordinate, also for the image
    if flipaxis == :x
        EllipseGeometry.center!(ellipse, (dims[1] + 1 - xc, yc))
        return angle!(ellipse, π - angle(ellipse))
    elseif flipaxis == :y
        EllipseGeometry.center!(ellipse, (xc, dims[2] + 1 - yc))
        return angle!(ellipse, -angle(ellipse))
    else
        error("flipaxis must be :x or :y")
    end
end

function flip_with_image!(ellipse, image::Matrix, flipaxis=:x)
    return flip_with_image!(ellipse, size(image), flipaxis)
end

flip_with_image(ellipse, args...) = flip_with_image!(copy(ellipse), args...)
