int distanceFromSensor = 428; //Millimeters from laser distance measure
float inc = 0.01;
float rotX;
float rotY;
float rotZ;
int transX = width/2;
int transY = height/2;
float scale = 1;

void setup() {

  size(800, 600, P3D); 

  String path = sketchPath;

  String[] fileNames = listFileNames(path);

  for (int i = 0; i < fileNames.length; i++) {
  }

  loadFromFile("FirstScan.txt");
}

void draw() {
  
  background(255);
  fill(0);
  translate(transX, transY);
  
  beginShape(POINTS);
  strokeWeight(2);
  
  for (int i = 0; i < index; i++) {
    vertex(xVals[i], yVals[i], inHeight[i]);
  }
  
  rotateX(rotX);
  rotateY(rotY);
  rotateZ(rotZ);
  scale(scale);
  endShape();
}

