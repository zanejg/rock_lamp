$fn = 100;

PRINT_WHOLE = true;

PRINT_TOP_ARCH = false;

SEGMENT_HT = 20;
TAIL_WD = 10;
TAIL_HT = 3;
TOOTH_BITE = 2;
// TAIL_CLEARANCE = 2;


// have decided 18,36,72
// NOMINAL_SEGMENT_RAD = 18;
NOMINAL_SEGMENT_RAD = 36;
// NOMINAL_SEGMENT_RAD = 72;

NEG_COEFF = 0.46;


cylinder_rad = NOMINAL_SEGMENT_RAD;// - TAIL_HT;
segment_rad = cylinder_rad;
neg_segment_rad = NOMINAL_SEGMENT_RAD*NEG_COEFF; //- TAIL_HT;
tail_triangle_rad = (TAIL_WD * sqrt(3))/3;
// tail_triangle_rad = 8;

module body_and_tail(this_cylinder_rad, negative=false){
    NEGATIVE_RAD_OS = 0.75;
    scaled_cylinder_rad = negative ? this_cylinder_rad + NEGATIVE_RAD_OS : this_cylinder_rad;
    scaled_ht = negative ? SEGMENT_HT + 2*NEGATIVE_RAD_OS : SEGMENT_HT;
    difference(){
        // the main cylinder body
        rotate_extrude(angle=180, convexity=10){
            translate([scaled_cylinder_rad/2, 0, 0]){
                square(size=[scaled_cylinder_rad, scaled_ht], center=true);
            }
        }
        // the tail triangle
        rotate_extrude(angle=180, convexity=10){
            // note just the unscaled cylinder rad is used here 
            // because the triangle is scaled up or down we don't need to scale the translation
            translate([this_cylinder_rad, 0, 0]){
                rotate([0, 0, 0]){
                    // if this a negative then we need to scale the triangle
                    // so that the hole is slightly larger than the solid tail
                    triangle_scale = negative ? 1.0 : 1.1;
                    scale([triangle_scale, triangle_scale, 1]){
                        circle(r=tail_triangle_rad, $fn=3);
                    }
                }
            }
        }
    }
}



// !union(){
//     body_and_tail(negative=false);
//     #body_and_tail(negative=true);
    
// }

// because we can't print this as is we need to chop it in half
// 3/8 * nom rad for half printing
// 

module full_segment(){
    HORIZ_COEFF = 0.54;
    VERT_COEFF = 0.8;

    difference(){
        difference(){
            body_and_tail(cylinder_rad, negative=false);
            translate([0, -segment_rad/8, 0]){
                cube([2.5*segment_rad, segment_rad, SEGMENT_HT *1.5], center=true);
            }
        }
        
        if (NOMINAL_SEGMENT_RAD > 18){
            
            
            translate([-segment_rad*HORIZ_COEFF , segment_rad/7, 0]){
                body_and_tail(neg_segment_rad,negative=true);
            }
            translate([segment_rad*HORIZ_COEFF,segment_rad/7 , 0]){
                body_and_tail(neg_segment_rad,negative=true);
            }  
        }
        // translate([-segment_rad*0.54 ,-neg_segment_rad*1.4 , 0]){
        //     negative_segment();
        // }
        // translate([segment_rad*0.54,-neg_segment_rad*1.4 , 0]){
        //     negative_segment();
        // }
    }
    translate([-segment_rad*HORIZ_COEFF , segment_rad/7, ]){
        difference(){
            body_and_tail(neg_segment_rad,negative=false);
            #translate([-segment_rad/4 - 0.5, -segment_rad/7, 0 ]){
                body_and_tail(neg_segment_rad/2,negative=true);
            }

            translate([segment_rad/4 + 0.5, -segment_rad/7, 0 ]){
                body_and_tail(neg_segment_rad/2,negative=true);
            }

        }
    }
    !translate([-segment_rad*(3/4) - 2 ,0 , 0]){
        body_and_tail(neg_segment_rad/2,negative=false);
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