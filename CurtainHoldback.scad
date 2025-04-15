// It's a good thing you were wearing that helmet
/* [General] */
$fn = 100;
Part = "MOUNT";  // [MOUNT:Mount, LEVER:Lever, CAP:Cap, COMBINED:Combined]

/* [Mount] */
Mount_Diameter = 10;  // [1:0.1:50]
Mount_Height = 40;    // [0:0.1:200]

Base_Diameter = 50;  // [1:0.1:100]
Base_Height = 1;     // [0:0.01:10]

Screw_Count = 0;             // [0:1:20]
Screw_Circle_Diameter = 37;  // [1:0.1:100]
Screw_Diameter = 4;          // [0:0.1:10]
Screw_Head_Diameter = 4.5;   // [1:0.1:50]
Countersunk_Angle = 90;      // [0:1:120]

/* [Lever] */
Lever_Diameter = 10;  // [1:0.1:50]
Lever_Length = 50;    // [1:0.1:200]

/* [Joint] */
Joint_Backlash = 0.1;      // [0:0.01:1]
Joint_Depth = 1;           // [0:0.01:10]
Joint_Lock_Strenght = .5;  // [0:0.01:10]
Joint_Lock_Cutout = .5;    // [0:0.01:10]
Latch_Length = 2;          // [0:0.01:5]
Stop_Type = "CCW";         // [NONE:None, CCW:Counter Clock Wise, CW:Clock Wise]
Stopper_Size = 6;          // [0:0.1:50]
Cap_Backlash = .02;        // [0:0.01:1]

/* [Hidden] */
epsilon = 0.01;
Base_Radius = Base_Diameter / 2;
Mount_Radius = Mount_Diameter / 2;
Lever_Radius = Lever_Diameter / 2;

if (Part == "MOUNT")
  color("#48F") Mount();
else if (Part == "LEVER")
  color("#48F") Lever();
else if (Part == "CAP")
  color("#48F") Cap();
else if (Part == "COMBINED") {
  color("#48F") Mount();
  translate([ 0, Mount_Radius, Mount_Height + Lever_Radius + Joint_Backlash ])
      rotate([ 90, 0, 0 ]) color("#F84") Lever();
  translate([ 0, 0, Mount_Height + Lever_Diameter + Joint_Backlash * 2 ])
      color("#FF0") Cap();
}

module Mount() {
  Mount_Base();
  cylinder(Mount_Height, r = Mount_Radius);
  translate([ 0, 0, Mount_Height ]) Mount_Joint();
}

module Mount_Base() {
  if (Base_Diameter > Mount_Diameter) {
    difference() {
      r = Base_Radius - Mount_Radius;
      h = r < Mount_Height / 2 ? r : Mount_Height / 2;
      cylinder(h + Base_Height, r = Base_Radius);
      scale([ 1, 1, h / r ]) translate([ 0, 0, r + Base_Height ])
          rotate_extrude() translate([ Base_Radius, 0 ]) circle(r = r);
      Screw_Circle();
    }
  }
}

module Mount_Joint() {
  difference() {
    union() {
      cylinder(Lever_Diameter + Joint_Backlash * 2,
               r = Mount_Radius - Joint_Depth - Joint_Backlash);
      translate([ 0, 0, Lever_Diameter + Joint_Backlash * 2 ]) {
        cylinder(Latch_Length / 3, r = Mount_Radius);
        translate([ 0, 0, Latch_Length / 3 ]) cylinder(
            Latch_Length * 2 / 3, Mount_Radius,
            Mount_Radius - Joint_Depth - Joint_Lock_Strenght - Joint_Backlash);
      }
    }
    translate([ 0, 0, Joint_Backlash * 2 ]) Mount_Joint_Cutout(0);
  }

  if (Stop_Type != "NONE") {
    Stop_Dir = Stop_Type == "CCW" ? 1 : -1;
    translate(
        [ 0, -Mount_Radius + Stop_Dir * Stopper_Size / 2, -Stopper_Size / 2 ])
        rotate([ 0, 0, 90 * -Stop_Dir ]) intersection() {
      translate([ Stopper_Size / 2, 0, Stopper_Size / 2 ])
          sphere(Stopper_Size / 2);
      translate([ 0, Joint_Backlash / 2, 0 ])
          cube([ Stopper_Size, Stopper_Size / 2, Stopper_Size / 2 ]);
    }
  }
}

module Mount_Joint_Cutout(Backlash) {
  hc = Lever_Diameter + epsilon + Joint_Backlash * 2 + Latch_Length;
  rc = Mount_Radius - Joint_Depth - Joint_Lock_Strenght - Backlash;
  rat = rc / hc * 2;
  translate([ 0, 0, hc * 1 / 3 ]) cylinder(hc * 2 / 3, r = rc);
  translate([ 0, 0, hc / 3 + Backlash ]) scale([ rat, rat, 2 / 3 ])
      sphere(hc / 2);
  translate([ -Mount_Diameter / 2, -Joint_Depth + Backlash, Backlash ]) cube([
    Mount_Diameter + epsilon * 2, Joint_Depth * 2 - Backlash * 2,
    Lever_Diameter + Joint_Backlash * 2 + Latch_Length +
    epsilon
  ]);
  translate(
      [ Mount_Radius - Joint_Depth + Backlash, -Mount_Radius, Lever_Diameter ])
      cube([
        Joint_Depth - Backlash, Mount_Diameter, Latch_Length + Joint_Backlash
      ]);
  translate([ -Mount_Radius, -Mount_Radius, Lever_Diameter ]) cube([
    Joint_Depth - Backlash, Mount_Diameter, Latch_Length + Joint_Backlash
  ]);
}

module Screw_Circle() {
  r = Base_Radius - Mount_Radius;
  if (Screw_Count > 0) {
    countersunk = (Screw_Head_Diameter / 2) * tan(Countersunk_Angle / 2);
    x = Base_Radius - (Screw_Circle_Diameter + Screw_Head_Diameter) / 2;
    y = r - sqrt(r ^ 2 - x ^ 2);
    translate([ 0, 0, Base_Height ]) for (i = [0:Screw_Count - 1]) {
      rotate([ 0, 0, i * 360 / Screw_Count ])
          translate([ Screw_Circle_Diameter / 2, 0, -epsilon ]) union() {
        cylinder(r = Screw_Diameter / 2, h = Mount_Height);
        translate([ 0, 0, y ])
            cylinder(Mount_Height, r = Screw_Head_Diameter / 2);
        translate([ 0, 0, y - countersunk ])
            cylinder(h = countersunk, 0, Screw_Head_Diameter / 2);
      }
    }
  }
}

module Lever() {
  Lever_Joint();
  translate([ 0, 0, Mount_Diameter ]) {
    cylinder(Lever_Length, r = Lever_Radius);
    translate([ 0, 0, Lever_Length ]) sphere(Lever_Radius);
  }
}
module Lever_Joint() {
  difference() {
    hull() {
      cylinder(Mount_Diameter, 0, Lever_Radius);
      translate([ 0, Lever_Radius, Mount_Radius ]) rotate([ 90, 0, 0 ])
          cylinder(Lever_Diameter, r = Mount_Radius);
    }
    translate([ 0, Lever_Radius + epsilon, Mount_Radius ]) rotate([ 90, 0, 0 ])
        cylinder(Lever_Diameter + epsilon * 2, r = Mount_Radius - Joint_Depth);
  }
  if (Stop_Type != "NONE") {
    Stop_Dir = Stop_Type == "CCW" ? 1 : -1;
    translate([
      0, -Lever_Radius - Stop_Dir * Stopper_Size / 2 - Joint_Backlash,
      Mount_Diameter
    ]) rotate([ 0, 0, 90 * Stop_Dir ]) intersection() {
      translate([ Stopper_Size / 2, 0, 0 ]) sphere(Stopper_Size / 2);
      translate([ 0, Joint_Backlash / 2, 0 ])
          cube([ Stopper_Size, Stopper_Size / 2, Stopper_Size / 2 ]);
    }
  }
}

module Cap() {
  intersection() {
    union() {
      translate([ 0, 0, Joint_Backlash ]) {
        translate([ 0, 0, -Lever_Diameter - Joint_Backlash + Cap_Backlash ])
            cylinder(Latch_Length / 3 + Lever_Diameter - Cap_Backlash,
                     r = Mount_Radius);
        translate([ 0, 0, Latch_Length / 3 - Joint_Backlash ]) cylinder(
            Latch_Length * 2 / 3, Mount_Radius,
            Mount_Radius - Joint_Depth - Joint_Lock_Strenght - Joint_Backlash);
      }
    }
    intersection() {
      translate([ 0, 0, Joint_Backlash - Lever_Diameter - Joint_Backlash ])
          Mount_Joint_Cutout(Cap_Backlash);
      union() {
        cylinder(Latch_Length, r = Mount_Radius);
        translate([ 0, 0, -Lever_Diameter ]) cylinder(
            Lever_Diameter, r = Mount_Radius - Joint_Depth - Joint_Backlash);
      }
    }
  }
}

module line(start, end, thickness = .1) {
  hull() {
    translate(start) sphere(thickness);
    translate(end) sphere(thickness);
  }
}