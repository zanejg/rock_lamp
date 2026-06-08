$fn=50;

difference(){
    cube([30, 22, 10], center=true);
    translate([5, 7, 0]){
        cylinder(h = 12, r = 2/2,center=true);
    }
    translate([5, -7, 0]){
        cylinder(h = 12, r = 2/2,center=true);
    }

    translate([17, 11, 0]){
        cube([15, 15, 12], center=true);
    }
    translate([17, -11, 0]){
        cube([15, 15, 12], center=true);
    }

    translate([-10, 14, 0]){
        cube([18, 15, 12], center=true);
    }
    translate([-10, -14, 0]){
        cube([18, 15, 12], center=true);
    }
}