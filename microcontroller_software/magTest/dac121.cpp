/*
 Interface with DAC121S101
 Nick Belsten
 10-29-2020
*/

// include this library's description file
#include "dac121.h"

// We will communicate with the DAC over SPI
#include <SPI.h>

SPISettings settingsB(5000000, MSBFIRST, SPI_MODE1);
// Constructor //
// Function that handles the creation and setup of instances
DAC::DAC(int SYNCB)
{
  // initialize this instance's variables
  CSBp=SYNCB;
  
  // initalize the chip select pin:
  pinMode(CSBp, OUTPUT);
  digitalWrite(CSBp,HIGH);

  // start the SPI library:
  SPI.begin();
}

void DAC::write(short val){
  SPI.beginTransaction(settingsB);
  digitalWrite(CSBp, LOW);
  delayMicroseconds(5);
  SPI.transfer16((0b111111111111&val)); //Normal mode of operation
  digitalWrite(CSBp, HIGH);
  delayMicroseconds(5);
}
