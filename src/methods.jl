function conic_to_axes(coeffs, normalise=true)
    # https://www.wikiwand.com/en/Ellipse#/General_ellipse
    # Extract  conic parameters
    if normalise && coeffs[1] != 0
        coeffs = coeffs / coeffs[1]
    end

    A, B, C, D, E, F = coeffs

    # Useful intermediates
    disc = B * B - 4 * A * C

    # Center
    x0 = (2 * C * D - B * E) / disc
    y0 = (2 * A * E - B * D) / disc

    # Axis lengths
    term1 = 2 * (A * E * E + C * D * D - B * D * E + disc * F)
    a = -sqrt(term1 * (A + C + sqrt((A - C)^2 + B^2))) / disc
    b = -sqrt(term1 * (A + C - sqrt((A - C)^2 + B^2))) / disc

    if A <= C
        if B == 0
            phi_b = 0
        else
            phi_b = atan(B, (A - C)) / 2
        end
    else
        if B == 0
            phi_b = π / 2
        else
            phi_b = atan(B, (A - C)) / 2 - π / 2
        end
    end

    return (x0, y0), (a, b), phi_b
end

function axes_to_conic(centre, axes, angle; normalise=true)
    x0, y0 = centre
    a, b = sort([axes...]; rev=true)

    A = (a * sin(angle))^2 + (b * cos(angle))^2
    B = 2 * (b^2 - a^2) * sin(angle) * cos(angle)
    C = (a * cos(angle))^2 + (b * sin(angle))^2
    D = -2 * A * x0 - B * y0
    E = -B * x0 - 2 * C * y0
    F = A * x0 * x0 + B * x0 * y0 + C * y0 * y0 - a * a * b * b
    conic = [A, B, C, D, E, F]
    normalise && conic ./= -conic[end]
    return conic
end

function getellipsepoints(cx, cy, rx, ry, θ; length=101)
    t = range(0, 2; length=length)
    ellipse_x_r = @. rx * cospi(t)
    ellipse_y_r = @. ry * sinpi(t)
    R = [cos(θ) sin(θ); -sin(θ) cos(θ)]
    r_ellipse = [ellipse_x_r ellipse_y_r] * R
    x = @. cx + r_ellipse[:, 1]
    y = @. cy + r_ellipse[:, 2]
    return (x, y)
end

function getellipsepoints(el::Ellipse; kwargs...)
    return getellipsepoints(center(el)..., axes(el)..., angle(el); kwargs...)
end

function getellipseaxes(cx, cy, rx, ry, θ)
    axmaj = rx * [1, 0]
    axmin = ry * [0, 1]
    R = [cos(θ) sin(θ); -sin(θ) cos(θ)]
    r_ellipse = [axmaj axmin] * R
    x = r_ellipse[:, 1]
    y = r_ellipse[:, 2]
    return ([cx, cx], [cy, cy], x, y)
end

getellipseaxes(el::Ellipse) = getellipseaxes(center(el)..., axes(el)..., angle(el))

"""
    add_axes!(el::Ellipse)

Function is active when Makie is loaded. Draws axes of the `el`.
"""
function add_axes!() end

"""
    fit_ellipse(positions::Vector{Point2-like}, weights = ones)

Document this function
"""
function fit_ellipse(positions, w=ones(length(positions)))
    length(positions) < 5 && return zeros(6) # infinite ellipse for less than 5 points
    b = -w
    zzz = point_conic_eq.(positions) .* w
    A = hcat(zzz...)'
    coeffs = A \ b
    el = Ellipse()
    conic!(el, vcat(coeffs, [1]))
    return el
end  # function fit_ellipse

function point_conic_eq(x, y)
    return [x^2, x * y, y^2, x, y]
end

point_conic_eq(p::Point2) = point_conic_eq(p.data...)
point_conic_eq(p::Tuple) = point_conic_eq(p...)
point_conic_eq(p::CartesianIndex) = point_conic_eq(p.I...)

function inside_ellipse(el::Ellipse, position)
    x, y = Tuple(position)
    return [x^2, x * y, y^2, x, y, 1]' * conic(el) * sign(conic(el)[1]) <= 0
end

function mask_ellipse(img, el::Ellipse)
    mask = similar(img, Bool)
    for i in CartesianIndices(img)
        mask[i] = inside_ellipse(el, i)
    end
    return mask
end
