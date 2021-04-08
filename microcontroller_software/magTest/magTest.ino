#include "RM3100.h"
#include "DAC121.h"
#include <SPI.h>

#define dCS_0 0
#define dCS_1 1
#define dCS_2 2
#define dCS_3 3
#define dCS_4 4
#define dCS_5 5
#define dCS_6 6

#define sCS_0 7
#define sCS_1 8
#define sCS_2 16
#define sCS_3 15
#define sCS_4 14

#define A_0 23
#define A_1 22
#define A_2 21
#define A_3 20
#define A_4 19
#define A_5 18
#define A_6 17


RM3100 mag0 = RM3100(sCS_0);
RM3100 mag1 = RM3100(sCS_1);
RM3100 mag2 = RM3100(sCS_2);

DAC dac0 = DAC(dCS_0);
DAC dac1 = DAC(dCS_1);
DAC dac2 = DAC(dCS_2);
DAC dac3 = DAC(dCS_3);
DAC dac4 = DAC(dCS_4);
DAC dac5 = DAC(dCS_5);
DAC dac6 = DAC(dCS_6);

float mga=0.87; //Measured gain error adjustment

void setup()
{

  //Serial communication with host computer
  Serial.begin(250000);
  //delay(1000);
  //Serial.println("Serial has been setup");
  delay(1000);
  //Setup magnetometers for continuous reading at minimum possible period 1.7 ms or 600 Hz
  mag0.initContinuous(5);
  mag1.initContinuous(5);
  //mag3.initContinuous(0);

  
  Serial.read();
  Serial.setTimeout(1);
  analogReadResolution(12);
  analogReadAveraging(32);
}

float NtoI(int N){
  return (((float(N)*3.3/4095)-1.65)/0.11)*mga;
}

short ItoN(float I){
  //Set DAC output based in input current request
  return short(I*136.5+2048);
}

void loop()
{
  String req; //Main captured string
  while(!Serial.available()){
     //Do nothing
  }
  req=Serial.readString();
  //Parse input string
  int ind1=req.indexOf(',');
  int ind2=req.indexOf(',',ind1+1);
  float xSet=(req.substring(0,ind1)).toFloat();
  float ySet=(req.substring(ind1+1,ind2)).toFloat();
  float zSet=(req.substring(ind2+1)).toFloat();
  //Requests are for current in Amps

  //Set DAC output based in input current request
  short xCode = ItoN(xSet);
  short yCode = ItoN(ySet);
  short zCode = ItoN(zSet);
  //And finally write
  dac0.write(xCode);
  dac1.write(yCode);
  dac2.write(zCode);

  //Get the coil currents
  float Ix = NtoI(analogRead(A_0));
  float Iy = NtoI(analogRead(A_1));
  float Iz = NtoI(analogRead(A_2));
  
  //Get magnetic field info
  float arr1[3];
  float arr2[3];
  mag0.readResult(arr1);
  mag1.readResult(arr2);

  //Send the results over the serial monitor
  Serial.println(arr1[0]);
  Serial.println(arr1[1]);
  Serial.println(arr1[2]);
  Serial.println(arr2[0]);
  Serial.println(arr2[1]);
  Serial.println(arr2[2]);
  Serial.println(Ix);
  Serial.println(Iy);
  Serial.println(Iz);
}
