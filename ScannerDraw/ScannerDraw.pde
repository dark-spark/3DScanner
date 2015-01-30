import java.io.*;

int distanceFromSensor = 428; //Millimeters from laser distance measure
float inc = 0.01;
String path = "D:/GitHub/3DScanner/ScannerFiles/";

int[][] pointsX = new int[300][0];
int[][] pointsY = new int[0][0];

void setup() {

  size(800, 600, P3D); 
  println("3D Scanner by Dark.Spark");
  transX = width/2;
  transY = height/2;

  String[] filenames = loadFilenames(path);

  String recentFile = filenames[filenames.length -1];

  loadFromFile(path + recentFile);

  
  int a=0;
  int b=0;
//  int t = floor(index/120);
  
  
//  for(int i = 0; i < index - 120; i+=120) { //Loop through all the values for the height of the model
//    for(int j = 0; j < 120; j++) {  //Loop through all the values for the rotation of the model
//      pointsX[a][j] = inHeight[b];  //Add distance to the array for each point of data
//      b++;
//    }
//    a++;
//  }
}

void draw() {

  background(255);
  fill(100);
  noStroke();
  translate(transX, transY);
  lights();
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < 120; i++) {
    vertex(xVals[i], yVals[i], inHeight[i]);
    vertex(xVals[i+120], yVals[i+120], inHeight[i+120]);
  }
  rotateX(rotX);
  rotateY(rotY);
  rotateZ(rotZ);
  rotX += 0.01;
  rotY += 0.01;
  scale(scale);  
  endShape();
  /*
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
*/
}
