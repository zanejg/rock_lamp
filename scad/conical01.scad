include <../utils/rect.scad>
$fn=60;

BASE_RD = 75;
BASE_WD = 300;
base_circle_separation = BASE_WD - 2 * BASE_RD;

MAIN_SHELL_TN = 2;


DISPLAY_SURFACE_RD = 70;
DISPLAY_SURFACE_WD = 250;
display_surface_circle_separation = DISPLAY_SURFACE_WD - 2 * DISPLAY_SURFACE_RD;
DISPLAY_SURFACE_ANGLE = 60;
DISPLAY_SURFACE_HT_OS = 80;


module main_shell_shape(){
    hull(){
        // BASE
        hull(){
            translate([base_circle_separation/2, 0, 0]){
                cylinder(r = BASE_RD, h = 1);
            }
            translate([-base_circle_separation/2, 0, 0]){
                cylinder(r = BASE_RD, h = 1);
            }
        }
        
        // DISPLAY SURFACE
        
        translate([0, -60, DISPLAY_SURFACE_HT_OS]){
            rotate([DISPLAY_SURFACE_ANGLE, 0, 0]){
                hull(){
                    translate([display_surface_circle_separation/2, 0, 0]){
                        cylinder(r = DISPLAY_SURFACE_RD, h = 1);
                    }
                    translate([-display_surface_circle_separation/2, 0, 0]){
                        cylinder(r = DISPLAY_SURFACE_RD, h = 1);
                    }
                }
            }
        }
    }
}



module main_shell(){
    shell_ht = DISPLAY_SURFACE_RD * sin(DISPLAY_SURFACE_ANGLE) + DISPLAY_SURFACE_HT_OS;
    x_scaler = (BASE_WD - 2*MAIN_SHELL_TN)/BASE_WD;
    y_scaler = ((2*BASE_RD) - 2*MAIN_SHELL_TN) / (2*BASE_RD);
    z_scaler = (shell_ht - 2*MAIN_SHELL_TN) / shell_ht;
    
    difference(){
        main_shell_shape();
        // hollow out the inside of the shell
        translate([0, 0, -0.1]){
            scale([x_scaler, y_scaler, z_scaler]){
                main_shell_shape();
            }
        }


    }
}


WINDOW_CNR_RAD = 6;
WINDOW_WD = 200;
WINDOW_HT = 100;
// WINDOW_CNR_;


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
// !rounded_edge(WINDOW_WD, WINDOW_CNR_RAD);

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
// !rounded_face(WINDOW_WD, WINDOW_HT, WINDOW_CNR_RAD);

module rounded_box(length, height, depth, radius){
    offset_dist = depth/2 - radius;
    hull(){
        translate([0,0, offset_dist]){
            rounded_face(length, height, radius);
        }
        translate([0, 0, -offset_dist]){
            rounded_face(length, height, radius);
        }
    }
}

// !rounded_box(100, 50, 60,WINDOW_CNR_RAD);




module rounded_rectangle_prism(width, height, depth, corner_radius){
    horiz_dist = width/2 - corner_radius;
    vert_dist = height/2 - corner_radius;
    hull(){
        translate([0, vert_dist, 0]){
            hull(){
                translate([horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
                translate([-horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
            }
        }
        translate([0, -vert_dist, 0]){
            hull(){
                translate([horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
                translate([-horiz_dist, 0, 0]){
                    cylinder(r=corner_radius, h=depth, center=true);
                }
            }
        }
    }
}

// !rounded_rectangle_prism(WINDOW_WD, WINDOW_HT, 1, WINDOW_CNR_RAD);



CRADLE_DEPTH = 60;
// cradle dimensions need to slide into the window with a little clearance
cradle_width = WINDOW_WD - 2;
cradle_height = WINDOW_HT - 2;
cradle_cavity_width = cradle_width - 2*MAIN_SHELL_TN;
cradle_cavity_height = cradle_height - 2*MAIN_SHELL_TN;
cradle_cavity_depth = CRADLE_DEPTH + 2*MAIN_SHELL_TN;

// cradle insert
module cradle_shape(){
    
    // main box shape
    intersection(){
        difference(){
            rounded_box(cradle_width, cradle_height, CRADLE_DEPTH, WINDOW_CNR_RAD);
            translate([0, 0, CRADLE_DEPTH/2]){
                cube([cradle_width*1.1, cradle_height*1.1, WINDOW_CNR_RAD*2], center=true);
            }
        }
        // to chop off the top corner to fit
        translate([-0, -46, 54]){
            rotate([0, 90, 0]){
                cylinder(r=100, h=cradle_cavity_width *1.1, center=true);
            }
        }
    }
    
}

RIM_SIZE=6;
module cradle_rim(){

    color("lightgreen",1.0){
        difference(){
            rounded_rectangle_prism(cradle_width + RIM_SIZE, cradle_height + RIM_SIZE, MAIN_SHELL_TN, WINDOW_CNR_RAD*2);
            translate([0, 0, MAIN_SHELL_TN-0.1]){
                // scale([cradle_hollow_width_factor, cradle_hollow_ht_factor, cradle_hollow_depth_factor]){
                    rounded_rectangle_prism(cradle_cavity_width, cradle_cavity_height, MAIN_SHELL_TN*3, WINDOW_CNR_RAD);
                // }
            }
        }
    }
}

// !cradle_rim();

cradle_hollow_width_factor = cradle_cavity_width/cradle_width;
cradle_hollow_ht_factor = cradle_cavity_height/cradle_height;
cradle_hollow_depth_factor = cradle_cavity_depth/CRADLE_DEPTH;



module cradle(){
    difference(){
        union(){
            color("yellow",1.0){
                difference(){
                    cradle_shape();
                    translate([0, 0, MAIN_SHELL_TN]){
                        scale([cradle_hollow_width_factor, cradle_hollow_ht_factor, cradle_hollow_depth_factor]){
                            cradle_shape();
                        }
                    }
                }
            }
            translate([0, 0, CRADLE_DEPTH/2 - MAIN_SHELL_TN*3]){
                cradle_rim();
            }
        }
        // diffuser window
        translate([0, -25, -CRADLE_DEPTH/2]){
            cube([DIFFUSER_WIDTH+1, DIFFUSER_HEIGHT+1, 2*MAIN_SHELL_TN], center=true);
        }
    }
}




DIFFUSER_WIDTH = 100;
DIFFUSER_HEIGHT = 30;
DIFFUSER_DEPTH = 10;
LED_MOUNT_HT = 10;
SCREWHOLE_RD=3/2-0.25;
screwhole_dp = DIFFUSER_DEPTH;
module diffuser(){
    color("lightblue", 0.8){
        whole_diffuser_ht = DIFFUSER_DEPTH+ LED_MOUNT_HT;
        difference(){
            cube([DIFFUSER_WIDTH, DIFFUSER_HEIGHT, whole_diffuser_ht], center=true);
    
            translate([0, 0, -DIFFUSER_DEPTH/2 - LED_MOUNT_HT/2]){
                cube([DIFFUSER_WIDTH-20, DIFFUSER_HEIGHT- MAIN_SHELL_TN*2, LED_MOUNT_HT], center=true);
            }

            screwhole_x_os = DIFFUSER_WIDTH/2-4;
            echo("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            echo( "Screwholes are ",screwhole_x_os*2, "mm apart");
            echo("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            screwhole_z_os = -(DIFFUSER_DEPTH/2);

            #translate([screwhole_x_os, 0, -(whole_diffuser_ht - screwhole_dp + 0.1)]){
                cylinder(h = screwhole_dp, r = SCREWHOLE_RD);
            }
            #translate([-screwhole_x_os, 0, -(whole_diffuser_ht - screwhole_dp + 0.1)]){
                cylinder(h = screwhole_dp, r = SCREWHOLE_RD);
            }
        }
    }
}

BASE_WALL_HT = 8;

module flat_base(){
    // BASE
    flat_base_rd = BASE_RD + 2*MAIN_SHELL_TN;
    // flat bottom base
    hull(){
        translate([base_circle_separation/2, 0, 0]){
            cylinder(r = flat_base_rd, h = MAIN_SHELL_TN);
        }
        translate([-base_circle_separation/2, 0, 0]){
            cylinder(r = flat_base_rd, h = MAIN_SHELL_TN);
        }
    }
    // base walls
    base_wall_scale_factor = (BASE_RD +1 ) / flat_base_rd;

    difference(){
        hull(){
            translate([base_circle_separation/2, 0, 0]){
                cylinder(r = flat_base_rd, h = BASE_WALL_HT);
            }
            translate([-base_circle_separation/2, 0, 0]){
                cylinder(r = flat_base_rd, h = BASE_WALL_HT);
            }
        }
        translate([0, 0, 0.1]){
            scale([base_wall_scale_factor,base_wall_scale_factor,1]){
                hull(){
                    translate([base_circle_separation/2, 0, 0]){
                        cylinder(r = flat_base_rd, h = BASE_WALL_HT);
                    }
                    translate([-base_circle_separation/2, 0, 0]){
                        cylinder(r = flat_base_rd, h = BASE_WALL_HT);
                    }
                }
            }
        }

        shape_scale_factor = (BASE_RD*2 +1)/(BASE_RD*2);
        scale([shape_scale_factor,shape_scale_factor,1]){
            main_shell_shape();
        }
    }
}


flat_base();


module power_bank(){
    color("black",1.0){
        rounded_rectangle_prism(74, 150, 15, 10);
    }
}


translate([0, 35, 70]){
    rotate([-55, 0, 0]){
        rotate([0, 0, 90]){
            power_bank();
        }
    }
}

// ASSEMBLY OF WHOLE THING
difference(){

    union(){
        // the shell with the window
        difference(){
            main_shell();
            translate([0, -60, DISPLAY_SURFACE_HT_OS]){
            rotate([DISPLAY_SURFACE_ANGLE, 0, 0]){
                    rounded_rectangle_prism(WINDOW_WD, WINDOW_HT, 5, WINDOW_CNR_RAD);
                }
            }
        }
        translate([0, -60, DISPLAY_SURFACE_HT_OS]){
            rotate([DISPLAY_SURFACE_ANGLE, 0, 0]){
                translate([0, 0, -CRADLE_DEPTH/2 + MAIN_SHELL_TN*4]){
                    cradle();
                }

                // diffuser
                translate([0, -25, -CRADLE_DEPTH - LED_MOUNT_HT/2 + MAIN_SHELL_TN * 2] ){
                    diffuser();
                }
            }

            
        }
    }

    
}

