
include <Round-Anything/polyround.scad>

$fn=20;




shldr_cube = 2.5;
spike_ht = 11.2;
bot_2_cube_top = 5.6;

size_mod = 0.05; // to ensure the shapes actually overlap not 
                // exactly touch
// create one spike of the connector
module conn_spike(){
    
    linear_extrude(height=spike_ht){
        square([0.64,0.64],center=true);
    }

    
    cbhf = (shldr_cube + size_mod)/2;
    cb_rad = 0.35;
    cbxy = [
        [cbhf,cbhf,cb_rad],
        [cbhf,-cbhf,cb_rad],
        [-cbhf,-cbhf,cb_rad],
        [-cbhf,cbhf,cb_rad],
    ];
    
    translate([0,0,bot_2_cube_top-(shldr_cube)]){
        linear_extrude(height=shldr_cube){
            polygon(polyRound(cbxy,$fn=20));
        }
    }

    // cube(shldr_cube,center=true);
}

arm_ht = 7.5;
spike_wd = 0.64;
bend_rad = 1.2;

spike_points = [
    [-(spike_wd/2),0,0],
    [-(spike_wd/2),arm_ht,bend_rad],
    [arm_ht-(spike_wd/2),arm_ht+(spike_wd/2),0],
    [arm_ht-(spike_wd/2),arm_ht-(spike_wd/2),0],
    [(spike_wd/2),arm_ht-spike_wd,bend_rad-spike_wd],
    [(spike_wd/2),0,0],
];



// create one spike of the connector
module bent_conn_spike(){
    
    translate([-spike_wd/2,0,0]){
        rotate(90,[0,0,1]){
            rotate(90,[1,0,0]){
                linear_extrude(height=spike_wd){
                    polygon(polyRound(spike_points));
                }
            }
        }
    }
    
    cbhf = (shldr_cube + size_mod)/2;
    cb_rad = 0.35;
    cbxy = [
        [cbhf,cbhf,cb_rad],
        [cbhf,-cbhf,cb_rad],
        [-cbhf,-cbhf,cb_rad],
        [-cbhf,cbhf,cb_rad],
    ];
    
    translate([0,0,bot_2_cube_top-(shldr_cube)]){
        linear_extrude(height=shldr_cube){
            polygon(polyRound(cbxy,$fn=20));
        }
    }

    // cube(shldr_cube,center=true);
}



// create an arbitrarily long line of them
// along the x-axis
module bent_multi_male_connector(conn_count){
    for (cc=[0 : conn_count-1] ){
        //translate([((cc*shldr_cube))-(shldr_cube/2),0,0]){
        translate([((cc*shldr_cube)),0,0]){
            bent_conn_spike();
        }
    }

}

//bent_multi_male_connector(14);

// create an arbitrarily long line of them
// along the x-axis
module multi_male_connector(conn_count){
    for (cc=[0 : conn_count-1] ){
        //translate([((cc*shldr_cube))-(shldr_cube/2),0,0]){
        translate([((cc*shldr_cube)),0,0]){
            conn_spike();
        }
    }

}

module matrix_male_connector(xlen,ylen){
    translate([0,0,-(bot_2_cube_top-shldr_cube)]){
        for(cc=[0 : ylen-1] ){
            translate([0,cc*shldr_cube,0]){
                multi_male_connector(xlen);
            }
        }
    }

}

//multi_male_connector(20);
//matrix_male_connector(6,5);

