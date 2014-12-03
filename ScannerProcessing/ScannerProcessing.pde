import processing.serial.*;
import java.io.*;

int distanceFromSensor = 428; //Millimeters from laser distance measure
String file;
Serial myPort;

void setup() {

  size(800, 600, P3D); 
  
  //Create file name for scan
  file = str(year()) + nf(month(),2) + nf(day(),2) + "_" + nf(hour(),2) + nf(minute(),2) + nf(second(),2);

  //Start serial comms and initialise
  boolean serial = startSerial();

  if (serial) {

    delay(1000);
    myPort.write(".");
    println("Serial connected");
  } else {
    println("Serial NOT connected");
  }
}

//Draws the data coming in. Everything else happens in serialEvent
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

