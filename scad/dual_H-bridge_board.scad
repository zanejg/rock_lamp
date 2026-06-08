include <strip_connector_male.scad>
include <screw_connector.scad>

$fn=20;
WIDTH = 23.3;
LENGTH = 29.1;
DEPTH = 1.5;

PCB_MNT_HOLE_RAD = 3/2;


hole_pts = [
    [1.4+PCB_MNT_HOLE_RAD,4.4+PCB_MNT_HOLE_RAD],
    [19.3 + PCB_MNT_HOLE_RAD,4.4+PCB_MNT_HOLE_RAD],
    [1.4+PCB_MNT_HOLE_RAD,17.8+PCB_MNT_HOLE_RAD],
    [19.3 + PCB_MNT_HOLE_RAD,17.8+PCB_MNT_HOLE_RAD],
];
module dual_H_bridge(){
    
    difference(){
        // THE ACTUAL PCB
        cube([WIDTH,LENGTH,DEPTH]);
    
        for(pt = hole_pts){
            translate([pt[0],pt[1],0]){
                cylinder(r=PCB_MNT_HOLE_RAD,h=5,center=true);
            }
        }
    }
    
    
    translate([5.6,1.5,-1.5]){
        multi_male_connector(6);
    }
    
    // translate([0.5,LENGTH-4.2,1.5]){
    //     dual_screw_connector();
    // }
    // translate([WIDTH-10,LENGTH-4.2,1.5]){
    //     dual_screw_connector();
    // }
}