$fn = 250;

R = 50;
ballShell = 3;
supportX = 35;
supportY = 8;
supportZ = 60;
mik = 2;
sThickness = 5;
supportBaseHeight = 5;
baseHeight = 31;

module box(Xdim, Ydim, Zdim, thickness, application)
//Creates a box, dimensions are internal
{
	difference() {
		//translate([10,0,-thickness])
		cube([Xdim + thickness, Ydim + thickness, Zdim], center = true);
		translate([0, 0, thickness / 2]) cube([Xdim, Ydim, Zdim], center = true);
		if(application == "servo")
	{
		translate([-Xdim/2,0,-0.5*Zdim])cube([5,Ydim+2*thickness,Zdim/2+thickness], center=true);	
		translate([+Xdim/2,0,-0.5*Zdim])cube([5,Ydim+2*thickness,Zdim/2+thickness], center=true);
		translate([+Xdim/2,0,0])cube([thickness/2,0.3*Ydim,Zdim], center=true);
		translate([-Xdim/2,0,0])cube([thickness/2,0.3*Ydim,Zdim], center=true);		
	}
	}
}

module support() {
	difference() {
		union() {
			intersection() {
				sphere(R);
				translate([-R, -R+(supportY+sThickness)/2, 0])  cube([500, 25, 200], center = true);
			}

		}
	}

	translate([0, -R+(supportY+sThickness/2), -supportZ/2]) {
		minkowski() {
			box(supportX, supportY, supportZ, sThickness , "none");
			cylinder(r = mik, h = 1);
			//rotate([90,0,0])cylinder(r = mik, h = 1);
		}
	}
}

module base() {
translate([0, 0, -supportZ])
		minkowski() {
			cylinder(r= R+mik, h= supportBaseHeight);
		rotate([90,0,0])cylinder(r = mik, h = 1);
}
}



sphere(R);
support();
mirror([0, 10, 0]) support();
//need to understnad -2 in  2*R-5-mik-2
base();

translate([0, 0, -supportZ-supportBaseHeight-baseHeight])
{difference(){
	minkowski() {
cylinder(r= R+mik, h = baseHeight);		
rotate([90,0,0])cylinder(r = mik, h = 1);
}

translate([0, 0, 5])cylinder(r= (R+mik)/2, h = 10*baseHeight);		
}
translate([0, 0, 17-3])	box(24.5, 13, 17, 3,"servo");}