import processing.serial.*;
import java.io.*;

int distanceFromSensor = 428; //Millimeters from laser distance measure
String file;
String path = "C:/Users/Dark/Documents/Arduino/3DScanner/ScannerFiles/";
Serial myPort;

void setup() {

  size(800, 600, P3D); 
  println("3D Scanner by Dark.Spark");
  transX = width/2;
  transY = height/2;

  //Create file name for scan
  file = str(year()) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);

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


//This function is triggered when ever there is serial data on the port, checks data, formats and adds it to the array. 
//Also saves the file
void serialEvent (Serial myPort) {

  String inString = myPort.readStringUntil('\n');

  if (inString != null) {

    String[] match = match(inString, "#");

    if (match != null) {

      inString = trim(inString);
      inString = inString.substring(1);

      String[] split = split(inString, ',');

      println(split);

      inRotation = append(inRotation, int(split[0]));
      inHeight = append(inHeight, int(split[1]));
      inDistance = append(inDistance, int(split[2]) / 10);

      xVals = append(xVals, int((distanceFromSensor - inDistance[index]) * cos(radians(inRotation[index]))));
      yVals = append(yVals, int((distanceFromSensor - inDistance[index]) * sin(radians(inRotation[index]))));

      index++;
    }
    saveToFile(file);
  }
}

