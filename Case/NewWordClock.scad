
letters = [ 
	[ "F", "O", "U", "R", "N", "I", "N", "E" ],
	[ "T", "W", "E", "L", "E", "V", "E", "N" ],
	[ "S", "I", "X", "T", "H", "R", "E", "E" ],
	[ "F", "I", "V", "E", "I", "G", "H", "T" ],
	[ "D", "P", "A", "S", "T", "O", "R", "O" ],
	[ "F", "I", "V", "E", "H", "A", "L", "F" ],
	[ "Q", "U", "A", "R", "T", "E", "R", "Y" ],
	[ "A", "T", "W", "E", "N", "T", "Y", "D" ]
];

$fn = 32;
max = 65; 
s = 65/8;
d_h = 5+1;  // was 5
w_h = 10;
b_h = 5;
c_h = 23;
letter_depth = w_h+1;

f = "Stencil Gothic";

module face()
{
	for (r = [0:7])
	{
		for (c = [0:7])
		{
			#translate([r*s + s/2+.2, c*s+s/2+1-0.6, 0])
				linear_extrude(height = letter_depth+1)
					text(
						letters[c][r], 
						font = f,
						size=6, 
						$fn=20, 
						valign="center", 
						halign = "center"
					);
		}
	}
}

module case_front()
{
	difference()
	{
		union()
		{
			translate([-5,-5,0]) 	cube([5,max+6+5, w_h]);	// left side
			translate([max+1,-5,0])	cube([5,max+6+5, w_h]); // right side 
			translate([0,max+1,0]) 	cube([max+2, 5, w_h]);	// top
			translate([-1,-5,0])	cube([max+3, 5, w_h]); 	// bottom
		}
		
		// mounting holes
		
		translate([-1.5,-1.5,0]) 			cylinder(d=2.4,h=w_h-2);	// ll 
		translate([max+1+1.5,-5+3.5,0]) 	cylinder(d=2.4,h=w_h-2);	// lr
		translate([-1.5,max+1+1.5,0]) 		cylinder(d=2.4,h=w_h-2);	// ul
		translate([max+1+1.5,max+1+1.5,0])	cylinder(d=2.4,h=w_h-2);	// ur 
	}
}

module dividers(w=1,hh=d_h)
{
	for (x = [0:8])
	{
		translate([s*x, 1, 0]) cube([w,max,d_h]);
		translate([0, s*x,0]) cube([max+1, w, d_h]);
	}
}

module clock_face()
{
	difference()
	{
		union()
		{
			translate([0,0,w_h-1]) cube([max+1,max+1,1]);
			translate([0,0,b_h]) dividers();
		}
		
		face();
		
		// cutout for connector
		translate([1,56,0])
			#cube([7.125,3,7]);
	}
	case_front();
}

module diffusers()
{
	difference()
	{
		translate([1,1,0]) cube([max,max,4.5+1]);  // was 4.5
		translate([0,0,0.2])
			dividers(1.8 );
	}	
}

module standoff()
{
	difference()
	{
		cylinder(d1=7,d2=5,h=7);
		translate([0,0,2])	cylinder(d=2, h=7);
	}
}

module rtc_mounts() {
	// standoffs for rtc
	
	translate([25, 0, 2])
		standoff();
	
	translate([0, 18, 2])
		standoff();
	
	translate([25, 18, 2])
		standoff();
}

module case_back()
{
	difference()
	{
		union()
		{
			cube([max+1,max+1,2]);
			translate([-5,-5,0]) 		cube([5+1,max+6+5, c_h]);	// left side
			translate([max+1-1,-5,0])	cube([5+1,max+6+5, c_h]); // right side 
			translate([0,max-1,0]) 		#cube([max+2, 6+1, c_h]);	// top
			translate([-1,-5,0])		cube([max+2, 6+1, c_h]); 	// bottom
		}
		
		// mount holes 
		
		translate([-1.5,-1.5,0]) 			cylinder(d=3,h=c_h+4);	// ll 
		translate([max+1+1.5,-5+3.5,0]) 	cylinder(d=3,h=c_h+4);	// lr
		translate([-1.5,max+1+1.5,0]) 		cylinder(d=3,h=c_h+4);	// ul
		translate([max+1+1.5,max+1+1.5,0])	cylinder(d=3,h=c_h+4);	// ur 
		
		translate([-1.5,-1.5,0]) 			cylinder(d=5.5,h=4);	// ll 
		translate([max+1+1.5,-5+3.5,0]) 	cylinder(d=5.5,h=4);	// lr
		translate([-1.5,max+1+1.5,0]) 		cylinder(d=5.5,h=4);	// ul
		translate([max+1+1.5,max+1+1.5,0])	cylinder(d=5.5,h=4);	// ur 
		
		// FTDI cutout
		//#translate([18+6+5+6,-5,15])	cube([19, 8, 8]); 	// bottom

		// Time Adjust Button Holes

		translate([22.75+6.5+12, 10+46-2, 0])
			#cylinder(d=5,h=5);
					
		 	translate([22.75+6.5+12, 10+46+6, .2]) 
				rotate([0,180,0])
					linear_extrude(height = 0.2)
					text(
						"M", 
						font = f,
						size=6, 
						$fn=20, 
						valign="center", 
						halign = "center"
					);
		
		
		translate([22.75-6.5+25.5+12, 10+46-2, 0])	
			cylinder(d=5,h=5);
		
		translate([22.75-6.5+25.5+12, 10+46+6,.2])	rotate([0,180,0])
					linear_extrude(height = 0.2)
					text(
						"H", 
						font = f,
						size=6, 
						$fn=20, 
						valign="center", 
						halign = "center"
					);

		// power socket cutout
		
		translate([10,13,0])
			 cylinder(d=12,h=16);
		
		translate([12,26,0.2]) rotate([0,180,0])
					linear_extrude(height = 0.2)
					text(
						"+5vdc", 
						font = f,
						size=6, 
						$fn=20, 
						valign="center", 
						halign = "center"
					);
	}
	
	// standoffs for cpu pc 25.5 horiz 
	
	translate([22.75+12, 10, 2]) 			standoff();	// LL
	translate([22.75+12, 10+46, 2]) 		standoff();	// UL
	translate([22.75+25.5+12, 10, 2]) 		standoff();	// LR
	translate([22.75+25.5+12, 10+46, 2]) 	standoff();	// UR
	
	rotate([0,0,90])
		translate([30.5,-25,0])

			rtc_mounts();
}

module time_button()
{
	hull() {
		translate([18+30+5+5,10+12.5+1.5,0])	sphere(d=4);
		translate([18+30+5+5,10+12.5+1.5,0])	cylinder(d=4,h=3);
	}
	translate([18+30+5+5,10+12.5+1.5,5+.4-2.4])	cylinder(d=12,h=1.6);
	
	hull ()	{
		translate([18+30+5+5,10+30+1.5,0])	sphere(d=4);
		translate([18+30+5+5,10+30+1.5,0])	cylinder(d=4,h=3);
	}
	translate([18+30+5+5,10+30+1.5,5+.4-2.4])	cylinder(d=12,h=1.6);
}

// uncomment to print clock face
//translate([-15,0,10]) rotate([0,180,0]) clock_face();

// uncomment to print led diffusers
 translate([0,-80,0]) diffusers();

// uncomment to print back of case
// case_back();

// uncomment to print buttons
// rotate([180,0,0]) time_button();
