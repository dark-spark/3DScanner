import java.io.*;

int distanceFromSensor = 428; //Millimeters from laser distance measure
float inc = 0.01;
String path = "C:/Users/Dark/Documents/Arduino/3DScanner/ScannerFiles/";

void setup() {

  size(800, 600, P3D); 
  transX = width/2;
  transY = height/2;

  String[] filenames = loadFilenames(path);

  String recentFile = filenames[filenames.length -1];

  loadFromFile(recentFile);
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

