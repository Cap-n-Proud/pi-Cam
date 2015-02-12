//$fn = 300;

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

module supportRound() {
	hull() {
		translate([0, 0, -5]) supportSection();
		translate([0, 0, -supportZ]) supportSection();
	}
}



module base() {
	translate([0, 0, -supportZ - supportBaseHeight]) {
		minkowski() {
			cylinder(r = R + mik, h = supportBaseHeight);
			rotate([90, 0, 0]) cylinder(r = mik, h = 1);
		}
		//This to create a anchorign mechanism with the pan base
		//translate([0, 0,-mik])cylinder(r = R + mik+3, h = 2);
	}
}

module bottom() {
	translate([0, 0, -supportZ - supportBaseHeight - baseHeight]) {
		difference() {

			difference() {
				minkowski() {
					cylinder(r = R + 6, h = baseHeight);
					rotate([90, 0, 0]) cylinder(r = mik, h = 1);
				}

				translate([0, 0, 5]) cylinder(r = (R + mik) - 2 * shellThickness, h = 10 * baseHeight);
			}
			translate([0, 0, baseHeight - supportBaseHeight]) cylinder(r = R + mik + tolerance, h = 10 * supportBaseHeight);
			translate([0, 0, 0]) cylinder(r = 0.7 * R + mik + 2, h = 10 * supportBaseHeight);

		}

		translate([0, 0, 17 - 3]) box(24.5, 13, 17, 3, "servo");
	}
}

module supportSection() {
	intersection() {
		difference() {
			sphere(R);
			cube([gimballWidth, 2 * gimballWidth, 2 * gimballWidth], center = true);

		}
		translate([R - supportX / 2, 0, 0]) cube([supportX, supportY, 10], center = true);
	}
}

module tiltSupport() {
	difference() {
		sphere(R);
		cube([gimballWidth, 2 * gimballWidth, 2 * gimballWidth], center = true);

	}
	supportRound();
	mirror([1, 0, 0]) supportRound();
	base();
}

module servoTiltSupport(xPos) {
	//Need to center the servo shaft, the seconf figure is the distance form hthe border
supportPosition = xPos;
	eccentricity = 22.2 / 2 - 5;
	servoBodySupport = 20;
	//Need to adjust the clearance to account fo rthe Xpos
	servoClerance = 27 - 15.5;
	rotate([-0, 0, 0]) difference() {

		union() {

			difference() {
				translate([-shellThickness / 2 + supportPosition, 0, 15]) cube([shellThickness, 20, 2 * panSupport], center = true);

				difference() {
					translate([-shellThickness / 2 + supportPosition, 0, 15]) cube([shellThickness, 20, 2 * panSupport], center = true);
				//The size of the sphere governs where the servo support will be cut. Need to add tolerance if you wnat to print as one piece with the shell.
					sphere(panSupport + shellThickness + tolerance);
				}
			}
			translate([-servoBodySupport / 2 + supportPosition, 0, eccentricity])
 {

				difference() {
					cube([servoBodySupport, 12 + shellThickness, 22.2 + shellThickness], center = true);
					cube([servoBodySupport, 12, 22.2], center = true);
				}
			}
		}

		translate([servoClerance+10, 0, eccentricity]) {
		
			cube([20, 12, 32.2], center = true);
			translate([-31 / 2, 0, 0]) cube([31, 12, 22.2], center = true);

		}
	}
}

module cameraSupport() {
	difference() {
		difference() {
			sphere(R);
			sphere(R - shellThickness);
		}
		
		translate([R + gimballWidth / 2, 0, 0]) cube([2 * R, 2 * R, 2 * R], center = true);
		translate([-R - gimballWidth / 2, 0, 0]) cube([2 * R, 2 * R, 2 * R], center = true);
		//Creates camera support
		translate([0,R-7,0])cube([PIcameraX + tolerance, 3, PIcameraY + tolerance], center = true);
		translate([0,R-7,0])cube([2 , 3, PIcameraY], center = true);
		//Slot for camera wires
	translate([0,R-8,-PIcameraY/2-2])cube([PIcameraX -5, 3, 3], center = true);

	
		//Hole for the camera
		translate([0, R, 0]) rotate([90, 0, 0]) cube([PIcameraDiam + tolerance,10, PIcameraDiam + tolerance], center=true);
	}

	//Need to hardwire the servo dimensions
	
	 {
		servoTiltSupport(gimballWidth/2);


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

module servoHorn(type) {
	cube([servoHornThickness, servoHornWidth, servoHornLenght], center = true);
	if (type == "cross") rotate([90, 0, 0]) cube([servoHornThickness, servoHornWidth, servoHornLenght], center = true);
}

module gimballPivot(tolerance) {
	rotate([0, 90, 0])
	difference() {
		cylinder(r = gimballPivotR - tolerance / 2, h = gimballPivotR / 2, center = true);
		cylinder(r = gimballPivotR - 3 + tolerance / 2, h = gimballPivotR / 2, center = true);
	}
}

//Cut slots for servos and pivot for the gimball
module support() {
	difference() {
		tiltSupport();
		translate([gimballWidth / 2 + servoHornThickness / 2, 0, 0]) rotate([45, 0, 0]) servoHorn("line");
		translate([-gimballWidth / 2, 0, 0]) gimballPivot(3);
		translate([0, 0, -supportZ - servoHornThickness]) rotate([0, 90, 0]) servoHorn("cross");

		//Duct for servo cable
		translate([+gimballWidth / 2 + supportX / 4 + 2, -supportX, 0]) {
			translate([0, 0, -supportZ + supportX]) cylinder(r = supportX / 4, h = supportZ + supportX / 2, center = true);
			translate([-supportX, 0, 0]) rotate([0, 120, 0]) cylinder(r = supportX / 4, h = supportX, center = false);
			translate([0, 0, -supportZ - supportX / 3]) rotate([0, 90, 150]) cylinder(r = supportX / 4, h = 0.8 * R, center = false);
		}
		//Duct for camera connetion
		translate([-gimballWidth / 2 - 0.5 * supportX, 0, 0]) rotate([0, 0, 90]) {
			translate([0, 0, 0]) rotate([90, 0, 0]) cylinder(r = 26 / 2, h = 0.6 * supportX);
			translate([0, 0, -supportZ / 2]) cube([20, 3, supportZ + 1.1 * supportBaseHeight], center = true);
			translate([0, -R * 0.5 + 13, -supportZ - supportBaseHeight]) rotate([90, 0, 0]) cube([20, 5, R * 0.5], center = true);
		}


	}

}


	

//support();
//bottom();
cameraSupport();
//servoTiltSupport(20);
/*translate([servoClerance, 0, eccentricity]){
cube([20, 12, 32.2], center = true);
translate([-31 / 2, 0, 0]) cube([31, 12, 22.2], center = true);

}*/