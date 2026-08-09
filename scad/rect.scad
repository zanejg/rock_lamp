
RECT_MATRIX = [ 
    [ 1, 1], 
    [ 1,-1], 
    [-1,-1], 
    [-1, 1] 
];

// returns an array of points that define a rectangle
function rect(wd,ln) = [
        for (rm = RECT_MATRIX) 
            [rm[0]*wd/2, rm[1]*ln/2]
    ];
