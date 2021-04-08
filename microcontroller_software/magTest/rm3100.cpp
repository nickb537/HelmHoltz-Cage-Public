/*

*/

// include this library's description file
#include "rm3100.h"

// We will communicate with the RM3100 over SPI
#include <SPI.h>

SPISettings settingsA(1000000, MSBFIRST, SPI_MODE0);
// Constructor //
// Function that handles the creation and setup of instances

RM3100::RM3100(int CSB)
{
  // initialize this instance's variables
  CSBp = CSB;

  // initalize the chip select pin:
  pinMode(CSBp, OUTPUT);
  digitalWrite(CSBp,HIGH);

  // start the SPI library:
  SPI.begin();
}

void RM3100::initContinuous(int t){
  if(t<0 || t>14){
    t=5;
  }
  writeRegister(TMRC, 0x92+t);
  writeRegister(CMM, 0x79);
}

void RM3100::readResult(float* arr){
    //Return x,y,z
    arr[1] = float(readRegister(MX, 3))/75;
    arr[0] = float(readRegister(MY, 3))/75;
    arr[2] = float(-readRegister(MZ, 3))/75;
}

void RM3100::singleMeasurement(int* arr) {
	// Request the data, all axes
	writeRegister(POLL, 0b01110000);


	arr[0] = 0;
	arr[1] = 0;
	arr[2] = 0;

  //delay is to allow the device make the measurement
 delay(10);

  //Read the data
  arr[0] = readRegister(MX, 3);
  arr[1] = readRegister(MY, 3);
  arr[2] = readRegister(MZ, 3);
}

//Sends a write command to RM3100
void RM3100::writeRegister(byte thisRegister, byte thisValue) {
	SPI.beginTransaction(settingsA);
	// combine the register address and the command into one byte:
	byte location = thisRegister | WRITE;

	// take the chip select low to select the device:
	digitalWrite(CSBp, LOW);
	delayMicroseconds(10);

	SPI.transfer(location); //Send register location
	SPI.transfer(thisValue);  //Send value to record into register

	// take the chip select high to de-select:
	digitalWrite(CSBp, HIGH);
 delayMicroseconds(10);
	SPI.endTransaction();
}

int RM3100::readRegister(byte thisRegister, int bytesToRead) {
	SPI.beginTransaction(settingsA);
  
	byte inByte = 0;           // incoming byte from the SPI
	int result = 0;   // result to return
					  // now combine the address and the command into one byte
	byte dataToSend = thisRegister | READ;
	// take the chip select low to select the device:
	digitalWrite(CSBp, LOW);
	delayMicroseconds(10); //Allows for remote spi device to wake up
	// send the device the register you want to read:
  
	SPI.transfer(dataToSend);
	// send a value of 0 (while reading) to read the first byte returned:
	result = SPI.transfer(0x00);
	// decrement the number of bytes left to read:
	bytesToRead--;
	// if you still have another byte to read:
	while (bytesToRead > 0) {
		// shift the first byte left, then get the second byte:
		result = result << 8;
		inByte = SPI.transfer(0x00);
		// combine the byte you just got with the previous one:
		result = result | inByte;
		// decrement the number of bytes left to read:
		bytesToRead--;
	}
	// take the chip select high to de-select:
	digitalWrite(CSBp, HIGH);

	SPI.endTransaction();
	// return the result:

  //Takes care of negative numbers
	if (result & 0x8000) {
		return (result | 0xFFFF0000);
	}
	return (result);
}
