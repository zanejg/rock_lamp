include <rect.scad>
include <rounded_rectangle.scad>

$fn=40;


BOWL_RD = 75;
BOWL_LN = 200;
SHELL_TN = 2;


sphere_separation = BOWL_LN - (BOWL_RD*2);

module base_bowl(){
    translate([0, 0, BOWL_RD]){
        difference(){
            hull(){
                translate([sphere_separation/2, 0, 0]){
                    sphere(r=BOWL_RD);
                }
                translate([-sphere_separation/2, 0, 0]){
                    sphere(r=BOWL_RD);
                }
            }
            translate([0, 0, BOWL_RD/2]){
                cube([BOWL_LN*1.5,BOWL_RD*2.2,BOWL_RD*2],center=true);
            }
        }
        translate([0, 0, -(BOWL_RD - 12)]){
            cube([sphere_separation*2.5,BOWL_RD,25],center=true);
        }
    }
}



module main_bowl(){
    scale_factor = (BOWL_LN-(2*SHELL_TN))/BOWL_LN;
    difference(){
        base_bowl();
        translate([0, 0, SHELL_TN]){
            scale([scale_factor,scale_factor,scale_factor]){
                base_bowl();
            }
        }
    }
}

// rotate([0, 0, 0]){
//     main_bowl();
// }


CRADLE_RD=200;
CRADLE_BASE_WD=140;
CRADLE_BASE_HT=100;
CRADLE_BASE_DP=10;
CRADLE_BASE_CNR_RD=10;

module cradle_base_rdrect() {
  rounded_rectangle_prism(CRADLE_BASE_WD, CRADLE_BASE_HT, CRADLE_BASE_DP, CRADLE_BASE_CNR_RD);
}

module cradle(){
    translate([0, 0, CRADLE_RD]){
        difference(){
            hull(){
                intersection(){     
                    sphere(r=CRADLE_RD);
                                        
                    translate([0, 0, -CRADLE_RD]){
                        scale([1.5,1,1]){
                            sphere(r = 60);
                        }
                    }
                }
                translate([0, 0, -CRADLE_RD]){
                    // cube([140,100,1],center=true);
                    cradle_base_rdrect();
                }
            }
            sphere(r=CRADLE_RD - SHELL_TN);
        }
    }
}

//################################################################
//     PUT IN LED HOLES
//################################################################

LED_HOLE_RD = 6/2;
LED_COLLAR_RD = 5.2/2;
LED_HOLE_LEN = 40;

module LED_hole(){
    translate([0, 0, -LED_HOLE_LEN]){
        cylinder(h = LED_HOLE_LEN, r = LED_HOLE_RD);
    }
    cylinder(h = 6, r = LED_COLLAR_RD);
}

LED_TILT= 25;
module rotated_LED_hole(){
    rotate([LED_TILT, 0, 0]){
        LED_hole();
    }
}

module cradle_with_led_holes(){
    // rotated_LED_hole();
    LED_PERIPHERY_WD = 30;
    LED_PERIPHERY_ZOS = 0.5;

    LED_positions = [
        [0,LED_PERIPHERY_WD,0],
        [20,LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [40,LED_PERIPHERY_WD,3],
        [-20,LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [-40,LED_PERIPHERY_WD,3],
        [0,-LED_PERIPHERY_WD,0],
        [20,-LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [40,-LED_PERIPHERY_WD,3],
        [-20,-LED_PERIPHERY_WD,LED_PERIPHERY_ZOS],
        // [-40,-LED_PERIPHERY_WD,3],
        
    ];
    
    
    
    difference(){
        cradle();
        
        // CREATE HOLES THAT ALL "POINT" INWARDS
        for(posi = LED_positions){
            translate([posi[0], posi[1], 2.5+posi[2]]){
                if(posi[0] != 0){
                    // echo("for x=",posi[0]," y=",posi[1]," rotated ",atan(posi[1]/posi[0])," degrees");
                    // we have to add 180 degrees when the Y coord in negative
                    echo("flip angle=",(180* ((LED_PERIPHERY_WD +(posi[1]*-1)))/(2*LED_PERIPHERY_WD)));
                    rotate([0, 0, 
                            -atan(posi[0]/posi[1]) + (180* ((LED_PERIPHERY_WD +(posi[1]*-1)))/(2*LED_PERIPHERY_WD))]){
                    // union(){
                        rotated_LED_hole();
                    }
                }
                else{
                    rotate([0, 0, (180* ((LED_PERIPHERY_WD +(posi[1]*-1)))/(2*LED_PERIPHERY_WD))]){
                        rotated_LED_hole();
                    }
                }
            }
        }
        
        // HOLES IN THE CENTER ALWAYS POINT STRAIGHT UP
        for(mposi = rect(20,20)){
            translate([mposi[0], mposi[1], -1]){
                LED_hole();
            }
        }
        translate([0, 0, 4]){
            for(mposi = rect(60,20)){
                translate([mposi[0], mposi[1], -1]){
                    LED_hole();
                }
            }
        }
    }
    
}



!cradle_with_led_holes();




// battery box
LEG_HT=70;

translate([0, 0, -10]){
    cradle_base_rdrect();
}
for(leg_posi = rect(CRADLE_BASE_WD - CRADLE_BASE_CNR_RD*2,CRADLE_BASE_HT - CRADLE_BASE_CNR_RD*2)){
    translate([leg_posi[0], leg_posi[1], -LEG_HT/2]){
        cylinder(h = LEG_HT, r = CRADLE_BASE_CNR_RD,center=true);
    }
}
// bottom box
neg_box_scale_x_coeff=(CRADLE_BASE_WD-SHELL_TN*2)/CRADLE_BASE_WD;
neg_box_scale_y_coeff=(CRADLE_BASE_HT-SHELL_TN*2)/CRADLE_BASE_HT;


translate([0, 0, -LEG_HT]){
    difference(){
        cradle_base_rdrect();
        translate([0, 0, SHELL_TN]){
            scale([neg_box_scale_x_coeff,neg_box_scale_y_coeff,1]){
                cradle_base_rdrect();
            }
        }
    }
}





// posi = LED_positions[3];

// echo("angle=",atan(posi[1]/posi[0]));
// translate([posi[0], posi[1], 0]){
//     rotate([0, 0, (-atan(posi[0]/posi[1]))]){
//         rotated_LED_hole();
//     }
// }


