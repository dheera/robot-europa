    minkowski() {
    translate([0,-6+13,0])
        union() {
    cylinder(d1=4.85,d2=4.85,h=6,$fn=32);
    translate([0,0,6])
    cylinder(d1=4.85,d2=4.5,h=1,$fn=32);
        }
        
    cube([0.001,17-5.5,0.001], center=true);
    }