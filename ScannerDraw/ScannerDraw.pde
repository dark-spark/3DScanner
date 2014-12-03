int xVals[] = new int[0];
int yVals[] = new int[0];
int inDistance[] = new int[0];
int inRotation[] = new int[0];
int distanceFromSensor = 428; //Millimeters from laser distance measure
int index = 0;
float inc = 0.01;

void setup() {
  
  size(800, 600, P3D); 
  
  float rads = PI / 180;
  
  for (int i = 0; i < 180; i++) {
    inRotation = append(inRotation, i);
    inDistance = append(inDistance, 350);

    xVals = append(xVals, int(((distanceFromSensor - inDistance[index]) * cos(inRotation[index]*rads)) ));
    yVals = append(yVals, int(((distanceFromSensor - inDistance[index]) * sin(inRotation[index]*rads))));
    index++;
  }
  println(inRotation);
  println(xVals);
  println(yVals);
}

void draw() {
  background(255);
  fill(0);  
  inc += 0.01;
  translate(width/2, height/2);
  beginShape(POINTS);
  for (int i = 0; i < index; i++) {
    vertex(xVals[i], yVals[i], 0);
  }
  rotateX(inc);
  rotateY(inc);
  endShape();
//  for (int i = 0; i < index; i++) {
//    point(xVals[i], yVals[i]);
//  }
}

