$fn=50;

MAIN_RD = 20;

module main_shape(){
    hull(){   
        cylinder(h = 1, r = MAIN_RD, $fn=6);
        translate([0, 0, 10]){
            cylinder(h = 25, r = 30,$fn=6);
        }
    }
}

// the shell
union(){
    difference(){
        difference(){
            main_shape();
            translate([0, 0, 2]){
                scale([0.9,0.9,1.0]){
                    main_shape();
                }
            }
        }
        // chop out the bite for the Al bar
        translate([0, 0, 36]){
            cube([25, 80, 20], center=true);
        }
        // clamp holes
        CLAMP_HOLE_Z = 30;
        translate([23, 10, CLAMP_HOLE_Z]){
            cube([10 ,5 ,4 ], center=true);
        }
        translate([23, -10, CLAMP_HOLE_Z]){
            cube([10 ,5 ,4 ], center=true);
        }
    
    
        // clamp screw end bite
        translate([-20, 0, 34]){
            cube([22, 15, 10], center=true);
        }
    }
    
    // screw bollard
    cnr_rd = MAIN_RD * (1/cos(30));
    difference(){
        translate([-(cnr_rd), 0, 9]){
            cylinder(h = 20, r = 8/2, $fn=6);
        }
        // 45deg champfer for printability
        translate([-20, 0, 6.5]){
            rotate([0, 45, 0]){
                cube([10, 10,20 ], center=true);
            }
        }
        // screw hole
        translate([-cnr_rd, 0, 20.5]){
            cylinder(h = 10, r = 2.5/2);
        }
    
        
    }
}


//  CLAMP
CLAMP_TN = 2.5;
CLAMP_Z = 30.75;
difference(){
    
    union(){
        translate([22, 10, CLAMP_Z]){
            cube([10, 4, CLAMP_TN], center=true);
        }
        translate([22, -10, CLAMP_Z]){
            cube([10, 4, CLAMP_TN], center=true);
        }
        translate([17, 0, CLAMP_Z]){
            cube([8, 24, CLAMP_TN], center=true);
        }
        translate([7.0, 0, CLAMP_Z - CLAMP_TN/2]){
            rotate([0, 0, 60]){
                cylinder(h = CLAMP_TN, r = 14, $fn=3);
            }
        }
        translate([-13, 0, CLAMP_Z]){
            cube([30, 10, CLAMP_TN], center=true);
        }

        translate([10, 0, CLAMP_Z - 0.5]){
            cube([2, 10, CLAMP_TN], center=true);
        }

    }

    #translate([-23, 0, CLAMP_Z-2]){
        cylinder(h = CLAMP_TN * 2 , r = 3/2);
    }
    
}

// UNPRINTED Al BAR
color("YELLOW",0.5){
    translate([0, 0, 27.6]){
        cube([25,150 ,3 ], center=true);
    }
}
