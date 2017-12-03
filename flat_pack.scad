//openscad flat-pack joint library

module finger_testing() {
  difference() {
    color("blue")
      square([110, 40]);
      #outside_cuts(length=110, finger=5, material=10, center=false);
  }
  
  rotate([180, 0, 0])
  translate([0, 0])
  difference() {  
    color("red")
      square([110, 50]);
      translate([55, 5])
      #inside_cuts(length=110, finger=5, material=10, center=true);
  }
}
//finger_testing();

module curved_test(dim=[100, 50, 45]) {
  translate() {
    //faceXY
    difference() {
      square([dim[0], dim[1]]);
      outside_cuts(length=dim[0], finger=5, material=10, type = "curved");
      translate([dim[0]/2, dim[1]/2])
        text(text="faceXY", size=dim[0]*.1, halign="center"); 
    }
  }
  //faceXZ
  translate([0, -dim[1]]) {
    difference() {
      square(size=[dim[0], dim[1]]);
      translate([dim[0]/2, dim[1]-5])
        rotate([0, 0, 180])
        inside_cuts(length=dim[0], finger=5, material=10, type="curved", center=true);
    }
  }
}

curved_test();

/*
##module: outside_cuts
Create a set of finger-joint cuts that result in two larger cuts taken at the outside
edge
  ###parameters:
    *length* (real)         length of edge
    *finger* (real)         length of each individual finger
    *material* (real)       thickness of material - sets cut depth
    *center* (boolean)         center the set of fingers with respect to origin
*/

module outside_cuts(length=6, finger=1, material=1, text=false, center=false) {
  // overage to ensure that all cuts are completed
  overage = 0.0001;


  //maximum possible divisions for this length
  max_divisions = floor(length/finger);
  //number of usable divisions that fall completely within the edge
  //for this implentation the number of divisions must be odd
  usable_divisions = max_divisions%2==0 ? max_divisions-3 : max_divisions-2;

  // number of "female cuts"
  num_cuts = floor(usable_divisions/2);

  //length of cut at either end
  end_cut_length = (length-usable_divisions*finger)/2;

  padding = end_cut_length + finger;

  //set position relative to origin
  x_translation = center==false ? 0 : -(num_cuts*2+1)*finger/2-end_cut_length;
  y_translation = center==false ? 0 : -material/2;


  translate([x_translation, y_translation]) {
  
    // make both endcuts here
    for (j = [0, 1]) {
      translate([(length-end_cut_length)*j, -overage/2])
        square([end_cut_length, material+overage]);
        if (type == "curved") {
          //very inelegant solution here
          translate([end_cut_length-finger+(length-2*end_cut_length+finger)*j, -overage/2])
            curved_finger([finger, material+overage]);
        }
    }
    

    //make all the "normal" finger cuts here
    for (i = [0 : num_cuts-1]) {
      translate([i*finger*2+padding, -overage/2]) //move cuts slightly in y plane
        if (type == "curved") {
          curved_finger([finger, material+overage]);
        } else {
          square([finger, material+overage]);
        }
    
    }
  }

} //end outside_cuts


/*
##module: inside_cuts
Create a set of finger-joint cuts all of the same size  
###parameters:
    *length* (real)         length of edge
    *finger* (real)         length of each individual finger
    *material* (real)       thickness of material - sets cut depth
    *center* (boolean)         center the set of fingers with respect to origin
*/

module inside_cuts(length=6, finger=1, material=1, text=false, center=false) {
  // overage to ensure that all cuts are completed
  overage = 0.0001;


  //maximum possible divisions for this length
  max_divisions = floor(length/finger);
  //number of usable divisions that fall completely within the edge
  //for this implementation the number of divisions must be odd
  usable_divisions = max_divisions%2==0 ? max_divisions-3 : max_divisions-2;

  // number of "female cuts"
  num_cuts = ceil(usable_divisions/2);

  //set position relative to origin
  x_translation = center==false ? 0 : -usable_divisions*finger/2;
  y_translation = center==false ? 0 : -material/2;

  translate([x_translation, y_translation]) {
    for (i = [0 : num_cuts-1]) {
      translate([i*finger*2, -overage/2, 0]) //move the cuts slightly in y plane for complete cuts
      if (type == "curved") {
        curved_finger([finger, material+overage]);
      } else {
        square([finger, material+overage]); //add a small amount to ensure complete cuts
      }
    }
  }

} //end inside_cuts



module curved_finger(size, quality=24) {
  //curve quality
  $fn = quality;

  //radius - use the X dimension if the Y dimension is larger
  r = size[0] > size[1] ? size[1] : size[0]/2;
  x_trans = size[0]/2;
  y_trans = -size[1]/2+r/2;

  //generate a quarater of a square differenced with an inscribed circle
  //polarity  [-1, 1]   left or right of origin 
  module quarter(polarity=-1) {
    translate([polarity*r/2, 0]) {
      difference() {
        square(r, center = true);
        translate([polarity*r/2, r/2])
          circle(r=r);
      }
    }
  }
  //position the finger so it is set in the same orientation as a square()
  translate([size[0]/2, size[1]/2]) {
    //add quarter square to finger
    union() {
      square(size=size, center=true);  
      for (i = [-1, 1]) {
        translate([(x_trans)*i, y_trans])
          quarter(polarity=i);
      }
    }
  }

}


/*
##module: intside_cuts_debug
Create a set of finger-joint cuts all of the same size  
  ###parameters:
    *length*      (real)           length of edge
    *finger*      (real)           length of each individual finger
    *material*    (real)           thickness of material - sets cut depth
    *center*      (boolean)        center the set of fingers with respect to origin
    *font*        (string)         name of font 
*/


module inside_cuts_debug(length=6, finger=1, material=1, center=false, font="Liberation Sans") {  

  x_translation = center==false ? length/2 : 0;
  y_translation = center==false ? material*1.5 : material; 

  inside_cuts(length=length, finger=finger, material=material, center=center);

  debugText = finger>=length/3 ? "ERR: finger>1/3 length" : "inside cuts";

  translate([x_translation, y_translation,  0])
  text(text=debugText, size = length*.1, halign = "center", font = font);


} // end inside debug


/*
##module: outside_cuts_debug
Create a set of finger-joint cuts that result in two larger cuts taken at the i
inside edge with debugging text
  ###parameters:
    *length*      (real)           length of edge
    *finger*      (real)           length of each individual finger
    *material*    (real)           thickness of material - sets cut depth
    *center*      (boolean)        center the set of fingers with respect to origin
    *font*        (string)         name of font 
*/

module outside_cuts_debug(length=6, finger=1, material=1, center=false, font="Liberation Sans") {  

  x_translation = center==false ? length/2 : 0;
  y_translation = center==false ? material*1.5 : material; 

  outside_cuts(length=length, finger=finger, material=material, center=center);

  debugText = finger>=length/3 ? "ERR: finger>1/3 length" : "outside cuts";

  translate([x_translation, y_translation,  0])
  text(text=debugText, size = length*.1, halign = "center", font = font);


} // end outside debug


//!curved_finger(size=[5, 2]);
