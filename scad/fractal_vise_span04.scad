$fn = 50;

echo("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
echo("@@@@@@@@@@@@@@@@@@@@@@@@@Start rendering @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");


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

module body_and_slot(this_cylinder_rad, center_coords, negative=false){
    if(this_cylinder_rad > TAIL_WD){
        NEGATIVE_RAD_OS = 0.75;
        scaled_cylinder_rad = negative ? this_cylinder_rad + NEGATIVE_RAD_OS : this_cylinder_rad;
        scaled_ht = negative ? SEGMENT_HT + 2*NEGATIVE_RAD_OS : SEGMENT_HT;
        translate([center_coords[0], center_coords[1], 0]){
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
    }else{
        echo("ZZZ cylinder rad too small to rotate tail triangle ZZZ");
    }
}


// [major_radius,height_ratio,[negative_x, negative_y]]
layer_details = [
    [144, 0.5, [70,30]],
    [72, 0.5, [30,15]]];

//     [36, 0.75, [15,8]],
//     [18, 1.0, [0,0]],
// ];


// recursive function to display the whole structure
module whole_structure(level = 0, center_coords=[0,0]){
    echo("level: ", level, " center_coords: ", center_coords);
    // recursion escape clause
    if (level < len(layer_details)){
        this_layer = layer_details[level];
        this_cylinder_rad = this_layer[0];
        this_height_ratio = this_layer[1];
        this_negative_coords = this_layer[2];
        neg_seg_details = (level < len(layer_details) - 1)?layer_details[level + 1]:[0,0,[0,0]];


        difference(){
            // display the body and slot
            body_and_slot(this_cylinder_rad, center_coords, negative=false);
            cube([2.1 * this_cylinder_rad, 2 * (this_cylinder_rad * this_height_ratio), SEGMENT_HT *1.1], 
                    center=true);
            pos_center_coords = [this_negative_coords[0] + center_coords[0],
                                 this_negative_coords[1] + center_coords[1]];
            opposite_coords = [center_coords[0]-this_negative_coords[0], 
                             center_coords[1]+this_negative_coords[1]];

            neg_rad = neg_seg_details[0];

            // now the next level
            if (level < len(layer_details) - 1){
                body_and_slot(neg_rad, this_negative_coords, negative=true);
                whole_structure(level + 1, this_negative_coords);
                
                body_and_slot(neg_rad, opposite_coords, negative=true);
                whole_structure(level + 1, opposite_coords);
                
            }else{
                difference(){
                    #body_and_slot(neg_rad, pos_center_coords, negative=false);
                    translate([pos_center_coords[0], pos_center_coords[1], 0]){
                        cube([2.1 * neg_rad, 2 * neg_rad, SEGMENT_HT *1.1], center=true);
                    }
                }
                
                difference(){
                    body_and_slot(neg_rad, opposite_coords, negative=false);
                    translate([opposite_coords[0], opposite_coords[1], 0]){
                        cube([2.1 * neg_rad, 2 * neg_rad, SEGMENT_HT *1.1], center=true);
                    }
                }
            }
        }
    }

}



whole_structure();




// if (PRINT_WHOLE){
//     intersection(){
//         full_segment();

//         // translate([-37, 0, 0]){
//         //     cylinder(r=segment_rad/2.5, h=SEGMENT_HT *1.5, center=false);
//         // }
//     }
// }else{

//     if (PRINT_TOP_ARCH){
//         difference(){
//             intersection(){
//                 full_segment();
//                 chopping_cube();
//             }
//             full_segment();
//             register_spikes();
//         }
        
//     }else{
//         difference(){
//             full_segment();
//             chopping_cube();
//         }

//         register_spikes();
        
//     }
// }