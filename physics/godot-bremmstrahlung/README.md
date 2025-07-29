A very simple visualization of the spatial distribution of electromagnetic radiation emitted by an accelerating point charge. The blue ball at the center is the point charge, whereas the white shape around it is a representation of the emitted radiation. The further the white shape goes from the central charge, the stronger the radiation is in that direction.

The radiated power is calculated using Liénard's relativistic generalization of the Larmor formula:
```math
\frac{dP_\text{charge}}{d\Omega}\sim\frac{\lvert \hat{\mathbf{n}}\times(\mathbf{u}\times \mathbf{a}) \rvert ^{2}}{(\hat{\mathbf{n}}\cdot \mathbf{u})^{5}}
```
where $\mathbf{u}=c\hat{\mathbf{n}}-\mathbf{v}$, $c$ is the speed of light, $\hat{\mathbf{n}}$ is the unit vector from the point charge to the observer, and $\mathbf{v}$ and $\mathbf{a}$ are the velocity and acceleration vectors. $d\Omega$ is the unit solid angle and the Liènard formula is found by integrating this overall a full solid angle.

The particle is made to move back and forth in an oscillatory pattern. At the edges, when the particle changes direction of motion, we can see that the shape around the charge is a torus, which is what is predicted by the nonrelativistic Larmor formula. When velocity is nonzero, the shape distorts in the direction of motion, becoming two lobes stretched forward.

The effect is achieved by creating a spherical mesh centered on the point charge, then at each physics frame calculating the power emitted in the direction of each vertex of the mesh. Since the sphere is centered on the charge, this is like sampling the power spherically. Then, all of the calculated values are collected, normalized between 0 and 1, multiplied by a scaling factor and the radius of each vertex on the sphere is multiplied by this value. As a consequence, the sphere gets warped based on the power in the direction of each vertex, becoming the shape that is seen around the charge. In order to make the effect visible without requiring absurd velocities that are impossible to visualize, the value of $c$ has been greatly reduced ($c=25\text{ m/s}$). This way, the point charge reaches peak velocities very near (>95%) the speed of light.

Project done in July 2025.