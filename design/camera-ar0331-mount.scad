board_d = 32;
hole_d = 28;
h = 28;

difference() {
    cube_center([board_d+4, board_d+4,h]);
    translate([0,0,1.5])
    cube_center([board_d+1, board_d+1,h]);
    
    translate([board_d/2 - 6/2,0,0])
    cube_center([6,20,15]);
    
    rotate([0,0,90])
    translate([board_d/2 - 5/2,0,1])
    cube_center([5,20,15]);
}

translate([-hole_d/2,-hole_d/2,0])
standoff();
translate([hole_d/2,-hole_d/2,0])
standoff();
translate([-hole_d/2,hole_d/2,0])
standoff();
translate([hole_d/2,hole_d/2,0])
standoff();

module cube_center(dims) {
    translate([-dims[0]/2, -dims[1]/2, 0])
    cube(dims);
}

translate([-board_d/2-2,0,0])
scale([h,board_d+4,h])
scale([1/sqrt(3),1,1])
triangle();

module triangle() {
scale([1,1,1])
rotate([0,-90,90])
linear_extrude(height = 1, center = true, convexity = 10, twist = 0)
polygon(points=[[0,0],[1,0],[0,1]]);
}

module standoff() {
    difference() {
    cylinder(d1=6,d2=4,h=6,$fn=32);
    cylinder(d=1.8,h=10,$fn=16);
    }
}