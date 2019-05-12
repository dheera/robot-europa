difference() {
  tilt_block();
  translate([0,0,13])
  cube_center([100,100,100]);
}

module triangle() {
scale([1,1,1])
rotate([0,-90,90])
linear_extrude(height = 1, center = true, convexity = 10, twist = 0)
polygon(points=[[0,0],[1,0],[0,1]]);
}

module tilt_block() {
rotate([0,0,0]) {
difference() {
    cube_center([40,22,14]);
    translate([0,0,14])
    rotate([90,0,0])
    cylinder(d=0.76*25.4,h=100,center=true,$fn=128);
    
    translate([-15,11.5/2,0]) {
    cylinder(d=3.3,h=50,$fn=32);
    cylinder(d1=6.3,d2=3.3,h=2.5,$fn=32);
    }
    translate([15,11.5/2,0]) {
    cylinder(d=3.3,h=50,$fn=32);
    cylinder(d1=6.3,d2=3.3,h=2.5,$fn=32);
    }
    translate([-15,-11.5/2,0]) {
    cylinder(d=3.3,h=50,$fn=32);
    cylinder(d1=6.3,d2=3.3,h=2.5,$fn=32);
    }
    translate([15,-11.5/2,0]) {
    cylinder(d=3.3,h=50,$fn=32);
    cylinder(d1=6.3,d2=3.3,h=2.5,$fn=32);
    }
}

}
}


module cube_center(dims) {
    translate([-dims[0]/2, -dims[1]/2, 0])
    cube(dims);
}
