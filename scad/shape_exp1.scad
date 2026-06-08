
XRAD = 15;

module xtal(){
    translate([10, -15, 0]){
        difference(){
            cylinder(h = 100, r = XRAD, $fn=5);
            translate([0, 17, 100]){
                rotate([30, 0, 0]){
                    cube([30, 20, 30], center=true);
                }
            }
            translate([0, -10, 100]){
                rotate([-30, 20, 0]){
                    cube([40, 20, 55], center=true);
                }
            }
            translate([-5, 0, 100]){
                rotate([0, 35, 20]){
                    cube([20, 30, 60], center=true);
                }
            }
        }
    }
    translate([XRAD*2, 0, 0]){
        difference(){
            cylinder(h = 100, r = XRAD, $fn=6);
            translate([12, 0, 100]){
                rotate([0, -20, 0]){
                    cube([20, 40, 80], center=true);
                }
            }
            translate([-10, 5, 100]){
                rotate([0, 20, -40]){
                    cube([20, 40, 80], center=true);
                }
            }
        }
    }
    translate([8, -20, 0]){
        translate([0, XRAD*2, 0]){
            difference(){
                cylinder(h = 100, r = XRAD, $fn=7);
                translate([0, 0, 110]){
                    rotate([0, 20, -40]){
                        cube([40, 40, 20], center=true);
                    }
                }
                translate([-9, 6, 100]){
                    rotate([0, 30, -40]){
                        cube([20, 40, 80], center=true);
                    }
                }
            }
        }
    }
}

translate([0, 0, 0]){
    xtal();
}
translate([-40, 0, 0]){
    xtal();
}
translate([-80, 0, 0]){
    xtal();
}

translate([0, 30, 0]){
    xtal();
}
translate([-40, 30, 0]){
    xtal();
}
translate([-80, 30, 0]){
    xtal();
}


