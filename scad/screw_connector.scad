
BOX_WD = 7.7;
BOX_HT =10;
THICKNESS = 4.7;
size_mod = 0.05; // ensure overlap
SHD_HT = 4;
SCREWHOLE_RAD = 3.6/2;

module single(){
    box_points=[
        [-(BOX_WD/2),0],
        [-(BOX_WD/2),BOX_HT-SHD_HT],
        [-(BOX_WD/2)+2.0,BOX_HT],
        [(BOX_WD/2)-1.5,BOX_HT],
        [(BOX_WD/2),BOX_HT-SHD_HT],
        [(BOX_WD/2),0],
    ];
    difference(){
        rotate(90,[0,0,1]){
            rotate(90,[1,0,0]){
                linear_extrude(height=THICKNESS + size_mod){
                    polygon(box_points);
                }
            }
        }
        // screw hole
        translate([THICKNESS/2,0.3,BOX_HT/2]){
            cylinder(r=SCREWHOLE_RAD,h=6,$fn=20);
        }

        // WIRE_ HOLES
        translate([0.25,0,0.3]){
            cube([4.2,4,5.2]);
        }
    }

    // wires
    translate([(THICKNESS/2)-.4,-0.4,-3.5]){
        cube([0.8,0.8,4]);
    }

    //contact stuff in holes... where the wires go
    translate([0.35,0,0.5]){
        difference(){
            cube([4.0,3.8,5.0]);
            translate([0.2,0.1,0.2]){
                cube([3.6,4.0,4.6]);
            }

        }
    }
    translate([0.7, 1.6, 3.2]){
        cube([3.2,2,3.2]);
    }

}

module dual_screw_connector(){
    single();
    translate([THICKNESS,0,0]){
        single();
    }
}


//dual_screw_connector();
