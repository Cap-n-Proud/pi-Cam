//everything in mm


width = 56;
length = 85;
height = 1.5;

T = 2;
HDMI_plug = 0;
Power_plug = 0;
4poles_plug= 0;
extrude = 10;

module ethernet ()
	{
	//ethernet port 
	color("silver")
	translate([0,width-10.5,height+13.3/2]) cube([21.2,16+T,13.3+T], center=true); 
	}


module usb ()
	{
	//usb port
	color("silver")
	translate([17.3/2+1-extrude,width-29,16/2+height+1]) cube([17.3+extrude,13.3+T,16+T], center=true);
	translate([17.3/2+1-extrude,width-47,16/2+height+1]) cube([17.3 + extrude,13.3+T,16+T],center=true);
	}

module 4polesJack ()
	{
	//composite port
	translate([length-53.5, width-5+2+extrude/2, height+2.5+(5/2+T+4poles_plug)/2])
		{
		color("yellow")
		rotate([90,0,0])cylinder(r=5/2+T+4poles_plug,h=10+2*extrude, center=true);
		}
	}

module audio ()
	{
	//audio jack
	translate([length-26,width-11.5,height])
		{
		color([.4,.4,.95])
		cube([12.1,11.5,10.1]);
		translate([6,11.5,10.1-(6.7/2)])
		rotate([-90,0,0])
		color([.4,.4,.95])
		cylinder(h = 3.5, r = 6.7/2, $fs=.5);
		}
	}


module gpio ()
	{
	//headers
	rotate([0,0,180])
	translate([-1,-width+6,height])
	off_pin_header(rows = 13, cols = 2);
	}

module hdmi ()
	{
	color ("silver")
	translate ([length-32,width+2+extrude/2,height+4])
	cube([15.1+T+HDMI_plug,11.7+extrude,8+T+HDMI_plug],center=true);
	}

module power ()
	{
	color("silver")
	translate ([length-10.6,width+0+extrude/2,height+2.2])
	cube ([8+T+Power_plug,5.6+2*extrude,4.4+T+Power_plug], center=true);
	}

module sd ()
	{

	color ([.2,.2,.7])
	translate ([length+extrude/2,width-28,0])
	cube ([10+T+extrude, 10+T, 4+T], center=true);
	}

module mhole ()
	{
	cylinder (r=3/2, h=height+5, $fs=0.1, center = true);
	}

module pcb ()
	{
		difference ()
		{
		color([0.2,0.5,0])
		linear_extrude(height = height)
		square([length,width]); //pcb
translate ([length-3.5, width-3.5,0]) mhole (); 
translate ([length-3.5, -0+3.5,0]) mhole (); 
translate ([length-58-3.5, width-3.5,0]) mhole (); 
translate ([length-58-3.5, 0+3.5,0]) mhole (); 
		}
	}


module leds()
	{
		// act
		color([0.9,0.1,0,0.6])
		translate([length-11.5,width-7.55,height]) led();
		// pwr
		color([0.9,0.1,0,0.6])
		translate([length-9.45,width-7.55,height]) led();

		// fdx
		color([0.9,0.1,0,0.6])
		translate([length-6.55,width-7.55,height]) led();
		// lnk
		color([0.9,0.1,0,0.6])
		translate([length-4.5,width-7.55,height]) led();
		// 100
		color([0.9,0.1,0,0.6])
		translate([length-2.45,width-7.55,height]) led();
	}
module led()
	{
		cube([1.0,1.6,0.7]);
	}

module rpi ()
	{
		pcb ();
		ethernet ();
		usb (); 
		4polesJack (); 
		//audio (); 
		//gpio (); 
		hdmi ();
		power ();
		sd ();
		//leds ();
	}

//rpi(); 
