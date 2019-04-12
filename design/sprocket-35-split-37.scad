use <sprockets.scad>

scale([1,1,.95])
translate([-5,0,0])
difference() {
  translate([9.525/4,0,0]) // to slice at bottom of bore
  rotate([0,0,360/37/4]) {
      difference() {
            sprocket(35, 37, 2.25, 0, 0);
          
            // hole pattern
            rotate([0,0,180+30])
            translate([3.228*25.4/2,0,0])
            cylinder(d=1/4*25.4,h=10,$fn=32);
            rotate([0,0,180-30])
            translate([3.228*25.4/2,0,0])
            cylinder(d=1/4*25.4,h=10,$fn=32);
      }
  }

  // slice
  scale([1,1,1])
  translate([0,-150/2,0])
  cube([150,150,10]);
  
}

scale([1,1,.95])
translate([5,0,0])
difference() {
  translate([9.525/4,0,0]) // to slice at bottom of bore
  rotate([0,0,360/37/4]) {
      difference() {
            sprocket(35, 37, 2.25, 0, 0);
          
            // hole pattern
            rotate([0,0,30])
            translate([3.228*25.4/2,0,0])
            cylinder(d=1/4*25.4,h=10,$fn=32);
            rotate([0,0,-30])
            translate([3.228*25.4/2,0,0])
            cylinder(d=1/4*25.4,h=10,$fn=32);
      }
  }

  // slice
  scale([-1,1,1])
  translate([0,-150/2,0])
  cube([150,150,10]);
  
}