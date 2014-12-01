import processing.serial.*;

int distanceFromSensor = 428; //Millimeters from laser distance measure
int inRotation[] = new int[0];
int inHeight[] = new int[0];
int inDistance[] = new int[0];
int xVals[] = new int[0];
int yVals[] = new int[0];
int index = 0;
Serial myPort;

void setup() {
  size(800, 600, P3D); 

  //Start serial comms and initialise
  boolean serial = startSerial();
  if (serial) {
    println("Serial connected");
    myPort.write(".");
  } else {
    println("Serial NOT connected");
  }
}

void draw() {
  background(255);
  fill(0);
  for (int i = 0; i < index; i++) {
    point(xVals[i], yVals[i]);
  }
//  noStroke();
//  translate(width/2, height/2);
//  beginShape(POINTS);
//  for (int i = 0; i > inHeight.length; i++) {
//  }
//  endShape();
}

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
      xVals = append(xVals, int((distanceFromSensor - inDistance[index]) * cos(inRotation[index]) + width/2));
      println(xVals[index]);
      yVals = append(yVals, int((distanceFromSensor - inDistance[index]) * sin(inRotation[index]) + height/2));
      println(yVals[index]);
      index++;
    }
  }
}

boolean startSerial() {
  //Setup serial communication
  println(Serial.list());
  if (Serial.list().length > 0) {
    myPort = new Serial(this, Serial.list()[0], 9600);
    println("Port [0] selected for comms");
    myPort.bufferUntil('\n');
    myPort.clear();
    return true;
  } else {
    return false;
  }
}

void delay(int delay)
{
  int time = millis();
  while (millis () - time <= delay);
}

