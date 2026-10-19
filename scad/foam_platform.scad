include <rect.scad>
include <rounded_rectangle.scad>

$fn=40;



MAIN_CYL_HT = 20;
PLATFORM_TN = 10;
PLATFORM_RD = 100;

LEG_HT=100;
LEG_RD=5;

leg_rect_sz = (1/sqrt(2) ) * ((2*PLATFORM_RD)) - (LEG_RD*2) + 1;
leg_socket_rd = LEG_RD +0.3;
leg_holder_rd = LEG_RD + 2;
leg_socket_ht = MAIN_CYL_HT;



module platform(){
    difference(){
        union(){
            difference(){
                cylinder(h=MAIN_CYL_HT, r=PLATFORM_RD,$fn=100 );
                translate([0, 0, PLATFORM_TN]){
                    cylinder(h=30, r=PLATFORM_RD-2);
                }
            }
        
            // leg connections     
            for(lposi=rect(leg_rect_sz,leg_rect_sz)){
                translate([lposi[0], lposi[1], 0]){
                    cylinder(h=leg_socket_ht, r=leg_holder_rd);
                }
            }
        }
        for(lposi=rect(leg_rect_sz,leg_rect_sz)){
            translate([lposi[0], lposi[1], 0]){
                translate([0, 0, -3]){
                    cylinder(h=leg_socket_ht, r=leg_socket_rd);
                }
            }
        }
    }
}

// // TEST socket
// !union(){
//     intersection(){
//         platform();
//         #translate([leg_rect_sz/2 - 7, leg_rect_sz/2 -7 , -2]){
//             cube([15,15,30]);
//         }
//     }

//     // translate([50, 50, 0]){
//     //     cylinder(h=40, r=LEG_RD);
//     // }
// }




//################################################################
//     PUT IN LED HOLES
//################################################################

LED_HOLE_RD = 6/2;
LED_COLLAR_RD = 5.2/2;
LED_COLLAR_LEN = 4;
LED_HOLE_LEN = 40;




module LED_hole(){
    translate([0, 0, -LED_HOLE_LEN]){
        cylinder(h = LED_HOLE_LEN, r = LED_HOLE_RD);
    }
    #cylinder(h = LED_COLLAR_LEN + 6, r = LED_COLLAR_RD);
}

// !LED_hole();

module make_and_aim_hole(x_posi, y_posi, convergence_height){
    y_angle = atan2(x_posi,convergence_height);
    x_angle = atan2(y_posi,convergence_height); 

    translate([x_posi, y_posi, 0]){
        rotate([x_angle, 0, 0]){
            rotate([0, -y_angle, 0]){
                LED_hole();
            }
        }
    }
}




LED_TILT= 25;
module rotated_LED_hole(){
    rotate([LED_TILT, 0, 0]){
        LED_hole();
    }
}

LED_ZOS = PLATFORM_TN - LED_COLLAR_LEN;

PLATFORM_SCREWHOLE_X=120;
PLATFORM_SCREWHOLE_Y=70;
PLATFORM_SCREWHOLE_HT=20;

module platform_screwholes(rad,ht){
    screwhole_rect = rect(PLATFORM_SCREWHOLE_X,PLATFORM_SCREWHOLE_Y);
    for(hole_coord = screwhole_rect){
        translate([hole_coord[0], hole_coord[1], -15]){
            cylinder(r=rad,h=ht);
        }
    }
}


module platform_with_led_holes(){
    // rotated_LED_hole();
    LED_PERIPHERY_WD = 25;
    LED_PERIPHERY_ZOS = LED_ZOS;
    LED_CENTRE_ZOS = LED_ZOS;
    LED_PERIPHERY2_SPAN = 40;
    LED_PERIPHERY2_WD = 30;
    CONVERGENCE_HT = 50;

    CHANNEL_RD = 5/2;


    HOLE_SPACE=15;


    LED_positions = [
        [0,LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        [HOLE_SPACE,LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [40,LED_PERIPHERY_WD,3],
        [-HOLE_SPACE,LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [-40,LED_PERIPHERY_WD,3],
        [0,-LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        [HOLE_SPACE,-LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [40,-LED_PERIPHERY_WD,3],
        [-HOLE_SPACE,-LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [-40,-LED_PERIPHERY_WD,3],
        // SECOND PERIPHERY
        [LED_PERIPHERY2_SPAN,LED_PERIPHERY2_WD,LED_PERIPHERY_ZOS],
        [LED_PERIPHERY2_SPAN,LED_PERIPHERY2_WD/2,LED_PERIPHERY_ZOS],
        [LED_PERIPHERY2_SPAN,-LED_PERIPHERY2_WD/2,LED_PERIPHERY_ZOS],
        [LED_PERIPHERY2_SPAN,-LED_PERIPHERY2_WD,LED_PERIPHERY_ZOS],

        [-LED_PERIPHERY2_SPAN,LED_PERIPHERY2_WD,LED_PERIPHERY_ZOS],
        [-LED_PERIPHERY2_SPAN,LED_PERIPHERY2_WD/2,LED_PERIPHERY_ZOS],
        [-LED_PERIPHERY2_SPAN,-LED_PERIPHERY2_WD/2,LED_PERIPHERY_ZOS],
        [-LED_PERIPHERY2_SPAN,-LED_PERIPHERY2_WD,LED_PERIPHERY_ZOS],
        
    ];
    
    difference(){
        platform();
        
        //#################################################################
        // CREATE HOLES THAT ALL "POINT" INWARDS
        for(posi = LED_positions){
            translate([0, 0, posi[2]]){
                make_and_aim_hole(posi[0],posi[1],CONVERGENCE_HT);
            }
        }
        HOLE_SPACE=15;

        // HOLES IN THE CENTER ALWAYS POINT STRAIGHT UP
        for(mposi = rect(HOLE_SPACE,HOLE_SPACE)){
            translate([mposi[0], mposi[1], LED_ZOS]){
                LED_hole();
            }
        }
        translate([0, 0, 0]){
            for(mposi = rect(3*HOLE_SPACE,HOLE_SPACE)){
                translate([mposi[0], mposi[1], LED_ZOS]){
                    LED_hole();
                }
            }
        }
        //#############################################################################
        // wire channels
        // translate([0, 27, 0]){
        //     rotate([0, 90, 0]){
        //         cylinder(r=CHANNEL_RD,h=100,center=true);
        //     }
        // }
        // translate([0, -27, 0]){
        //     rotate([0, 90, 0]){
        //         cylinder(r=CHANNEL_RD,h=100,center=true);
        //     }
        // }

        // translate([0, 7, 0]){
        //     rotate([0, 90, 0]){
        //         cylinder(r=CHANNEL_RD,h=100,center=true);
        //     }
        // }
        // translate([0, -7, 0]){
        //     rotate([0, 90, 0]){
        //         cylinder(r=CHANNEL_RD,h=100,center=true);
        //     }
        // }

        // translate([45, 0, 0]){
        //     rotate([90, 0, 0]){
        //         cylinder(r=CHANNEL_RD,h=80,center=true);
        //     }
        // }
        // translate([-45, 0, 0]){
        //     rotate([90, 0, 0]){
        //         cylinder(r=CHANNEL_RD,h=80,center=true);
        //     }
        // }

        // // diagonals to the legs
        // diag_posi_matrix = [
        //     [1,1,1],
        //     [1,-1,-1],
        //     [-1,-1,1],
        //     [-1,1,-1]
        // ];

        // for(diag_posi = diag_posi_matrix){
        //     translate([diag_posi[0] * 55, diag_posi[1] * 50, 0]){
        //         rotate([0, 0, diag_posi[2] * -40]){
        //             rotate([90, 0, 0]){
        //                 cylinder(r=CHANNEL_RD,h=33,center=true);
        //             }
        //         }
        //     }
        // }

        // screwholes
        platform_screwholes(4.2/2,PLATFORM_SCREWHOLE_HT);
        
    }
    
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
platform_with_led_holes();
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


// plate
module plate(){
    screwhole_support_rect = rect(PLATFORM_SCREWHOLE_X,PLATFORM_SCREWHOLE_Y);
    translate([0, 0, 0]){
        difference(){
            union(){
                cube([130,80,2],center=true);
                
    
                for(sup_posi=screwhole_support_rect){
                    translate([sup_posi[0], sup_posi[1], -2]){
                        cylinder(r=5,4,center=true);
                    }
                }
            }
            platform_screwholes(3.5/2,PLATFORM_SCREWHOLE_HT);
            for(ctr_posi=screwhole_support_rect){
                translate([ctr_posi[0], ctr_posi[1], -2.1]){
                    cylinder(r2=2, r1=6,h=4,center=true);
                }
            }
        }
        translate([0, 0, -2]){
            difference(){
                cube([120,50,4],center=true);
                cube([115,45,5],center=true);
            }
        }
        
    }
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
// plate();
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








SUPPORT_HT = 30;
SUPPORT_WD = 50;
SUPPORT_TN = 5;
leg_support_posis =[
    [0,0],
    [SUPPORT_WD,0],
    [SUPPORT_WD/2,SUPPORT_HT]
];

module leg_support(){
    translate([-SUPPORT_WD/2, 0, -LEG_HT]){
        rotate([90, 0, 0]){
            linear_extrude(height=SUPPORT_TN, center=true){
                polygon(leg_support_posis);
            }
        }
    }
}






module base_platform(){

    // the legs
    leg_posis = rect(leg_rect_sz, leg_rect_sz);
    difference(){
        for (posi = leg_posis){
            translate([posi[0], posi[1], -100]){
                cylinder(h=LEG_HT, r=LEG_RD);
            }
    
            // leg support base strut thingies
            translate([posi[0], posi[1], 0]){
                rotate([0, 0, -atan2(posi[0], posi[1])]){
                    leg_support();
                }
            }
        }

        // hollow out a leg for wires
        LEG_IDX=1;
        translate([leg_posis[LEG_IDX][0],leg_posis[LEG_IDX][1], -98]){
            cylinder(r=LEG_RD-2,h=LEG_HT);

            // holes for wire egress
            // bottom
            translate([-2, 2, 5]){
                rotate([0, 0, 45]){
                    cube([4,10,10],center=true);
                }
            }
            // top
            translate([-2, 4, LEG_HT- 20]){
                rotate([0, 0, 30]){
                    cube([4,10,7],center=true);
                }
            }
        }

    }


    // the base 
    translate([0, 0, -LEG_HT ]){
        difference(){
            cylinder(h=MAIN_CYL_HT, r=PLATFORM_RD,$fn=300);
            translate([0, 0, 2]){
                cylinder(h=30, r=PLATFORM_RD-2);
            }
        }
    }
}
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// base_platform();
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



// CONTROL PANEL
SWITCH_HOLE_HT = 14;
SWITCH_HOLE_WD = 9;
SWITCH_HOLE_DP = 4;

PANEL_HT = 40;
PANEL_WD = 80;
PANEL_TN = 2;
PANEL_ANG = 45;

// panel
module panel(){
    intersection(){
        rotate([PANEL_ANG, 0, 0]){
            difference(){
                translate([0, 0, 0]){
                    cube([PANEL_WD, PANEL_HT, PANEL_TN], center=true);
                }
                for(switch_x = [-20,0,20]){
                    translate([switch_x, 0, 0]){
                        cube([SWITCH_HOLE_WD, SWITCH_HOLE_HT, SWITCH_HOLE_DP], center=true);
                    }
                }
            }
        }
        translate([0, 88 , 0]){
            cylinder(h=100, r=PLATFORM_RD, center=true);
        }
    }
    // panel support
}



// BASE PLATFORM WITH PANEL
module base_platform_with_panel(){
    difference(){
        union(){
            base_platform();
            translate([0,-88, -80]){
                panel();
            }
        }
    
        translate([0, -100, -76.5]){
            rotate([45, 0, 0]){
                cube(size=[100, 100, 20], center=true);
            }
        }
    
    }
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// Testing model
// difference(){
//     union(){
//         translate([0, 0, 16.9]){
            // base_platform_with_panel();
//         }
//         // plate();
//         // platform_with_led_holes();
//     }

//     // // Chop out window to see how they fit
//     // translate([78, -78, 0]){
//     //     rotate([0, 0, 45]){
//     //         cube([60,30,60],center=true);
//     //     }
//     // }
// }


//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// test-ring of pillar
// intersection(){
//     base_platform_with_panel();

//     #translate([70, -70, 0]){
//         cube([20,20,20],center=true);
//     }
// }






//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// power bank for modelling only
module rounded_edge(length,radius){
    offset_dist = length/2 - radius;
    hull(){
        translate([offset_dist, 0, 0]){
            sphere(r=radius);
        }
        translate([-offset_dist, 0, 0]){
            sphere(r=radius);
        }
    }
}


module rounded_face(length, height, radius){
    offset_dist = height/2 - radius;
    offset_ht = length/2 - radius;
    hull(){
        translate([0,offset_dist, 0]){
            rounded_edge(length, radius);
        }
        translate([0, -offset_dist, 0]){
            rounded_edge(length, radius);
        }
    }
}

// translate([0, 0, -70]){
//     color("black",1.0){
//         rounded_face(140,65,7);
//     }
// }








