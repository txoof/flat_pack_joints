//openscad flat-pack joint library



module outsideCuts(length=100, finger=8, material=5, text=false, center=false) {
  // overage to ensure that all cuts are completed
  o = 0.0001;


  //maximum possible divisions for this length
  maxDiv = floor(length/finger);
  //number of usable divisions that fall completely within the edge
  //for this implentation the number of divisions must be odd
  uDiv = maxDiv%2==0 ? maxDiv-3 : maxDiv-2;

  // number of "female cuts"
  numCuts = floor(uDiv/2);

  //length of cut at either end
  endCut = (length-uDiv*finger)/2;

  padding = endCut + finger;
  //echo("outsideCuts\nmaxDiv", maxDiv, "\nuDiv", uDiv, "\nnumCuts", numCuts, "\nendCut", endCut);

  xTrans = center==false ? 0 : -(numCuts*2+1)*finger/2-endCut;
  yTrans = center==false ? 0 : -material/2;

  translate([xTrans, yTrans]) {
    // add the "endcut" for a standard width cut plus any residual
    square([endCut, material]);
    //create the standard fingers
    for (i=[0:numCuts]) {
      if(i < numCuts) {
        translate([i*finger*2+padding, -o/2]) //move the cuts slightly in y plane for overage
          square([finger, material+o]); //add a tiny amount to the material thickness
      } else { // the last cut needs to be an end cut
        translate([i*finger*2+padding, -o/2])
          square([endCut, material+o]);
      }
    }
  }

  debugText = finger>=length/3 ? "ERR: finger>1/3 length" : "outsideCut";


  if (text) {
    translate([length/2+xTrans, yTrans+material*2])
    text(text=debugText, size = length*.05, halign = "center", font = font);
    //echo(debugText);
  }

}


module insideCuts(length = 100, finger = 8, material = 5, text = true, center = false) {
  // overage to ensure that all cuts are completed
  o = 0.0001;


  //maximum possible divisions for this length
  maxDiv = floor(length/finger);
  //number of usable divisions that fall completely within the edge
  //for this implementation the number of divisions must be odd
  uDiv = maxDiv%2==0 ? maxDiv-3 : maxDiv-2;

  // number of "female cuts"
  numCuts = ceil(uDiv/2);

  //echo("insideCuts\nmaxDiv", maxDiv, "\nuDiv", uDiv, "\nnumCuts", numCuts);

  xTrans = center==false ? 0 : -uDiv*finger/2;
  yTrans = center==false ? 0 : -material/2;

  translate([xTrans, yTrans]) {
    for (i=[0:numCuts-1]) {
      translate([i*finger*2, -o/2, 0]) //move the cuts slightly in y plane for complete cuts
        square([finger, material+o]); //add a small amount to ensure complete cuts
    }
  }
  debugText = finger>=length/3 ? "ERR: finger>1/3 length" : "insideCut";


  if (text) {
    translate([0, yTrans+material*2])
      text(text=debugText, size = length*0.05, halign = "center", font = font);
    //echo(debugText);
  }

}
