include <swirl_common_vars.scad>

include <modelling_tests.scad>

$fn=100;

IS_AN_END_PIECE = true;

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
                //remove the cavity 
                translate([0,0,9]){
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
// BOX_TN = 2.5;
// cavity_ht = 40;
// MBOX_WD = 100;
// TAB_LN = 30;
// cavity_wd = MBOX_WD -(BOX_TN *4);
// tab_ht = cavity_ht - BOX_TN;
// str_ang_cos = cos(straight_ang);
// str_ang_sin = sin(straight_ang);
// swirl_center_y = (STRAIGHT_LN*2) * str_ang_cos + (str_ang_sin * (SHAPE_WD + 2*INNER_RD));
// swirl_center_x = SHAPE_WD + INNER_RD + inter_swirl_gap/2 - (INNER_RD * (1-str_ang_cos));
// SCREW_STANCHION_RD = 9/2;
// SCREWHOLE_Y = 47;
// SCREWHOLE_X_OS = 43;

// SCREWHOLE_PAIR_XY=[
//     [swirl_center_x + SCREWHOLE_X_OS,SCREWHOLE_Y],
//     [swirl_center_x - SCREWHOLE_X_OS,SCREWHOLE_Y]
// ];



module glue_tab_shape(){
    cube([TAB_LN/2, BOX_TN*1.5, tab_ht *0.4], center=true);
    translate([0, 0, tab_ht * 0.6]){
        cube([TAB_LN/2, BOX_TN*1.5, tab_ht *0.4], center=true);
    }
}

module one_main_section(){
    intersection(){
        union(){
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
        
                    // Cylinder loop strengthening
                    intersection(){
                        union(){
                            // corner ends
                            translate([110, -52, 20]){
                                rotate([45, 0, 0]){
                                    cube([10, 25, BOX_TN], center=true);
                                }
                            }
                            translate([6, -52, 20]){
                                rotate([45, 0, 0]){
                                    cube([10, 25, BOX_TN], center=true);
                                }
                            }
                            // diag struts
                            translate([30, -86, 20]){
                                rotate([0, 0, 60]){
                                    rotate([-45, 0, 0]){
                                        cube([10, 45, BOX_TN], center=true);
                                    }
                                }
                            }
                            translate([86, -86, 20]){
                                rotate([0, 0, -60]){
                                    rotate([-45, 0, 0]){
                                        cube([10, 45, BOX_TN], center=true);
                                    }
                                }
                            }
        
                        }
                        // trim off anything outside the loop
                        translate([58, -36, 0]){
                            cylinder(h = 50, r = 56);
                        }
                    }
                }
                // Main box cavity
                translate([-0.5, -40, -BOX_TN]){
                    cube([section_wd + 1,cavity_wd ,cavity_ht ], center=false);   
                }
            
                // cable holes
                translate([25, -34, 40]){
                    cube([12,8 , 10], center=true);
                }
                translate([90, -34, 40]){
                    cube([12,8 , 10], center=true);
                }
                // glue tab cavities
                translate([TAB_LN/4, -40 - (BOX_TN* 0.25), tab_ht *0.2]){
                    glue_tab_shape();
                }
        
                translate([section_wd - TAB_LN/4, 50 + (BOX_TN* 0.25), tab_ht *0.2]){
                    glue_tab_shape();
                }
            
                
            }
            

            difference(){
                union(){
                    //################################################
                    // GLUE SURFACES
                    translate( [swirl_center_x, 
                                -swirl_center_y, 
                                box_ht ]){
                        cylinder(h = BOX_TN, r = INNER_RD * 1.5);
                    }
        
                    
                    translate([58, 0, box_ht + BOX_TN/2]){
                        cube([100, 15, BOX_TN], center=true);
                    }
                    
                    translate([swirl_center_x - 43, 30, box_ht + BOX_TN/2]){
                        difference(){
                            cube([15, 52, BOX_TN], center=true);
                            translate([2, 28, 0]){
                                rotate([0, 0, -20]){
                                    cube([20, 10, 12], center=true);
                                }
                            }
                        }
                    }
                    translate([swirl_center_x + 43, 30, box_ht + BOX_TN/2]){
                        difference(){
                            cube([15, 52, BOX_TN], center=true);
                            translate([0, 28, 0]){
                                rotate([0, 0, 20]){
                                    cube([20, 10, 12], center=true);
                                }
                            }
                        }
                    }

                    translate([swirl_center_x + SHAPE_WD +2.5, -22, box_ht + BOX_TN/2]){
                        difference(){
                            rotate([0, 0, 20]){
                                cube([10, 35, BOX_TN], center=true);
                            }
                            translate([11, 0, 0]){
                                rotate([0, 0, 10]){
                                    cube([20, 45, 12], center=true);
                                }
                            }
                        }
                    }

                    translate([swirl_center_x - SHAPE_WD -2.5, -22, box_ht + BOX_TN/2]){
                        difference(){
                            rotate([0, 0, -20]){
                                cube([10, 35, BOX_TN], center=true);
                            }
                            translate([-11, 0, 0]){
                                rotate([0, 0, -10]){
                                    cube([20, 45, 12], center=true);
                                }
                            }
                        }
                    }

                    translate([swirl_center_x+18, -20, box_ht + BOX_TN/2]){
                        rotate([0, 0, 50]){
                            cube([SHAPE_WD -10, 8, BOX_TN], center=true);
                        }
                    }
                    translate([swirl_center_x-18, -20, box_ht + BOX_TN/2]){
                        rotate([0, 0, -50]){
                            cube([SHAPE_WD -10, 8, BOX_TN], center=true);
                        }
                    }

                    translate([swirl_center_x + 26, 18, box_ht + BOX_TN/2]){
                        rotate([0, 0, -50]){
                            cube([SHAPE_WD -10, 8, BOX_TN], center=true);
                        }
                    }
                    translate([swirl_center_x - 27, 18, box_ht + BOX_TN/2]){
                        rotate([0, 0, 50]){
                            cube([SHAPE_WD -10, 8, BOX_TN], center=true);
                        }
                    }



                    // Front base circular thickening
                    swirl_rd = (INNER_RD + SHAPE_WD) * 0.98;
                    translate([swirl_center_x - 0.1, -swirl_center_y ,  box_ht + BOX_TN/2]){
                        difference(){
                            cylinder(h = BOX_TN, r = swirl_rd, center = true);
                            cylinder(h = BOX_TN * 1.1, r = swirl_rd - 5, center = true);
                            translate([0, SHAPE_WD-5, 0]){
                                cube([SHAPE_WD * 2.2, SHAPE_WD * 1.5 , BOX_TN * 1.1], center=true);
                            }
                        }
                    }




                    //##############################################


                    // screwhole stanchions
                    for(posi = SCREWHOLE_PAIR_XY){
                        translate([posi[0], posi[1], box_ht + 0.1]){
                            cylinder(h = 10, r = SCREW_STANCHION_RD);
                        }
                    }
                    // strengthening for screw arms
                    translate([swirl_center_x + 43, 25, box_ht + 3]){
                        rotate([0, 0, 12]){
                            cube([BOX_TN, 52, 6], center=true);
                        }
                    }
                    translate([swirl_center_x - 43, 25, box_ht + 3]){
                        rotate([0, 0, -12]){
                            cube([BOX_TN, 52, 6], center=true);
                        }
                    }
        
                }
                // screwholes
                for(posi = SCREWHOLE_PAIR_XY){
                    translate([posi[0], posi[1], box_ht]){
                        cylinder(h = 10, r = 2/2);
                    }
                }
                translate([swirl_center_x, 
                                -swirl_center_y, 
                                box_ht - 1 ]){
                    cylinder(h = 5, r = 3.5/2);
                    translate([0, 0, 1.1]){
                        cylinder(h = 2.5, r2 = 7/2, r1=2/2);
                    }
                }

            }
        }

        // define top part
        translate([50, 0, box_ht + 45 ]){
            cube([150, 200, 90], center=true);
        }
    }

    //###############################################
    // For the end piece
    if(IS_AN_END_PIECE){
        
        hull(){
            translate([0, INNER_RD, 0]){
                rotate([90, 0, 90]){
                    linear_extrude(height = 0.1) {
                        polygon(points = [shape_pts[2],shape_pts[3],shape_pts[4]]);
                    }
                }
            }
            hull(){
                translate([0, SHAPE_WD/2 + INNER_RD, box_ht + 0.5]){
                    cube([1,SHAPE_WD ,1 ], center=true);
                }
                translate([-10, SHAPE_WD/2 + INNER_RD, box_ht + 0.5]){
                    cube([1,1 ,1 ], center=true);
                }
            }
        }
    }

}

//one_main_section();

mirror(v = [1,0,0]){
    one_main_section();
} 

// difference(){
//     one_main_section();
//     translate([50, 0, 100]){
//         cube([150, 200, 80], center=true);
//     }
// }


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


