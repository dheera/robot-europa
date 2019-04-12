difference() {
    union() {
        cylinder(d=2.25*25.4,h=2,$fn=128);
        translate([-7/8/2*25.4+.1,-7/8/2*25.4+.1,2])
        cube([7/8*25.4-.2,7/8*25.4-.2,11]);
    }
    
    
  for(i=[0:24]) {
  rotate([0,0,i*15+15])
  translate([1.9375*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
  }
    
}