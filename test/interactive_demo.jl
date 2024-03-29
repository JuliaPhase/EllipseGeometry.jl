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

el2 = Observable(Ellipse())
lines!(el2; color=:red)

for a in 0:0.01:1
    EllipseGeometry.center!(el2[], (0, a))
    angle!(el2[], a * π)
    axes!(el2[], [1 - a, 1 + a / 2])
    notify(el2)
    sleep(0.04)
end
