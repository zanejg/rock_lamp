

SHAPE_WD = 50;

INNER_RD = SHAPE_WD * (10/75);
STRAIGHT_LN = SHAPE_WD * (20/75);
SWIRL_ANG = 200;
straight_ang = (SWIRL_ANG - 180)/2;

// PEAK_DIST = 30;
// BASE_HT = 60;
// PEAK_HT = 30;
// outer_peak_wd = (SHAPE_WD - PEAK_DIST) /2;
// shape_pts = [
//     [0, 0],
//     [SHAPE_WD, 0],
//     [SHAPE_WD, BASE_HT],
//     [SHAPE_WD - outer_peak_wd, BASE_HT + PEAK_HT],
//     [SHAPE_WD/2, BASE_HT],
//     [outer_peak_wd, BASE_HT + PEAK_HT],
//     [0, BASE_HT]
// ];


BASE_HT = 60;
PEAK_HT = 60;
box_ht = BASE_HT * 5/6;


shape_pts = [
    [0, 0],
    [SHAPE_WD, 0],
    [SHAPE_WD, BASE_HT],
    [SHAPE_WD/2, BASE_HT + (PEAK_HT)],
    [0, BASE_HT]
];



SC_COEFF = 0.90;
xos = (SHAPE_WD - (SHAPE_WD *SC_COEFF))/2;
scaled_pts = [
    for (this_pt = shape_pts)
        [this_pt[0] * SC_COEFF + xos, this_pt[1] * SC_COEFF ]
    
];




inter_swirl_offset = (INNER_RD+SHAPE_WD)*2 + (sin(straight_ang) * STRAIGHT_LN );

inter_swirl_gap = (INNER_RD - (sin(straight_ang) * (2 * STRAIGHT_LN))) + // gap caused by extension of straight len at angle
                           ((1- cos(straight_ang)) * SHAPE_WD) // curl back of shape
                            -((1- cos(straight_ang)) * INNER_RD);
                        
section_wd = (SHAPE_WD*2) + (INNER_RD*2) + inter_swirl_gap;






BOX_TN = 2.5;
cavity_ht = box_ht ;//* 4/5;
MBOX_WD = 100;
TAB_LN = 30;
cavity_wd = MBOX_WD -(BOX_TN *4);
tab_ht = cavity_ht - BOX_TN;
str_ang_cos = cos(straight_ang);
str_ang_sin = sin(straight_ang);
swirl_center_y = (STRAIGHT_LN*2) * str_ang_cos + (str_ang_sin * (SHAPE_WD + 2*INNER_RD));
swirl_center_x = SHAPE_WD + INNER_RD + inter_swirl_gap/2 - (INNER_RD * (1-str_ang_cos));
SCREW_STANCHION_RD = 9/2;
SCREWHOLE_Y = 46;
SCREWHOLE_X_OS = 43;

SCREWHOLE_PAIR_XY=[
    [swirl_center_x + SCREWHOLE_X_OS,SCREWHOLE_Y],
    [swirl_center_x - SCREWHOLE_X_OS,SCREWHOLE_Y]
];


POWER_FLEX_POSI = [100, -37, 20];



