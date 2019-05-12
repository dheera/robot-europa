difference() {
    union() {
        translate([0,-2.5,0])
    cube_center([40,45,3]);

difference() {
    translate([0,-3.8,-29])
    tilt_block();
    
    scale([1,1,-1])
    cube_center([100,100,100]);
    
    translate([0,50+25,0])
    cube_center([100,100,100]);
    
    
    translate([0,-50-2,0])
    cube_center([100,100,100]);
}


}

    translate([0,-6,0])
    cylinder(d=3.3,h=50,$fn=32);

    translate([0,-6,1])
    cylinder(d=3.3,d2=6.3,h=2,$fn=32);


    minkowski() {
    translate([0,-6+13,0])
    cylinder(d=4.85,h=5,$fn=32);
        
    cube([0.001,17-5.5,0.001], center=true);
    }
}

difference() {
    union() {
translate([20-2,5.5,0])
scale([4,35.6,22.3])
rotate([0,0,90])
triangle();
        
translate([-20+2,5.5,0])
scale([4,35.6,22.3])
rotate([0,0,90])
triangle();
    }
    
    
    translate([0,-50-25,0])
    cube_center([100,100,100]);
}

module triangle() {
scale([1,1,1])
rotate([0,-90,90])
linear_extrude(height = 1, center = true, convexity = 10, twist = 0)
polygon(points=[[0,0],[1,0],[0,1]]);
}

module tilt_block() {
rotate([-27,0,0]) {
difference() {
    cube_center([40,30,50]);
    translate([0,0,50])
    rotate([90,0,0])
    cylinder(d=0.76*25.4,h=100,center=true,$fn=128);
    
    translate([-15,1.5,50-5])
    cylinder(d=4.7,h=50,$fn=32);
    translate([15,1.5,50-5])
    cylinder(d=4.7,h=50,$fn=32);
    translate([-15,-10,50-5])
    cylinder(d=4.7,h=50,$fn=32);
    translate([15,-10,50-5])
    cylinder(d=4.7,h=50,$fn=32);
}

}
}


module cube_center(dims) {
    translate([-dims[0]/2, -dims[1]/2, 0])
    cube(dims);
}
