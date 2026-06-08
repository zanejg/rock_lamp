$fn=40;
MAIN_HT=6;


difference(){
    union(){
        // main body
        cube([12, 26, MAIN_HT], center=true);
        cube([16, 10, MAIN_HT], center=true);

        // gripping ridges
        translate([-7.3, 5, MAIN_HT/2]){
            rotate([90, 0, 0]){
                cylinder(h = 10, r = 1, $fn=3);
            }
        }
        translate([7.3, 5, MAIN_HT/2]){
            rotate([90, 60, 0]){
                cylinder(h = 10, r = 1, $fn=3);
            }
        }

    }
    translate([0, 8, -6]){
        cylinder(h = 12, r = 3.5/2);
    }
    translate([0, -8, -6]){
        cylinder(h = 12, r = 3.5/2);
    }
}