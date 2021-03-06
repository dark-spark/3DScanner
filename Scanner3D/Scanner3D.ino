#include <Encoder.h>
#include <Stepper.h>
#include <FastLED.h>
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>
#include <SoftI2CMaster.h>
#include <avr/io.h>

#define NUM_LEDS 1
#define DATA_PIN 0

#define SDA_PORT PORTB
#define SDA_PIN 0
#define SCL_PORT PORTB
#define SCL_PIN 1
#define I2C_TIMEOUT 100
#define I2C_NOINTERRUPT 0
#define I2C_SLOWMODE 1

const int stepsPerRev = 48;
const int distPerRev = 127;
const int vertResolution = 2; //Resolution in mm.
const int rotationResolution = 3; //Resoltion in degrees.
const int vertTravel = 200; //In mm.
const int indexPin = 6;
const int plateMotor1 = 9;
const int plateMotor2 = 10;
const int sensorPin = 21;
const int vertLowerLimit = 3;
Encoder encoder(5, 4);
boolean encoderIndex = false;
int desired;
int desiredCounts;
int platePos;
int platePosNew = 0;
int distance = 0;
int mode = 0;
boolean recdata = true;
boolean data;
boolean measuring = false;
int buf [64] ;
int rc = 0 ;
Stepper vertStepper(stepsPerRev, 12, 13, 14, 15);
String recieved;

// Creat a set of new characters
const uint8_t charBitmap[][8] = {
  { 
    0xc, 0x12, 0x12, 0xc, 0, 0, 0, 0   }
  ,
  { 
    0x6, 0x9, 0x9, 0x6, 0, 0, 0, 0   }
  ,
  { 
    0x0, 0x6, 0x9, 0x9, 0x6, 0, 0, 0x0   }
  ,
  { 
    0x0, 0xc, 0x12, 0x12, 0xc, 0, 0, 0x0   }
  ,
  { 
    0x0, 0x0, 0xc, 0x12, 0x12, 0xc, 0, 0x0   }
  ,
  { 
    0x0, 0x0, 0x6, 0x9, 0x9, 0x6, 0, 0x0   }
  ,
  { 
    0x0, 0x0, 0x0, 0x6, 0x9, 0x9, 0x6, 0x0   }
  ,
  { 
    0x0, 0x0, 0x0, 0xc, 0x12, 0x12, 0xc, 0x0   }
};

//CRGB leds[NUM_LEDS];
LiquidCrystal_I2C lcd(0x38);  // Set the LCD I2C address

void setup() {

  Serial.begin(115200);
  Serial1.begin (115200);
  Serial.println("3D Scanner by Dark.Spark");

  pinMode(indexPin, INPUT);
  pinMode(vertLowerLimit, INPUT_PULLUP);
  pinMode(plateMotor1, OUTPUT);
  pinMode(plateMotor2, OUTPUT);

  if (!i2c_init()) 
    Serial.println(F("Initialization error. SDA or SCL are low"));
  else
    Serial.println(F("...done"));

  int charBitmapSize = (sizeof(charBitmap ) / sizeof (charBitmap[0]));

  lcd.begin(16,2);               // initialize the lcd 

  for ( int i = 0; i < charBitmapSize; i++ )
  {
    lcd.createChar ( i, (uint8_t *)charBitmap[i] );
  }

  lcd.home ();                   // go home
  lcd.print("Hello. 3DPrinter ");  
  lcd.setCursor ( 0, 1 );        // go to the next line
  lcd.print ("by Dark-Spark");

  vertStepper.setSpeed(100);
  findVertLowerLimit();
  findIndex();
  mode = 0;


}

void loop() {
  if(mode == 0) {
    if (Serial.available()) {
      char inChar = (char)Serial.read();
      if (inChar == '.') {
        mode = 2;
      }
    }
  }
  else if(mode == 2) {
    for (int i = 0; i <= vertTravel; i = i + vertResolution) {
      //      int t = millis();
      for (int j = 0; j <= 359; j = j + rotationResolution) {
        plateMove(j);
        delay(100); //Wait for plate motion to settle. 
        distance = getDistance();
        serialSend(j, i, distance);
      }
      findIndex();
      vertStepper.step(-steps(vertResolution));
      //      Serial.print("Timer = ");
      //      Serial.println(millis() - t);
    }
  } 
  else {
    mode = 0;
  }
}

void findVertLowerLimit() {
  while(digitalRead(vertLowerLimit) == HIGH) {
    vertStepper.step(1);
  }
}

int steps(int distance) {
  int steps;
  steps = ((distance*100)/distPerRev)*stepsPerRev;
  return steps;
}

void plateMotorForwardFast() {
  digitalWrite(plateMotor1, HIGH);
  digitalWrite(plateMotor2, LOW);
}

void plateMotorForwardSlow() {
  analogWrite(plateMotor1, 100);
  digitalWrite(plateMotor2, LOW);
}

void plateMotorBackwardFast() {
  digitalWrite(plateMotor1, LOW);
  digitalWrite(plateMotor2, HIGH);
}

void plateMotorBackwardSlow() {
  analogWrite(plateMotor1, LOW);
  digitalWrite(plateMotor2, 100);
}

void plateMotorStop() {
  digitalWrite(plateMotor1, LOW);
  digitalWrite(plateMotor2, LOW);
}

void findIndex() {
  Serial.print("Finding Index of Encoder...");
  while (encoderIndex == false) {
    plateMotorForwardSlow();
    if (digitalRead(indexPin) == HIGH) {
      encoderIndex = true;
      encoder.write(0);
    }
  }
  plateMotorStop();
  Serial.println("Index Found, encoder counts reset to zero");
}

unsigned int counts(unsigned long desiredDeg) {
  unsigned long counts;
  counts = desiredDeg * 1137;
  counts = counts / 100;
  return counts;
}

void plateMove(int desiredPlatePos) {
  Serial.print("Moving Plate to Desired Position...");
  platePos = encoder.read();
  if (platePos != 0) {
    encoderIndex = false;
  }
  desiredCounts = counts(desiredPlatePos);
  while (platePos <= desiredCounts) {
    platePos = encoder.read();
    plateMotorForwardSlow();
    delay(10);
  }
  plateMotorStop();
  Serial.println("Desired Position Reached");
}

int distanceMeasure() {
  Serial.print("Requesting a measurement...");
  Serial1.write ("* 00004 # ");
  char buf[64];
  char *comma;
  int dist;
  int rc;
  for (;;) {
    rc = Serial1.readBytesUntil('\n', buf, sizeof(buf));
    buf[rc] = '\0';
    if (!strstart_P(buf, PSTR("Dist: ")))
      continue;
    comma = strchr(buf, ',');
    if (comma == NULL)
      continue;
    *comma = '\0';
    dist = atoi(buf + strlen_P(PSTR("Dist: ")));
    Serial.print("Measurement complete, Distance = ");
    Serial.println(dist);
    return dist;
  }
}

int getDistance() {
  int litera;
  unsigned int dist;
  unsigned int noReply = millis();
  unsigned int noReplyTimer;
  Serial.print("Requesting a measurement...");
  measuring = true;
  Serial1.write("* 00004 # ");
  while(measuring) {
    noReplyTimer = millis() - noReply;
    if (noReplyTimer > 5000) {
      Serial1.write("* 00004 # ");
      noReply = millis();
    }
    if (Serial1.available ()> 0) {
      while (Serial1.available ()> 0) {
        litera = Serial1.read ();
        if (litera == 42) {// If passed a "* "
          data = true; // we set the sign of the beginning of the packet
        }
        if (litera == 35) {// If passed , the "# "
          data = false; // we set the sign of the end of the package ...
          recdata = true; // get and set the attribute data management ( reset) timer and further processing package
        }
        if (data == true && rc < 40 && litera> 47 ) {// If there is a sign of the beginning of the packet , the packet length is within reasonable limits and litera has a digital value by ASCII, the ...
          litera = litera- 48 ;// Convert to ASCII digit ...
          buf [rc] = litera; // And add it to an array .
          rc ++;
        }
      }
    }
    if (recdata == true) {
      if(buf[3] == 6 && buf[4] == 4) {
        dist = buf[10] * 10000;
        dist += buf[11] * 1000;
        dist += buf[12] * 100;
        dist += buf[13] * 10;
        dist += buf[14];
        Serial.print("Measurement complete, Distance = ");
        Serial.println(dist);
        measuring = false;
        buf[3] = 0;
        return dist;
      }
      rc = 0 ;
      recdata = false;
    }
  }
}

int strstart_P(const char *s1, const char * PROGMEM s2)
{
  return strncmp_P(s1, s2, strlen_P(s2)) == 0;
}

void serialSend(int rotationalPos, int vertPos, int distance) {
  Serial.print("#");
  Serial.print(rotationalPos);
  Serial.print(",");
  Serial.print(vertPos);
  Serial.print(",");
  Serial.println(distance);
}























