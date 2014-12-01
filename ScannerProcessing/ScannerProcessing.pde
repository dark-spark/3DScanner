import processing.serial.*;

int inRotation[] = new int[0];
int inHeight[] = new int[0];
int inDistance[] = new int[0];
int index = 0;
Serial myPort;

void setup() {
  size(800, 600, P3D); 

  //Start serial comms and initialise
  boolean serial = startSerial();
  if (serial) {
    println("Serial connected");
    myPort.write("Begin");
  } else {
    println("Serial NOT connected");
  }
}

void draw() {




}

void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n');
  if (inString != null) {
    String match[] = match(inString, "*");
    if (match != null) {
      inString = trim(inString);
      String[] split = split(inString, ',');
      for (int i = 0; i < split.length; i++) {
        inRotation = append(inRotation, int(split[0]));
        inHeight = append(inHeight, int(split[1]));
        inDistance = append(inDistance, int(split[2]));
      }
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

