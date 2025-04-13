/* [General] */
$fn = 100;
Part = "SOCKET";  // [SOCKET:Socket, HOLD:Holdback]

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

/* [Hidden] */
epsilon = 0.01;
Base_Radius = Base_Diameter / 2;
Socket_Radius = Socket_Diameter / 2;

color("#48F") if (Part == "SOCKET") Socket();
else if (Part == "HOLD") Hold();

module Socket() {
  Socket_Base();
  // Socket
  cylinder(Socket_Height, r = Socket_Radius);
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

module Hold() {}

module line(start, end, thickness = .1) {
  hull() {
    translate(start) sphere(thickness);
    translate(end) sphere(thickness);
  }
}