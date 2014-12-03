
float rotX;
float rotY;
float rotZ;
int transX;
int transY;
float scale = 1;

//Moves and rotates
void mouseDragged() {  

  if (mouseButton == CENTER) {
    float alpha = 0.03;

    if (pmouseX - mouseX > 2) {
      rotY -= alpha;
    } else if (pmouseX - mouseX < -2) {
      rotY += alpha;
    }  
    if (pmouseY - mouseY > 2) {
      rotX += alpha;
    } else if (pmouseY - mouseY < -2) {
      rotX -= alpha;
    }
  }

  if (mouseButton == RIGHT) {
    float alpha = 0.05;

    if (pmouseX - mouseX > 2) {
      rotZ += alpha;
    } else if (pmouseX - mouseX < -2) {
      rotZ -= alpha;
    }
  }

  if (mouseButton == LEFT) {
    int alpha = 6;

    if (pmouseX - mouseX > 2) {
      transX -= alpha;
    } else if (pmouseX - mouseX < -2) {
      transX += alpha;
    }  
    if (pmouseY - mouseY > 2) {
      transY -= alpha;
    } else if (pmouseY - mouseY < -2) {
      transY += alpha;
    }
  }
}


// This function is called when ever the mouse wheel is moved, it then zooms the image
void mouseWheel(MouseEvent event) {
  int e = event.getCount();  

  if (e > 0) {
    scale *= 1.05;
  }
  if (e < 0) {
    scale *= 0.95;
  }
}


//Zoooooooooom
void keyPressed() {
  if (key == '+') {
    scale *= 1.05;
  }
  if (key == '-') {
    scale *= 0.95;
  }
}


//This function loads data from a specific file
int inRotation[] = new int[0];
int inHeight[] = new int[0];
int inDistance[] = new int[0];
int xVals[] = new int[0];
int yVals[] = new int[0];
int index = 0;

void loadFromFile(String file) {

  print("Loading from file: ");
  println(file);

  String[] loadlist = loadStrings(file);

  for (int i = 0; i < loadlist.length; i++) {

    String[] split = split(loadlist[i], ",");

    inRotation = append(inRotation, int(split[0]));
    inHeight = append(inHeight, int(split[2]));
    inDistance = append(inDistance, int(split[1]));

    xVals = append(xVals, int((distanceFromSensor - inDistance[index]) * cos(radians(inRotation[index]))));
    yVals = append(yVals, int((distanceFromSensor - inDistance[index]) * sin(radians(inRotation[index]))));

    index++;
  }

  print(index);
  println(" data points loaded");
}


// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


// This function returns all the files in a directory that have a specific extension as an array of Strings
String[] loadFilenames(String path) {
  File folder = new File(path);
  FilenameFilter filenameFilter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".txt"); // change this to any extension you want
    }
  };
  return folder.list(filenameFilter);
}


//This function creates the data string and saves it to a file
void saveToFile(String file) {

  String[] dataString = new String[index];

  for (int i = 0; i < index; i++) {
    dataString[i] = inRotation[i] + "," + inDistance[i] + "," + inHeight[i];
  }

  saveStrings(file, dataString);
}


//Delay
void delay(int delay)
{
  int time = millis();
  while (millis () - time <= delay);
}


//This function initiates the serial comms and returns state of connection
boolean startSerial() {

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

