

// We want a whole bunch of LEDs, represented by cylinders to point at a point in space above a plane
// COVERGENCE_HT is the height above the center of the plane 
COVERGENCE_HT = 100;
CYLINDER_HT = 20;
CYLINDER_RD = 3;


translate([0, 0, COVERGENCE_HT]){
    color("yellow",1.0){
        sphere(radius=3);
    }
}





// for(xposi=[-100:20:100]){
//     y_angle = atan2(xposi,COVERGENCE_HT);
    
//     translate([xposi, 0, 0]){
//         rotate([0, -y_angle, 0]){
//             translate([0, 0, -CYLINDER_HT/2]){
//                 cylinder(r=3,h=CYLINDER_HT,center=true);
//             }
//         }
//     }
// }


// for(yposi=[-100:20:100]){
//     x_angle = atan2(yposi,COVERGENCE_HT);
    
//     translate([0, yposi, 0]){
//         rotate([x_angle, 0]){
//             translate([0, 0, -CYLINDER_HT/2]){
//                 cylinder(r=3,h=CYLINDER_HT,center=true);
//             }
//         }
//     }
// }



module make_and_aim_cylinder(x_posi, y_posi, convergence_height){
    y_angle = atan2(x_posi,convergence_height);
    x_angle = atan2(y_posi,convergence_height); 

    translate([x_posi, y_posi, 0]){
        rotate([x_angle, 0, 0]){
            rotate([0, -y_angle, 0]){
                translate([0, 0, -CYLINDER_HT/2]){
                    cylinder(r=CYLINDER_RD,h=CYLINDER_HT,center=true);
                }
            }
        }
    }
}


for(yposi=[-100:20:100]){
    for(xposi=[-100:20:100]){
        make_and_aim_cylinder(xposi,yposi,COVERGENCE_HT);
    }
}


