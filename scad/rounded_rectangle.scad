
module rounded_rectangle_prism(width, height, depth, corner_radius){
    horiz_dist = width/2 - corner_radius;
    vert_dist = height/2 - corner_radius;
    hull(){
        translate([0, vert_dist, 0]){
            hull(){
                translate([horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
                translate([-horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
            }
        }
        translate([0, -vert_dist, 0]){
            hull(){
                translate([horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
                translate([-horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
            }
        }
    }
}