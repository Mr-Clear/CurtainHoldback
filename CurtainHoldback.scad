Part = "SOCKET";  // [SOCKET:Socket, HOLD:Holdback]

$fn = 100;

Socket_Diameter = 10;  // [1:0.1:50]
Socket_Height = 40;    // [0:0.1:100]

Base_Diameter = 50;  // [1:0.1:100]
Base_Height = 1;     // [0:0.01:10]

/* [Hidden] */
Base_Radius = Base_Diameter / 2;
Socket_Radius = Socket_Diameter / 2;

if (Part == "SOCKET")
  socket();
else if (Part == "HOLD")
  hold();

module socket() {
  // Base
  if (Base_Diameter > Socket_Diameter) {
    difference() {
      r = Base_Radius - Socket_Radius;
      h = r < Socket_Height / 2 ? r : Socket_Height / 2;
      cylinder(h + Base_Height, r = Base_Radius);
      scale([ 1, 1, h / r ]) translate([ 0, 0, r + Base_Height ])
          rotate_extrude() translate([ Base_Radius, 0 ]) circle(r = r);
    }
  }
  // Socket
  cylinder(Socket_Height, r = Socket_Radius);
}

module hold() {
}