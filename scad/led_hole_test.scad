include <rect.scad>
include <rounded_rectangle.scad>

$fn=40;


LED_HOLE_RD = 6/2;
LED_COLLAR_RD = 5.2/2;
LED_HOLE_LEN = 40;

module LED_hole(led_hole_rd, led_collar_rd){
    translate([0, 0, -LED_HOLE_LEN]){
        cylinder(h = LED_HOLE_LEN, r = led_hole_rd);
    }
    cylinder(h = 6, r = led_collar_rd);
}

LED_TILT= 25;
module rotated_LED_hole(){
    rotate([LED_TILT, 0, 0]){
        LED_hole();
    }
}



difference(){
    cube([20,20,2],center=true);
    LED_hole(LED_HOLE_RD,LED_COLLAR_RD);
}


