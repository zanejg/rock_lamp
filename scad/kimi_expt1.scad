// Sphere with through-hole
// Sphere diameter: 100mm
// Hole diameter: 10mm

$fn = 100;  // Smoothness (number of fragments)

sphere_d = 100;
hole_d = 10;

difference() {
    // Main sphere
    sphere(d = sphere_d, center = true);
    
    // Hole — cylinder slightly longer than sphere diameter
    cylinder(d = hole_d, h = sphere_d + 2, center = true);
}