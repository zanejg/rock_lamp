include <strip_connector_male.scad>
include <dual_H-bridge_board.scad>

// Main PCB
module main_pcb(){
    color("green",1.0){
        cube([150, 90, 1.5], center=true);
    }
    
}

// ESP32
module esp32(){
    color("darkblue",1.0){
        cube([48, 28, 1.5], center=true);
    }
    translate([-15.5, 0, 2]){
        cube([17, 16, 2.5], center=true);
    }
    color("black",1.0){
        translate([-26, 0, 1.2]){
            cube([9, 18, 0.8], center=true);
        }
    }
    
    
    translate([21.5, 0, 1.7]){
        cube([6.5,7.5 , 2.5], center=true);
    }
    
    translate([-22.5, -12.5, 2]){
        rotate([180, 0, 0]){
            multi_male_connector(19);
        }
    }
    translate([-22.5, 12.5, 2]){
        rotate([180, 0, 0]){
            multi_male_connector(19);
        }
    }
}


// dual_H_bridge();
// dual_screw_connector();

module main_board(){
    
    main_pcb();
    translate([20, -3, 12]){
        esp32();
    }
    
    
    for(x=[65: -26 : -50]){
        translate([x, 25, 12]){
            rotate([45, 0, 0]){
                rotate([0, 180, 0]){
                    dual_H_bridge();
                }
            }
        }
    }
    
    
    translate([-60, 25, 12]){
        rotate([0, 0, 90]){
            rotate([45, 0, 0]){
                rotate([0, 180, 0]){
                    dual_H_bridge();
                }
            }
        }
    }
    
    color("lightgreen",1.0){
        for(scx = [55:-26:-60]){
            translate([scx, 41, 0.8]){
                dual_screw_connector();
            }
            translate([scx-10, 41, 0.8]){
                dual_screw_connector();
            }
        }
        
        translate([-70, -10, 0]){
            rotate([0, 0, 90]){
                dual_screw_connector();
            }
        }
        translate([-70, 25, 0]){
            rotate([0, 0, 90]){
                dual_screw_connector();
            }
        }
    
    }
}


BBANK_WD = 68;
BBANK_TN = 15.5;
BBANK_LN = 136;
bbank_rd = BBANK_TN/2;
bbank_swd = BBANK_WD - (bbank_rd*2);
bbank_sln = BBANK_LN - (bbank_rd*2);

module power_bank(){
    color("blue",1.0){
        hull(){
            translate([0,bbank_sln/2 , 0]){
                hull(){
                    translate([bbank_swd/2, 0, 0]){
                        sphere(r = bbank_rd);
                    }
                    translate([-bbank_swd/2, 0, 0]){
                        sphere(r = bbank_rd);
                    }
                }    
            }
            translate([0,-bbank_sln/2 , 0]){
                hull(){
                    translate([bbank_swd/2, 0, 0]){
                        sphere(r = bbank_rd);
                    }
                    translate([-bbank_swd/2, 0, 0]){
                        sphere(r = bbank_rd);
                    }
                }    
            }
        }
    }
    
}
