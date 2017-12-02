//openscad flat-pack joint library

module finger_testing() {
  difference() {
    color("blue")
      square([100, 40]);
      outside_cuts(length=100, finger=5, material=10, center=false);
  }
  
  translate([0, -50])
  difference() {  
    color("red")
      square([100, 50]);
      #inside_cuts(length=100, finger=5, material=10, center=false);
  }
}

finger_testing();

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
    // add the "endcut" for a standard width cut plus any residual
    square([end_cut_length, material]);
    //create the standard fingers
    for (i = [0 : num_cuts]) {
      if(i < num_cuts) {
        translate([i*finger*2+padding, -overage/2]) //move the cuts slightly in y plane for overage
          square([finger, material+overage]); //add a tiny amount to the material thickness
      } else { // the last cut needs to be an end cut
        translate([i*finger*2+padding, -overage/2])
          square([end_cut_length, material+overage]);
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
        square([finger, material+overage]); //add a small amount to ensure complete cuts
    }
  }

} //end inside_cuts

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


