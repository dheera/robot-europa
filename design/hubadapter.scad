scale([1,1,-1])
difference() {
    cylinder(d1=66.5,d2=67,h=7,$fn=256);
    for(i=[0:2]) {
    rotate([0,0,i*120])
    translate([51.5/sqrt(3),0,0]) {
    cylinder(d=3.3,h=15,$fn=32);
    translate([0,0,4])
    cylinder(d1=3.3,d2=6,h=3,$fn=32);
    }    
    rotate([0,0,i*120+60])
    translate([51.5/sqrt(3),0,0])
    cylinder(d=3.3,h=15,$fn=32);
    }
    
    for(i=[0:5]) {
    rotate([0,0,i*60+30])
    translate([2.125/2*25.4,0,0]) {
    cylinder(d=3.3,h=15,$fn=32);
        rotate([0,0,30])
    cylinder(d=6.3,h=5,$fn=6);
    }
    }
    
    cylinder(d=50,h=3,$fn=256);
    
    cylinder(d=27,h=50,$fn=128);
    
}