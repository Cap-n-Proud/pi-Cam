//$fn = 100;


//Need to fix servo tilt suport issue. The spheric part does not move with the arm when you change xPos parameter
include <rpi.scad>;
PIcameraDiam = 8;
PIcameraX = 25;
PIcameraY = 25;

mik = 2;
shellThickness = 3;
supportBaseHeight = 5;
//5.4 is the height of the 
baseHeight = 31 + shellThickness - 5.4;
tolerance = 1.5;
gimballWidth = 45; //for 50 gives R = 86

R = sqrt(3 * gimballWidth * gimballWidth) / 2;
panSupport = sqrt(R * R - (gimballWidth * gimballWidth / 4));
gimballPivotR = R / 2;
supportY = 2 * sqrt(R * R - (gimballWidth / 2) * (gimballWidth / 2));
supportX = R - gimballWidth / 2;
supportZ = 1.1 * R;

servoHornThickness = 5.5;
servoHornWidth = 8;
servoHornLenght = 32;

screwDiam	= 3;
screwLenght = 10;
screwTolerance = 0.2;

Piwidth = 56;
Pilength = 85;
Piheight = 1.5;

boxLenght = Pilength + mik + 3;
boxDepth = 2 * R + 10;
boxHeight = 48;





function RatX(x) = sqrt(R * R - (x * x));


module box(Xdim, Ydim, Zdim, thickness, application)
//Creates a box, dimensions are internal
{
	difference() {
		//translate([10,0,-thickness])
		cube([Xdim + thickness, Ydim + thickness, Zdim], center = true);
		translate([0, 0, thickness / 2]) cube([Xdim, Ydim, Zdim], center = true);
		if (application == "servo") {
			translate([-Xdim / 2, 0, -0.5 * Zdim]) cube([5, Ydim + 2 * thickness, Zdim / 2 + thickness], center = true);
			translate([+Xdim / 2, 0, -0.5 * Zdim]) cube([5, Ydim + 2 * thickness, Zdim / 2 + thickness], center = true);
			translate([+Xdim / 2, 0, 0]) cube([thickness / 2, 0.3 * Ydim, Zdim], center = true);
			translate([-Xdim / 2, 0, 0]) cube([thickness / 2, 0.3 * Ydim, Zdim], center = true);
		}
	}
}

//Baseplate for pan mechanism
module base(servo) {
	difference(){
		
	 {
		minkowski() {
			cylinder(r = R + mik, h = supportBaseHeight);
			rotate([90, 0, 0]) cylinder(r = mik, h = 1);
		}

		//This to create a anchorign mechanism with the pan base
		//translate([0, 0,-mik])cylinder(r = R + mik+3, h = 2);
	}
		if(servo == true) translate([0, 0, -supportZ - servoHornThickness]) rotate([0, 90, 0]) servoHorn("cross");
	}
}
//-------------------------


module supportSection() {
	intersection() {
		difference() {
			sphere(R);
			cube([gimballWidth, 2 * gimballWidth, 2 * gimballWidth], center = true);

		}
		translate([R - supportX / 2, 0, 0]) cube([supportX, supportY, 10], center = true);
	}
}
//-------------------------

module tiltSupport()
//This creates the supporting pillar for the camera shell
 {
	union(){
difference() {
		sphere(R);
		cube([gimballWidth, 2 * gimballWidth, 2 * gimballWidth], center = true);
		translate([-gimballWidth,0,0])cube([2 * gimballWidth,2 * gimballWidth,2 * gimballWidth], center=true);

	}

	hull() {
		translate([0, 0, -5]) supportSection();
		translate([0, 0, -supportZ]) supportSection();
	}}

}


module servoTiltSupport(xPos) {
	//Need to center the servo shaft, the seconf figure is the distance form border
	supportPosition = xPos;
	eccentricity = 22.2 / 2 - 5;
	servoBodySupport = 20;
	//Need to adjust the clearance to account for the Xpos
	servoClerance = 31 - 16 - servoHornThickness;
	supportCurvature = 30;

	rotate([-0, 0, 0]) difference() {

		union() {

			difference() {
				translate([-shellThickness / 2 + supportPosition, 0, 15]) {
					cube([shellThickness, 20, 2 * RatX(gimballWidth / 2)], center = true);
				}
				difference() {
					translate([-shellThickness / 2 + supportPosition, 0, 15]) cube([shellThickness, 20, 2 * RatX(gimballWidth / 2)], center = true);


					//The size of the sphere governs where the servo support will be cut. Need to add tolerance if you wnat to print as one piece with the shell.
					sphere(RatX(gimballWidth / 2) + shellThickness + tolerance);

				}

			}

			translate([-servoBodySupport / 2 + supportPosition, 0, eccentricity]) {
				//This is the servo box
				difference() {
					cube([servoBodySupport, 12 + 1 + shellThickness, 22.2 + 1 + shellThickness], center = true);
					cube([servoBodySupport, 12 + 1, 22.2 + 1], center = true);

					//Servo cable slot
					translate([0, 0, -2 * eccentricity]) cube([100, 3, 3], center = true);

				}

			}
		}

	//This is the slot in the servo arm
		translate([servoClerance + 10, 0, eccentricity]) {

			cube([20+1, 12, 32.2+1], center = true);
			translate([-31 / 2, 0, 0]) cube([31+1, 12, 22.2+1], center = true);

		}
	}


translate([0, 0, 0])
			difference() {
		translate([3, 0,+ RatX(xPos)-10])
		difference() {
			cube([20, 20, 20], center = true);
			translate([-supportCurvature, 0, -supportCurvature]) sphere(r = supportCurvature + 20);
		}

		difference() {
			sphere(RatX(gimballWidth / 2) + 10 * shellThickness + tolerance);

			sphere(RatX(gimballWidth / 2) + shellThickness + tolerance);
		}
	}

}
//-------------------------
module cameraSupport() {
	difference() {
		difference() {
			sphere(R);
			sphere(R - shellThickness);
		}

		translate([R + gimballWidth / 2, 0, 0]) cube([2 * R, 2 * R, 2 * R], center = true);
		translate([-R - gimballWidth / 2, 0, 0]) cube([2 * R, 2 * R, 2 * R], center = true);
		//Creates camera support
		translate([0, R - 7, 0]) cube([PIcameraX + tolerance, 3, PIcameraY + tolerance], center = true);
		translate([0, R - 7, 0]) cube([2, 3, PIcameraY], center = true);
		//Slot for camera wires
		translate([0, R - 8, -PIcameraY / 2 - 2]) cube([PIcameraX - 5, 3, 3], center = true);


		//Hole for the camera
		translate([0, R, 0]) rotate([90, 0, 0]) cube([PIcameraDiam + tolerance, 10, PIcameraDiam + tolerance], center = true);
	}

	//Need to hardwire the servo dimensions

	{
		servoTiltSupport(gimballWidth / 2);


	}
	//pivot mechanism
	translate([-gimballWidth / 2, 0, 0]) {
		difference() {
			rotate([0, 90, 0]) cylinder(r = panSupport, h = shellThickness);
			gimballPivot(1);
			rotate([0, 90, 0]) cylinder(r = gimballPivotR - shellThickness, h = shellThickness);

		}
		gimballPivot(1);
	}
}
//-------------------------

module servoHorn(type) {
	cube([servoHornThickness, servoHornWidth, servoHornLenght], center = true);
	if (type == "cross") rotate([90, 0, 0]) cube([servoHornThickness, servoHornWidth, servoHornLenght], center = true);
}
//-------------------------

module gimballPivot(tolerance) {
	rotate([0, 90, 0])
	difference() {
		cylinder(r = gimballPivotR - tolerance / 2, h = gimballPivotR / 2, center = true);
		cylinder(r = gimballPivotR - 3 + tolerance / 2, h = gimballPivotR / 2, center = true);
	}
}
//-------------------------

module support() {
  scaleFactor = (R + tolerance)/R;
			
    difference() {
        tiltSupport();

        translate([gimballWidth / 2 + servoHornThickness / 2, 0, 0]) rotate([45, 0, 0]) servoHorn("line");
        SUB_servocableDuct();
    }

	//Need to cut holes in the base for servo and camera cables and the screws
	translate([0,0,-supportBaseHeight/2])
	difference(){
		
		{
			color("blue",0.5)translate([0, 0, -supportZ - supportBaseHeight])base(true);
			SUB_cameracableDuct();
			SUB_servocableDuct();
			translate([0,0,+supportBaseHeight/2])mirror([1, 0, 0])tiltSupport();
			SUB_mountedPillarScrewHoles();
		}

	}
}

module mountedPillar(){
    //Pillar for camera. This one needs to be mounted separately
	difference() {
        mirror([1, 0, 0]) tiltSupport();
        translate([-gimballWidth / 2, 0, 0]) gimballPivot(0);
        translate([-gimballWidth / 2, 0, 0]) gimballPivot(3); {
        SUB_cameracableDuct();
		SUB_mountedPillarScrewHoles();
        }

    }
}

module SUB_screw(tolerance)
{
	cylinder(r= screwDiam/2+tolerance, h = screwLenght);
	translate([0,0,-3])cylinder(r= 2*screwDiam/2+screwTolerance, h = 3);
}

module SUB_mountedPillarScrewHoles()
{
	color("blue",0.5)translate([-R+supportX/2+2,0,-supportZ-screwLenght/2])
	{
	translate([0, 0.5 * panSupport,0])SUB_screw(-screwTolerance);
	mirror([0,1,0])translate([0, 0.5 * panSupport,0])SUB_screw(-screwTolerance);
	}	
}

module SUB_servocableDuct() {
    //Duct for servo cable
    translate([+gimballWidth / 2 + supportX / 4 + 2, -supportX/3, -3]) {
        translate([0, 0, -supportZ + supportX]) cylinder(r = supportX / 4, h = supportZ + supportX / 2, center = true);
        translate([-supportX, 0, 0]) rotate([0, 120, 0]) cylinder(r = supportX / 4, h = supportX, center = false);
        translate([0, 0, -supportZ - supportX / 3]) rotate([0, 90, 170]) cylinder(r = supportX / 4, h = 0.8 * R, center = false);
    }

}

module SUB_cameracableDuct()
 {
    //Duct for camera connetion
    translate([-gimballWidth / 2 - 0.5 * supportX, 0, 0]) rotate([0, 0, 90]) {
        translate([0, 0, 0]) rotate([90, 0, 0]) cylinder(r = 26 / 2, h = 0.6 * supportX);
        translate([0, 0, -supportZ / 2]) cube([20, 3, supportZ + 1.1 * supportBaseHeight], center = true);
        translate([0, -R * 0.5 + 13, -supportZ - supportBaseHeight]) rotate([90, 0, 0]) cube([20, 5, R * 0.5], center = true);

    }
}
//---------------------------





module connectionSocket ()
{

cylinder(r=3, h=5);
translate([-9,-3/2,0])cube([10,3,5]);

}

module mhole ()
	{
	cylinder (r=3/2-0.2, h=2*Piheight+8, $fs=0.1);
	}



module case(){
translate([0, 0, -boxHeight  / 2 - supportZ - 2 * supportBaseHeight]) {
	difference(){
	minkowski()
	{
		box(boxLength, boxDepth, boxHeight, shellThickness - mik, "PI");
		//sphere(r = mik);
		cylinder(r=mik, h=2);
	}
translate([R-10 , -Piwidth / 2,-boxHeight  / 2 - 5/2 ])connectionSocket ();
translate([-R+10 , -Piwidth / 2,-boxHeight  / 2 - 5/2 ])connectionSocket ();
translate([R-10 , Piwidth / 2,-boxHeight  / 2 - 5/2 ])connectionSocket ();
translate([-R+10 , Piwidth / 2,-boxHeight  / 2 - 5/2 ])connectionSocket ();
translate([0, 0,-boxHeight  / 2 - 5/2 ])cylinder(r=3,h=5);


	translate([-Pilength / 2, -Piwidth / 2, -boxHeight  / 2 + 5 + shellThickness]) {
		rpi();		
	}
}
translate([-Pilength / 2, -Piwidth / 2, -boxHeight  / 2 + 5 + shellThickness])
{
 translate([25.5, 18, -(+5 + shellThickness)]) mhole();
 translate([length - 5, width - 12.5, -(+5 + shellThickness)]) mhole();

 }
}
}
 

//mountedPillar();
//mirror([1, 0, 0])tiltSupport();
//SUB_mountedPillarScrewHoles();
//servoTiltSupport(15);
//cameraSupport();

//translate([-10, 0, 0])
//support();


topCoverHeight = 15;
difference()
{
{
translate([0, 0, -supportZ-supportBaseHeight-topCoverHeight/2])	cube([boxLenght+mik,boxDepth,topCoverHeight], center=true);
translate([0, 0, -supportZ - supportBaseHeight]){
base("false");
scale([0.8,0.8,30])base("false");
}
}
}

