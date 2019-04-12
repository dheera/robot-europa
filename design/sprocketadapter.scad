scale([1,1,-1]) {
difference() {
    union() {
    cylinder(d1=66.5,d2=67,h=8,$fn=256);
        
    
translate([0,0,8])
cylinder(d1=66.5,d2=18.5,h=1.5, $fn=256);
    }
    
    for(i=[0:2]) {
    rotate([0,0,i*120])
    translate([51.5/sqrt(3),0,0]) {
        
    cylinder(d=3.3,h=15,$fn=32);
        
    translate([0,0,6.5])
    cylinder(d1=3.3,d2=6.6,h=1.5,$fn=32);
        
    translate([0,0,8])
    cylinder(d1=6.6,d2=6.6,h=3,$fn=32);
        
    }    
    
    
    rotate([0,0,i*120+60])
    translate([51.5/sqrt(3),0,0])
    cylinder(d=3.3,h=15,$fn=32);
    }
    
    
    cylinder(d=50,h=3,$fn=256);

cylinder(d=.55*25.4,h=6,$fn=64);


    
}
difference() {
union() {
translate([0,0,8])
translate([-3/16/2*25.4+.05/2,-3/16/2*25.4+5/8/2*25.4+.05/2,0])
cube([3/16*25.4-.05,3/16*25.4-.05,24+3]);

translate([0,0,8])
cylinder(d1=29,d2=21,h=5, $fn=256);

difference() {
translate([0,0,8])
cylinder(d=5/8*25.4-.05,h=24+3, $fn=256);

translate([0,0,8+24+3-7.5])
rotate([0,90,0]) {
translate([0,0,4.5])
cylinder(d1=3,d2=6,h=1,$fn=32);
translate([0,0,5.5])
cylinder(d1=6,d2=6,h=5,$fn=32);
}

scale([-1,1,1])
translate([0,0,8+24+3-7.5])
rotate([0,90,0]) {
translate([0,0,4.5])
cylinder(d1=3,d2=6,h=1,$fn=32);
translate([0,0,5.5])
cylinder(d1=6,d2=6,h=5,$fn=32);
}
}

}


cylinder(d=1/4*25.4,h=50,$fn=32);

}

}