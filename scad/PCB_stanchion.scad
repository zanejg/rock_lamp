$fn=40;

WHOLE_HT = 10;
BASE_RD = 18/2;
BASE_HT = 2;
SHAFT_RD = 9/2;

FILLET_RD = 3;


difference(){
    union(){
        cylinder(h =BASE_HT , r = BASE_RD);
        
        cylinder(h = WHOLE_HT, r = SHAFT_RD);
        
        difference(){
            cylinder(h = FILLET_RD + BASE_HT, r = SHAFT_RD + FILLET_RD);
        
            translate([0, 0, FILLET_RD + BASE_HT]){
                rotate_extrude(angle=360) {
                    translate([SHAFT_RD + FILLET_RD, 0, 0]){
                        circle(r = FILLET_RD);
                    }
                }
                
            }
        }
    }
    cylinder(h = WHOLE_HT * 1.1, r = 2/2);
}