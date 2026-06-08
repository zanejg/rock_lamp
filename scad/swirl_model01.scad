include <modelling_tests.scad>

SHAPE_WD = 50;

INNER_RD = SHAPE_WD * (10/75);
STRAIGHT_LN = SHAPE_WD * (20/75);
SWIRL_ANG = 200;
straight_ang = (SWIRL_ANG - 180)/2;

// PEAK_DIST = 30;
// BASE_HT = 60;
// PEAK_HT = 30;
// outer_peak_wd = (SHAPE_WD - PEAK_DIST) /2;
// shape_pts = [
//     [0, 0],
//     [SHAPE_WD, 0],
//     [SHAPE_WD, BASE_HT],
//     [SHAPE_WD - outer_peak_wd, BASE_HT + PEAK_HT],
//     [SHAPE_WD/2, BASE_HT],
//     [outer_peak_wd, BASE_HT + PEAK_HT],
//     [0, BASE_HT]
// ];


BASE_HT = 50;
PEAK_HT = 60;

shape_pts = [
    [0, 0],
    [SHAPE_WD, 0],
    [SHAPE_WD, BASE_HT],
    [SHAPE_WD/2, BASE_HT + (PEAK_HT)],
    [0, BASE_HT]
];



SC_COEFF = 0.90;
xos = (SHAPE_WD - (SHAPE_WD *SC_COEFF))/2;
scaled_pts = [
    for (this_pt = shape_pts)
        [this_pt[0] * SC_COEFF + xos, this_pt[1] * SC_COEFF ]
    
];

// Just testing the scaling
// !union(){
//     polygon(shape_pts);
    
//     translate([2.5, 0, 5]){
//         polygon(scaled_pts);
//     }
// }

module halfswirl(the_pts){
    rotate([0, 0, -straight_ang]){
        rotate_extrude(angle = SWIRL_ANG){ 
            translate([INNER_RD, 0, 0]){
                polygon(the_pts);
            }
        }
        
    }
    rotate([0, 0, 10]){
        translate([-(SHAPE_WD + INNER_RD), 0, 0]){
            rotate([90, 0, 0]){
                linear_extrude(height = STRAIGHT_LN) {
                    polygon(the_pts);    
                }
            }
        }
    }

    rotate([0, 0, -straight_ang]){
        translate([(INNER_RD), 0, 0]){
            rotate([90, 0, 0]){
                linear_extrude(height = STRAIGHT_LN) {
                    polygon(the_pts);    
                }
            }
        }
    }
}

module fullswirl(the_pts){
    halfswirl(the_pts);

    translate([SHAPE_WD + INNER_RD + (sin(straight_ang) * STRAIGHT_LN /2), 
                -(STRAIGHT_LN*2 + (sin(straight_ang) * (SHAPE_WD + INNER_RD))), 
                0]){
        rotate([0, 0, 180]){
            halfswirl(the_pts);
        }
    }
    // translate([SHAPE_WD - (INNER_RD * 3), 
    //           -(STRAIGHT_LN + INNER_RD), 
    //           BASE_HT/2]){
    //     cube([SHAPE_WD *1.5 + (INNER_RD * 2), 
    //           (STRAIGHT_LN*3) + (INNER_RD * 2), 
    //           BASE_HT], center=true);
    
    // }
}


inter_swirl_offset = (INNER_RD+SHAPE_WD)*2 + (sin(straight_ang) * STRAIGHT_LN );

inter_swirl_gap = (INNER_RD - (sin(straight_ang) * (2 * STRAIGHT_LN))) + // gap caused by extension of straight len at angle
                           ((1- cos(straight_ang)) * SHAPE_WD) // curl back of shape
                            -((1- cos(straight_ang)) * INNER_RD);
                        
section_wd = (SHAPE_WD*2) + (INNER_RD*2) + inter_swirl_gap;

// !fullswirl(shape_pts);

module lamp_section(){
    intersection() {
        for(xos = [0,1]){
            difference(){
                union(){
                    fullswirl(shape_pts);
                    translate([inter_swirl_offset * xos, 0, 0]){
                        fullswirl(shape_pts);
                    }
                }
                translate([0,0,-0.1]){
                    fullswirl(scaled_pts);
                    translate([inter_swirl_offset * xos, 0, 0]){
                        fullswirl(scaled_pts);
                    }
                }
            }
        }

        

        // trim ends
        translate([0, -100, 0]){
            cube([section_wd, 200, BASE_HT*3 ], center=false);
        }
    }
    
}


module LED_support(){
    rotate([40, 0, 0]){
        difference(){
            cube([8,25 ,16 ], center=true);
            translate([0, -5, 0]){
                cylinder(h = 12, r = 2/2);
            }
        }
    }
}

// ###############################################################
// One main section
BOX_TN = 2.5;
CAVITY_HT = 40;
MBOX_WD = 100;
TAB_LN = 30;

cavity_wd = MBOX_WD -(BOX_TN *2);

module one_main_section(){
    difference(){
        union(){
            lamp_section();
            translate([0, -45, 0]){
                cube([section_wd,100 ,40 ], center=false);   
            }
            // LED Supports
            translate([32, -49, 25]){
                LED_support();
            }
            translate([84, -49, 25]){
                LED_support();
            }
        }
        // Main box cavity
        translate([-0.5, -42.5, -BOX_TN]){
            cube([section_wd + 1,cavity_wd ,CAVITY_HT ], center=false);   
        }
    
        // cable holes
        translate([25, -34, 40]){
            cube([12,8 , 10], center=true);
        }
        translate([90, -34, 40]){
            cube([12,8 , 10], center=true);
        }
    
        // // TEMP chop off top for dev
        // translate([50, 0, 85]){
        //     cube([150, 200, 90], center=true);
        // }
    }
    // glue tabs
    tab_ht = CAVITY_HT - BOX_TN;
    translate([section_wd, -(cavity_wd/2 - BOX_TN*2.5), tab_ht/2]){
        cube([TAB_LN, BOX_TN, tab_ht], center=true);
    }
    
    translate([0, (cavity_wd/2 + BOX_TN*1.5), tab_ht/2]){
        cube([TAB_LN, BOX_TN, tab_ht], center=true);
    }
}

one_main_section();

//###################################################################
// PCB cradle Box insert

// Mbox_wd = cavity_wd - 1;

// translate([0, BOX_TN*2, 0]){
//     difference(){
//         cube([200, Mbox_wd, tab_ht], center=true);
    
//         translate([-BOX_TN, 0, BOX_TN/2]){
//             cube([200, Mbox_wd - BOX_TN * 2, tab_ht-BOX_TN +1], center=true);
//         }
//     }
// }



// Al LED slab
// NOT TO BE PRINTED!!
color("yellow",1.0){
    translate([58, -60, 31]){
        rotate([40, 0, 0]){
            difference(){
                cube([58,25 ,3 ], center=true);
                translate([26, 0, -3]){
                    cylinder(h = 10, r = 3/2);
                }
                translate([-26, 0, -3]){
                    cylinder(h = 10, r = 3/2);
                }
            }
        }
    }    
}

translate([0, 5, 0]){
    main_board();
}

// translate([-150, 0, 0]){
//     rotate([0, 0, 90]){
//         power_bank();
//     }
// }