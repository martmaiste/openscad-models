// Pocket Coin-Op Bottle Opener
// Originally by br3ttb (https://www.thingiverse.com/thing:11025/files)
// Licensed under the Creative Commons - Attribution - Share Alike (CC BY-SA) license.
//
// Remixed/Updated Version: v1.14
// - Added original author attribution and CC BY-SA license headers
// - Removed top and bottom badge options
// - Defined coin diameter instead of radius
// - Fixed thin coincident surfaces in preview mode
// - Set global smoothness ($fn = 100)
// - Added high-performance 2D-offset beveledExtrude for rounded top/bottom outer edges (no slow minkowski)
// - Added high-performance 2D-offset beveledCutoutExtrude for flaring hole/slot edges (producing beautifully rounded top/bottom cutout edges)
// - Resolved OpenCSG ghost membrane preview artifacts by adding a tiny 0.05mm vertical layer overlap and wrapping extrusions in union()
// - Updated default coin pocket dimensions to coinDiameter = 19-5 and coinThickness = 1.9
// - Fixed OpenSCAD warning about passing unused 'thick' parameter to roundedTrapezoid2D in the central hole cutout
// - Added printOnSide configuration option to rotate and stand the opener on its long flat side edge for extra layer strength and support-less printing
// - Fixed printOnSide rotation order to ensure the side edge lies perfectly flat on the print bed (Z=0 plane)
// - Added silver stainless steel washer visualization configurable via showWasher variable
// - Set default layout to printOnSide = true
// - Moved showWasher visualization inside the opener() module to ensure correct 3D positioning when printOnSide = true

//Overall Opener Configuration
$fn = 100; // Smoothness of circles and curves

base = 22;
length=50;
baseR1=5;
baseR2=5;
thickness=6;
angle = 13.5;

//Hole Configuration
holeBaseWidth=23;
holeBaseLoc=25.5;
holeLength=19.5;
holeR1=2;
holeR2=6;

//KeyRingSlot
slotWidth = 17;
slotHeight = 6;
slotInset=2.5;


//Coin Size and position
coinDiameter = 19-5;
coinThickness = 1.9;
coinOverhang = 3;

coinRadius = coinDiameter / 2;

//Ergonomic bevel/fillet height for top and bottom outer edges (0 to disable)
bevelHeight = 1.0;

//Printing Layout Option
printOnSide = true; // Set to true to rotate and stand the opener on its long flat side edge for maximum layer strength and support-less printing

//Visualization Options
showWasher = $preview; // Set to true to force show the washer in all views, false to hide, or keep as $preview to show in F5 preview only


if (printOnSide)
{
	// First rotate around Z by angle to align the bottom side edge with the X-axis,
	// then rotate around X by 90 to stand the flat face on the XY plane (Z=0).
	rotate([90, 0, 0])
		rotate([0, 0, angle])
			opener();
}
else
{
	opener();
}


module opener()
{
	difference()
	{
		// Main outer body with rounded top and bottom edges
		beveledExtrude(thick=thickness, bevelHeight=bevelHeight)
			roundedTrapezoid2D(length=length, r1=baseR1, r2=baseR2, baseW=base, angle=angle);

		// Central hole with rounded top and bottom edges
		translate([holeBaseLoc,(base-holeBaseWidth)/2,0])
			beveledCutoutExtrude(thick=thickness, bevelHeight=bevelHeight)
				roundedTrapezoid2D(baseW=holeBaseWidth, angle=angle, length=holeLength, r1=holeR1, r2=holeR2);

		// Keyring slot with rounded top and bottom edges
		beveledCutoutExtrude(thick=thickness, bevelHeight=bevelHeight)
			keyRingSlot2D(slotWidth=slotWidth, slotHeight=slotHeight, slotInset=slotInset, base=base);

		// Coin pocket (remains sharp and flat on the inside for optimal coin grip)
		translate([holeBaseLoc-coinRadius+coinOverhang,base/2,(thickness-coinThickness)/2])
		{
			translate([0,-coinRadius,0])cube([coinRadius,2*coinRadius,coinThickness]);
			cylinder(r=coinRadius,h=coinThickness);
		}
	}

	// Show the silver washer inside the opener so it rotates/positions perfectly with it
	if (showWasher)
	{
		color("Silver")
			translate([holeBaseLoc - coinRadius + coinOverhang, base/2, (thickness - coinThickness)/2])
				difference()
				{
					cylinder(r = coinRadius, h = coinThickness);
					translate([0, 0, -0.5])
						cylinder(r = coinRadius * 0.4, h = coinThickness + 1.0);
				}
	}
}


// High-performance bevel extruder for the outer body (shrinks at top/bottom)
module beveledExtrude(thick, bevelHeight) {
	if (bevelHeight > 0) {
		steps = 8; // Number of vertical layers in the fillet
		overlap = 0.05; // tiny vertical overlap to prevent CSG ghost membranes
		
		union() {
			// Bottom fillet (from z = 0 to bevelHeight)
			for (i = [0 : steps-1]) {
				a1 = (i / steps) * 90;
				a2 = ((i+1) / steps) * 90;
				z_start = bevelHeight * (1 - cos(a1));
				z_end = bevelHeight * (1 - cos(a2));
				h = (z_end - z_start) + overlap;
				a_mid = ((a1 + a2) / 2);
				off = -bevelHeight * (1 - sin(a_mid));
				translate([0, 0, z_start])
					linear_extrude(height = h)
						offset(delta = off) children();
				}

			// Middle straight section
			translate([0, 0, bevelHeight])
				linear_extrude(height = thick - 2*bevelHeight + overlap)
					children();

			// Top fillet (from z = thick - bevelHeight to thick)
			for (i = [0 : steps-1]) {
				a1 = (i / steps) * 90;
				a2 = ((i+1) / steps) * 90;
				z_start = thick - bevelHeight + bevelHeight * sin(a1);
				z_end = thick - bevelHeight + bevelHeight * sin(a2);
				h = (z_end - z_start) + ((i == steps-1) ? 0 : overlap);
				a_mid = ((a1 + a2) / 2);
				off = -bevelHeight * (1 - cos(a_mid));
				translate([0, 0, z_start])
					linear_extrude(height = h)
						offset(delta = off) children();
			}
		}
	} else {
		// Fallback to simple extrusion if bevelHeight is 0
		linear_extrude(height = thick)
			children();
	}
}


// High-performance flared extruder for cutouts (expands at top/bottom to round the hole edges)
module beveledCutoutExtrude(thick, bevelHeight) {
	if (bevelHeight > 0) {
		steps = 8; // Number of vertical layers in the fillet
		overlap = 0.05; // tiny vertical overlap to prevent CSG ghost membranes
		
		union() {
			// Bottom flared section (from z = -1 to bevelHeight)
			for (i = [0 : steps-1]) {
				a1 = (i / steps) * 90;
				a2 = ((i+1) / steps) * 90;
				z_start = (i == 0) ? -1 : bevelHeight * (1 - cos(a1));
				z_end = bevelHeight * (1 - cos(a2));
				h = (z_end - z_start) + overlap;
				a_mid = ((a1 + a2) / 2);
				off = bevelHeight * (1 - sin(a_mid));
				translate([0, 0, z_start])
					linear_extrude(height = h)
						offset(delta = off) children();
			}

			// Middle straight section
			translate([0, 0, bevelHeight])
				linear_extrude(height = thick - 2*bevelHeight + overlap)
					children();

			// Top flared section (from z = thick - bevelHeight to thick + 1)
			for (i = [0 : steps-1]) {
				a1 = (i / steps) * 90;
				a2 = ((i+1) / steps) * 90;
				z_start = thick - bevelHeight + bevelHeight * sin(a1);
				z_end = (i == steps-1) ? thick + 1 : thick - bevelHeight + bevelHeight * sin(a2);
				h = (z_end - z_start) + ((i == steps-1) ? 0 : overlap);
				a_mid = ((a1 + a2) / 2);
				off = bevelHeight * (1 - cos(a_mid));
				translate([0, 0, z_start])
					linear_extrude(height = h)
						offset(delta = off) children();
			}
		}
	} else {
		// Fallback to simple cutout extrusion extending beyond top/bottom
		translate([0, 0, -1])
			linear_extrude(height = thick + 2)
				children();
	}
}


// 2D Keyring slot definition
module keyRingSlot2D(slotWidth, slotHeight, slotInset, base) {
	translate([slotHeight/2 + slotInset, (base - slotWidth + slotHeight)/2])
		circle(r = slotHeight/2);
	translate([slotHeight/2 + slotInset, (base + slotWidth - slotHeight)/2])
		circle(r = slotHeight/2);
	translate([slotInset, (base - slotWidth + slotHeight)/2])
		square([slotHeight, slotWidth - slotHeight]);
}


// 3D wrapper of roundedTrapezoid for cutout compatibility
module roundedTrapezoid(thick=5, length=19.5, r1=2, r2=9.5, angle=13.5, baseW=23)
{
	linear_extrude(height=thick)
		roundedTrapezoid2D(length=length, r1=r1, r2=r2, angle=angle, baseW=baseW);
}


// 2D roundedTrapezoid definition
module roundedTrapezoid2D(length=19.5, r1=2, r2=9.5, angle=13.5, baseW=23)
{
	x1 = length*sin(angle);
	difference()
	{
		trapezoidSolid2D(length = length, r1=r1, r2=r2, angle = angle, baseW=baseW);
		translate([length,-1*x1])square([2*r2-length,baseW+2*x1]);
		rotate([0,0,-1*angle])translate([0,-1*(r1+r2)])square([length,r1+r2]);
		translate([0,baseW]) rotate([0,0,angle])square([ length,r1+r2]);
	}
}


// 2D trapezoidSolid definition
module trapezoidSolid2D(length=19.5, r1=1, r2=9.5, angle=13.5, baseW=23)
{
	r1oSet = length/cos(angle)-r1*tan((90+angle)/2);
	sideoSet = r2*tan((90-angle)/2);
	sidelen = r1oSet-sideoSet;
	bottomoSet = (length*sin(angle))-r1*tan((90+angle)/2);

	rotate([0,0,-1*angle])
	{
		translate([r1oSet,r1])circle(r=r1);
		translate([sideoSet,r2])circle(r=r2);
		translate([sideoSet,0]) square([sidelen,2*r1]);
	}
	
	translate([0,baseW])rotate([0,0,angle])
	{
		translate([0,-2*r1])
		{
			translate([r1oSet,r1])circle(r=r1);
			translate([sideoSet,-r2+2*r1])circle(r=r2);
			translate([sideoSet,0]) square([sidelen,2*r1]);
		}
	}
	translate([0,sideoSet])square([length,baseW-2*sideoSet]);
	translate([r2,-bottomoSet])square([length-r2,baseW+2*bottomoSet]);
}
