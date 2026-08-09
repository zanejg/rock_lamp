$fn = 100;

SEGMENT_HT = 20;
TAIL_WD = 10;
TAIL_HT = 3;
TOOTH_BITE = 2;

segment_rad = 5;




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


color("yellow",1.0){
    translate([0, 0, 0]){
        rotate_extrude(angle=180, convexity=10){
            polygon(rotating_segment_shape);
        }
    }
}


FAN_VERTICAL_OS = 0.1;
MAIN_OS = 0.2;
RADIUS_OS = 0.2;
BULGE_SZ = 0.5;
neg_segment_rad = segment_rad + RADIUS_OS;


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


difference(){
    translate([-neg_segment_rad, neg_segment_rad * 0.75, -(SEGMENT_HT *1.5)/6]){
        cube([2 * segment_rad, segment_rad, SEGMENT_HT *1.5], center=false);
    }
    rotate_extrude(angle=180, convexity=10){
        polygon(negative_segment_shape);
    }
}






