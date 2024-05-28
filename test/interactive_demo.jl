using EllipseGeometry
using GLMakie

el = Ellipse()
el1 = Ellipse()
axes!(el1, (2, 0.5))
EllipseGeometry.center!(el1, (-1, 0.5))
angle!(el1, π / 3)

fig, ax, _, = lines(el)
scatter!(el1)
ax.aspect = DataAspect()

display(fig)

# Test creation of ellips by conic
el1copy = Ellipse(conic(el1))
lines!(el1copy)

EllipseGeometry.add_axes!.([el, el1])

sampling = 0.05
xs = -3:sampling:1
ys = -2:sampling:3
allpoints = [(x, y) for x in xs, y in ys]
pinel = filter(x -> inside_ellipse(el, x), allpoints)
scatter!(pinel; markersize=0.1)
pinel1 = filter(x -> inside_ellipse(el1, x), allpoints)
scatter!(pinel1; markersize=0.1, color=:orange)

## TMP, remove
vecz = PhaseBases.makezerniketable(pinel, 10)
heatmap!(first.(pinel), last.(pinel), vecz[24])

pinel1_rel = EllipseGeometry.to_el_coord.(pinel1, [el1])
vecz1 = PhaseBases.makezerniketable(pinel1_rel, 10)
heatmap!(first.(pinel1), last.(pinel1), vecz1[24])

EllipseGeometry.add_axes!.([el, el1])

scatter!(
    first.(pinel1_rel),
    last.(pinel1_rel);
    color=vecz1[24],
    strokewidth=0.1,
    strokecolor=:white,
)
# scatter!(pinel1_rel; markersize=0.75, color=:white)

el2 = Observable(Ellipse())
lines!(el2; color=:red)

for a in 0:0.01:1
    EllipseGeometry.center!(el2[], (0, a))
    angle!(el2[], a * π)
    axes!(el2[], [1 - a, 1 + a / 2])
    notify(el2)
    sleep(0.04)
end
