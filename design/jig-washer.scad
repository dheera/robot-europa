difference() {
    union() {
        cylinder(d=3.5*25.4,h=2,$fn=128);
        translate([0,0,2])
        cylinder(d1=1.625*25.4-.1,d2=1.625*25.4-.5,h=2,$fn=128);
    }
    
  for(i=[0:24]) {
  rotate([0,0,i*15+15])
  translate([1.9375*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
  }

  rotate([0,0,30])
  translate([3.228*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
  rotate([0,0,-30])
  translate([3.228*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
  
  rotate([0,0,180-30])
  translate([3.228*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
  rotate([0,0,180+30])
  translate([3.228*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
  
  
  rotate([0,0,90])
  translate([3.228*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
  
  
  rotate([0,0,-90])
  translate([3.228*25.4/2,0,0])
  cylinder(d=1/8*25.4,h=10,$fn=32);
    
}