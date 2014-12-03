

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
  
  if(mouseButton == RIGHT) {
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

