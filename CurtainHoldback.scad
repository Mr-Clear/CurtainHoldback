/* [General] */
$fn = 100;
Part = "SOCKET";  // [SOCKET:Socket, HOLD:Holdback, COMBINED:Combined]

/* [Socket] */
Socket_Diameter = 10;  // [1:0.1:50]
Socket_Height = 40;    // [0:0.1:100]

Base_Diameter = 50;  // [1:0.1:100]
Base_Height = 1;     // [0:0.01:10]

Screw_Count = 0;             // [0:1:20]
Screw_Circle_Diameter = 37;  // [1:0.1:100]
Screw_Diameter = 4;          // [0:0.1:10]
Screw_Head_Diameter = 4.5;   // [1:0.1:50]
Countersunk_Angle = 90;      // [0:1:120]

/* [Holdback] */
Holdback_Diameter = 10;  // [1:0.1:50]
Holdback_Length = 50;    // [1:0.1:50]

/* [Joint] */
Joint_Backlash = 10;       // [0:0.01:5]
Joint_Depth = 1;           // [0:0.01:10]
Joint_Lock_Strenght = .5;  // [0:0.01:10]
Joint_Lock_Cutout = .5;    // [0:0.01:10]
Thing_Length = 2;          //  [0:0.01:5]

/* [Hidden] */
epsilon = 0.01;
Base_Radius = Base_Diameter / 2;
Socket_Radius = Socket_Diameter / 2;
Holdback_Radius = Holdback_Diameter / 2;

color("#48F") if (Part == "SOCKET") Socket();
else if (Part == "HOLD") Hold();
else if (Part == "COMBINED") {
  color("#48F") Socket();
  translate([
    0, Socket_Radius, Socket_Height + Holdback_Radius + Holdback_Diameter * 2
  ]) rotate([ 90, 0, 0 ]) color("#F84") Hold();
}

module Socket() {
  Socket_Base();
  cylinder(Socket_Height, r = Socket_Radius);
  translate([ 0, 0, Socket_Height ]) Socket_Joint();
}

module Socket_Base() {
  if (Base_Diameter > Socket_Diameter) {
    difference() {
      r = Base_Radius - Socket_Radius;
      h = r < Socket_Height / 2 ? r : Socket_Height / 2;
      cylinder(h + Base_Height, r = Base_Radius);
      scale([ 1, 1, h / r ]) translate([ 0, 0, r + Base_Height ])
          rotate_extrude() translate([ Base_Radius, 0 ]) circle(r = r);
      Screw_Circle(r);
    }
  }
}

module Socket_Joint() {
  difference() {
    union() {
      cylinder(Holdback_Diameter + Joint_Backlash * 2,
               r = Holdback_Radius - Joint_Depth - Joint_Backlash);
      translate([ 0, 0, Holdback_Diameter + Joint_Backlash * 2 ]) {
        cylinder(Thing_Length / 3, r = Socket_Radius);
        translate([ 0, 0, Thing_Length / 3 ])
            cylinder(Thing_Length * 2 / 3, Socket_Radius,
                     Holdback_Radius - Joint_Depth - Joint_Lock_Strenght -
                         Joint_Backlash);
      }
    }
    cylinder(Holdback_Diameter + epsilon + Joint_Backlash * 2 + Thing_Length,
             r = Holdback_Radius - Joint_Depth - Joint_Lock_Strenght -
                 Joint_Backlash);
    translate([ -Socket_Diameter / 2, -Joint_Depth, 0 ]) cube([
      Socket_Diameter + epsilon * 2, Joint_Depth * 2,
      Holdback_Diameter + Joint_Backlash * 2 + Thing_Length +
      epsilon
    ]);
  }
}

module Screw_Circle(r) {
  if (Screw_Count > 0) {
    countersunk = (Screw_Head_Diameter / 2) * tan(Countersunk_Angle / 2);
    x = Base_Radius - (Screw_Circle_Diameter + Screw_Head_Diameter) / 2;
    y = r - sqrt(r ^ 2 - x ^ 2);
    translate([ 0, 0, Base_Height ]) for (i = [0:Screw_Count - 1]) {
      rotate([ 0, 0, i * 360 / Screw_Count ])
          translate([ Screw_Circle_Diameter / 2, 0, -epsilon ]) union() {
        cylinder(r = Screw_Diameter / 2, h = Socket_Height);
        translate([ 0, 0, y ])
            cylinder(Socket_Height, r = Screw_Head_Diameter / 2);
        translate([ 0, 0, y - countersunk ])
            cylinder(h = countersunk, 0, Screw_Head_Diameter / 2);
      }
    }
  }
}

module Hold() {
  Hold_Joint();
  translate([ 0, 0, Socket_Diameter ]) {
    cylinder(Holdback_Length, r = Holdback_Radius);
    translate([0,0, Holdback_Length])
        sphere(Holdback_Radius);
  }
}
module Hold_Joint() {
  difference() {
    hull() {
      cylinder(Holdback_Diameter, 0, Socket_Radius);
      translate([ 0, Socket_Radius, Holdback_Radius ]) rotate([ 90, 0, 0 ])
          cylinder(Socket_Diameter, r = Holdback_Radius);
    }
    translate([ 0, Holdback_Radius + epsilon, Holdback_Radius ])
        rotate([ 90, 0, 0 ]) cylinder(Holdback_Diameter + epsilon * 2,
                                      r = Holdback_Radius - Joint_Depth);
  }
}

module line(start, end, thickness = .1) {
  hull() {
    translate(start) sphere(thickness);
    translate(end) sphere(thickness);
  }
}