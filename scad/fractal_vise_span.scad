$fn = 100;

PRINT_WHOLE = true;

PRINT_TOP_ARCH = false;

SEGMENT_HT = 20;
TAIL_WD = 10;
TAIL_HT = 3;
TOOTH_BITE = 2;
// TAIL_CLEARANCE = 2;


// have decided 18,36,72
NOMINAL_SEGMENT_RAD = 18;
// NOMINAL_SEGMENT_RAD = 36;
// NOMINAL_SEGMENT_RAD = 72;



segment_rad = NOMINAL_SEGMENT_RAD - 2*TAIL_HT;



rotating_segment_shape =[
    [0,0],
    [0,SEGMENT_HT],
    [segment_rad,           SEGMENT_HT],
    [segment_rad,           SEGMENT_HT/2 + (TAIL_WD/2 - TOOTH_BITE)],
    [segment_rad + TAIL_HT, SEGMENT_HT/2 + TAIL_WD/2],
    [segment_rad + TAIL_HT, SEGMENT_HT/2 - TAIL_WD/2],
    [segment_rad,           SEGMENT_HT/2 - (TAIL_WD/2 - TOOTH_BITE)],
    [segment_rad,0]
];


FAN_VERTICAL_OS = 0.5;
MAIN_OS = 0.2;
RADIUS_OS = 0.2;
BULGE_SZ = 0.5;
// the next rad needs to be half minus the tails
nominal_neg_rad = NOMINAL_SEGMENT_RAD/2;


// if (NOMINAL_SEGMENT_RAD > 18){
//     neg_segment_rad = nominal_neg_rad - 2*TAIL_HT; 
// }else{
//     neg_segment_rad = nominal_neg_rad - 2*TAIL_HT - 4*BULGE_SZ;
// }

neg_segment_rad = NOMINAL_SEGMENT_RAD > 18 ? nominal_neg_rad - 2*TAIL_HT : 
                                            nominal_neg_rad - 2*TAIL_HT - 3*BULGE_SZ;


module negative_segment(){
    negative_segment_shape = [
        [0,- MAIN_OS],
        [0,SEGMENT_HT + MAIN_OS],
        [neg_segment_rad,           SEGMENT_HT + MAIN_OS],
        [neg_segment_rad,           SEGMENT_HT/2 + (TAIL_WD/2 - TOOTH_BITE + MAIN_OS)],
        [neg_segment_rad + TAIL_HT, SEGMENT_HT/2 + TAIL_WD/2 + FAN_VERTICAL_OS+ MAIN_OS],
        [neg_segment_rad + TAIL_HT + BULGE_SZ, SEGMENT_HT/2],
        [neg_segment_rad + TAIL_HT, SEGMENT_HT/2 - TAIL_WD/2 - FAN_VERTICAL_OS - MAIN_OS],
        [neg_segment_rad,           SEGMENT_HT/2 - (TAIL_WD/2 - TOOTH_BITE + MAIN_OS)],
        [neg_segment_rad,- MAIN_OS]
    ];
    rotate_extrude(angle=180, convexity=10){
        polygon(negative_segment_shape);
    }
}




// because we can't print this as is we need to chop it in half
// 3/8 * nom rad for half printing
// 

module full_segment(){
    difference(){
        difference(){
            //  chop off the bottom of the half-circle
            translate([0, -NOMINAL_SEGMENT_RAD/4, 0]){
                rotate_extrude(angle=180, convexity=10){
                    polygon(rotating_segment_shape);
                }
            }
            // translate([0, -segment_rad/2, 10]){
            //     cube([2.1 * segment_rad+2*TAIL_HT, segment_rad, SEGMENT_HT *1.5], 
            //             center=true);
            // }
        }
        
        if (NOMINAL_SEGMENT_RAD > 18){
            
            HORIZ_COEFF = 0.54;
            VERT_COEFF = 1.4;
            translate([-segment_rad*HORIZ_COEFF ,-neg_segment_rad*VERT_COEFF , 0]){
                negative_segment();
            }
            translate([segment_rad*HORIZ_COEFF,-neg_segment_rad*VERT_COEFF , 0]){
                negative_segment();
            }
        }
        // translate([-segment_rad*0.54 ,-neg_segment_rad*1.4 , 0]){
        //     negative_segment();
        // }
        // translate([segment_rad*0.54,-neg_segment_rad*1.4 , 0]){
        //     negative_segment();
        // }
    }
}

chop_ht = 2/8 * NOMINAL_SEGMENT_RAD;

module chopping_cube(){
    translate([-NOMINAL_SEGMENT_RAD, 
                chop_ht, -0.1]){
        cube([2 * NOMINAL_SEGMENT_RAD, segment_rad, SEGMENT_HT *1.5], 
                center=false);
    }
}

module register_spike(){
    rotate([-90, 0, 0]){
        hull(){
            translate([0, 0, 6]){
                cube([2,2,0.1], center=true);
            }
            cube([3,3,0.1], center=true);
        }
    }
}


module register_spikes(){
    translate([segment_rad*(1/4), chop_ht -1, SEGMENT_HT/2]){
        register_spike();
    }
    translate([-segment_rad*(1/4), chop_ht -1, SEGMENT_HT/2]){
        register_spike();
    }
}
    



// register_spike();


if (PRINT_WHOLE){
    intersection(){
        full_segment();

        // translate([-37, 0, 0]){
        //     cylinder(r=segment_rad/2.5, h=SEGMENT_HT *1.5, center=false);
        // }
    }
}else{

    if (PRINT_TOP_ARCH){
        difference(){
            intersection(){
                full_segment();
                chopping_cube();
            }
            full_segment();
            register_spikes();
        }
        
    }else{
        difference(){
            full_segment();
            chopping_cube();
        }

        register_spikes();
        
    }
}